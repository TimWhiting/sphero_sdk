import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:meta/meta.dart';

import 'parsers/response.dart';
import 'parsers/response_async.dart';
import 'parsers/response_sync.dart';
import 'utils.dart';
export 'utils.dart';

const MIN_BUFFER_SIZE = 6;

class FIELDS {
  static const size = 5;
  static const sop1_pos = 0;
  static const sop1_hex = 0xff;
  static const sop2_pos = 1;
  static const sop2_sync = 0xff;
  static const sop2_async = 0xfe;
  static const mrspHex = 0x00;
  static const seqHex = 0x00;
  static const mrspIdCode = 2;
  static const seqMsb = 3;
  static const dlenLsb = 4;
  static const checksum = 5;
  static const didHex = 0x00;
  static const cidHex = 0x01;
}

class PacketV1 {
  PacketV1();
  PacketV1.create({
    int sop1,
    int sop2,
    int cid,
    int did,
    int seq,
    int checksum,
    Uint8List data,
  })  : data = data ?? Uint8List(0),
        dlen = data?.length ?? 0,
        sop1 = sop1 ?? FIELDS.sop1_hex,
        sop2 = sop2 ?? FIELDS.sop2_sync,
        cid = cid ?? FIELDS.cidHex,
        did = did ?? FIELDS.didHex,
        seq = seq ?? FIELDS.seqHex,
        checksum = checksum ?? 0x00;
  Uint8List data;
  int partialCounter = 0;

  int sop1, sop2, did, cid, seq, checksum, dlen; // adds checksum
  int mrsp, idCode, dlenMsb, dlenLsb;
  Uint8List get packet {
    print(
      '''sop1: $sop1, sop2: $sop2, did: $did, cid: $cid, dlen: $dlen, data: $data''',
    );
    final p =
        Uint8List.fromList([sop1, sop2, did, cid, seq, dlen + 1, ...data]);
    checksum = p.sublist(2).toList().checksum;
    return Uint8List.fromList([...p, checksum]);
  }
}

class PacketParser {
  PacketParser({
    this.emitPacketErrors = false,
  });
  bool emitPacketErrors;

  Uint8List partialBuffer = Uint8List(0);

  PacketV1 create(
          {int sop1,
          int sop2,
          int cid,
          int did,
          int seq,
          int checksum,
          Uint8List data}) =>
      PacketV1.create(
          sop1: sop1,
          sop2: sop2,
          cid: cid,
          did: did,
          seq: seq,
          checksum: checksum,
          data: data);

  PacketV1 parse(Uint8List buffer) {
    var b = buffer;
    if (partialBuffer.isNotEmpty) {
      b = Uint8List.fromList([...partialBuffer, ...b]);
      partialBuffer = Uint8List(0);
    } else {
      partialBuffer = b;
    }
    if (checkSOPs(b)) {
      if (checkMinSize(b) && checkExpectedSize(b) > -1) {
        return parseBuffer(b);
      }
      partialBuffer = Uint8List.fromList(b);
    }
    return null;
  }

  @visibleForTesting
  PacketV1 parseBuffer(Uint8List b) {
    final packet = PacketV1();
    packet.sop1 = b[FIELDS.sop1_pos];
    packet.sop2 = b[FIELDS.sop2_pos];

    final bByte2 = b[FIELDS.mrspIdCode],
        bByte3 = b[FIELDS.seqMsb],
        bByte4 = b[FIELDS.dlenLsb];

    if (FIELDS.sop2_sync == b[FIELDS.sop2_pos]) {
      packet.mrsp = bByte2;
      packet.seq = bByte3;
      packet.dlen = bByte4;
    } else {
      packet.idCode = bByte2;
      packet.dlenMsb = bByte3;
      packet.dlenLsb = bByte4;
    }

    packet.dlen = extractDlen(b);

    // Copy data from buffer into packet.data
    packet.data = Uint8List.fromList([
      for (final byte in b.sublist(FIELDS.size, FIELDS.size + packet.dlen - 1))
        byte
    ]);
    packet.checksum = b[FIELDS.size + packet.dlen - 1];

    dealWithExtraBytes(b);

    return verifyChecksum(b, packet);
  }

  @visibleForTesting
  void dealWithExtraBytes(Uint8List b) {
    // If the packet was parsed successfully, and the buffer and
    // expected size of the buffer are the same, clean up the
    // partialBuffer, otherwise assign extrabytes to partialBuffer
    final expectedSize = checkExpectedSize(b);
    if (b.length > expectedSize) {
      partialBuffer = Uint8List.fromList(
          [for (final byte in b.sublist(expectedSize)) byte]);
    } else {
      partialBuffer = Uint8List(0);
    }
  }

  @visibleForTesting
  PacketV1 verifyChecksum(Uint8List buffer, PacketV1 packet) {
    final bSlice =
        buffer.sublist(FIELDS.mrspIdCode, FIELDS.checksum + packet.dlen - 1);
    final checksum = bSlice.checksum;

    // If we got an incorrect checksum we cleanup the packet,
    // partialBuffer, return null and emit an error event
    if (checksum != packet.checksum) {
      partialBuffer = Uint8List(0);
      if (emitPacketErrors) {
        throw Exception('Incorrect checksum, packet discarded!');
      }
    }
    return packet;
  }

  Map<String, dynamic> parseAsyncData(PacketV1 payload, Map<String, int> ds) {
    final parser = ASYNC_PARSER[payload.idCode];

    return parseDataMap(parser, payload, ds);
  }

  Map<String, dynamic> parseResponseData(
      Map<String, int> cmd, PacketV1 payload) {
    if (cmd == null || cmd['did'] == null || cmd['cid'] == null) {
      throw Exception(payload);
    }
    final parserId =
            // ignore: prefer_interpolation_to_compose_strings
            cmd['did'].toRadixString(16) + ':' + cmd['cid'].toRadixString(16),
        parser = RES_PARSER[parserId];

    return parseDataMap(parser, payload);
  }

  @visibleForTesting
  Map<String, dynamic> parseDataMap(APIV1 parser, PacketV1 payload,
      [Map<String, int> dsIn]) {
    final data = payload.data;
    Map<String, dynamic> pData;
    APIField field;
    var ds = dsIn;
    if (parser != null && (data.isNotEmpty)) {
      try {
        ds = checkDSMasks(ds, parser);
      } on Exception catch (e) {
        print(e);
        return {'payload': payload};
      }

      final fields = parser.fields;

      pData = {
        'desc': parser.desc,
        'idCode': parser.idCode,
        'event': parser.event,
        'did': parser.did,
        'cid': parser.cid,
        'packet': payload
      };

      var dsIndex = 0, dsFlag = 0, i = 0;

      while (i < fields.length) {
        field = fields[i];

        dsFlag = checkDSBit(ds, field);

        if (dsFlag == 1) {
          field = field.copyWith(from: dsIndex, to: dsIndex + 2);
          dsIndex += 2;
        } else if (dsFlag == 0) {
          i = incParserIndex(i, fields, data, dsFlag, dsIndex);
          continue;
        }

        pData[field.name] = parseField(field, data, pData);

        i = incParserIndex(i, fields, data, dsFlag, dsIndex);
      }
    } else {
      print('No parser found:  data: $payload');
      return {'payload': payload};
    }

    return pData;
  }

  @visibleForTesting
  Map<String, int> checkDSMasks(Map<String, int> ds, APIV1 parser) {
    if (parser.idCode == 0x03) {
      if (!(ds != null && ds['mask1'] != null && ds['mask2'] != null)) {
        throw Exception();
      }
    } else {
      return null;
    }

    return ds;
  }

  @visibleForTesting
  int incParserIndex(int iIn, List<APIField> fields, Uint8List data,
      [int dsFlag = 0, int dsIndex]) {
    var i = iIn + 1;

    if ((dsFlag >= 0) && (i == fields.length) && (dsIndex < data.length)) {
      i = 0;
    }

    return i;
  }

  @visibleForTesting
  int checkDSBit(Map<String, int> ds, APIField field) {
    if (ds == null) {
      return -1;
    }

    if ((ds[field.maskField] & field.bitmask).abs() > 0) {
      return 1;
    }

    return 0;
  }

  @visibleForTesting
  dynamic parseField(APIField field, Uint8List dataIn,
      [Map<String, dynamic> pData = const {}]) {
    dynamic pField;
    final data = dataIn.sublist(field.from, field.to ?? dataIn.length);
    final intField = data.isNotEmpty ? bufferToInt(data) : 0;
    pField = intField;

    switch (field.type) {
      case 'number':
        if (field.format == 'hex') {
          // ignore: prefer_interpolation_to_compose_strings
          pField = '0x' + intField.toRadixString(16).toUpperCase();
        }
        break;
      case 'string':
        pField = data.toStringFormat(field.format).replaceAll('\0', '0');
        break;
      case 'raw':
        pField = data;
        break;
      case 'predefined':
        if (field.mask != null) {
          pField = intField & field.mask;
        }
        pField = field.values[pField as int];
        break;
      case 'bitmask':
        pField = parseBitmaskField(intField, field, pData);
        break;
      case 'signed':
        final width = 8 * (field.to - field.from);
        pField = intField;
        if (intField >= pow(2, width - 1)) {
          pField = pField - pow(2, width);
        }
        break;
      default:
        throw Exception('Data could not be parsed!');
        pField = 'Data could not be parsed!';
        break;
    }

    return pField;
  }

  @visibleForTesting
  Map<String, dynamic> parseBitmaskField(
      int valIn, APIField field, Map<String, dynamic> pData) {
    var pField = <String, dynamic>{};
    print('valIn $valIn, $field, $pData');
    var val = valIn;
    if (val > field.rangeTop) {
      val = twosToInt(val, 2);
    }

    if (pData[field.name] != null) {
      pField = pData[field.name] as Map<String, dynamic>;
      pField['value'].add(val);
    } else {
      pField = {
        'sensor': field.sensor,
        'range': {'top': field.rangeTop, 'bottom': field.rangeBottom},
        'units': field.units,
        'value': [val]
      };
    }

    return pField;
  }

  @visibleForTesting
  bool checkSOPs(Uint8List buffer) =>
      // ignore: avoid_bool_literals_in_conditional_expressions
      checkSOP1(buffer) ? checkSOP2(buffer) != false : false;

  @visibleForTesting
  bool checkSOP1(Uint8List buffer) =>
      buffer[FIELDS.sop1_pos] == FIELDS.sop1_hex;

  @visibleForTesting
  dynamic checkSOP2(Uint8List buffer) {
    final sop2 = buffer[FIELDS.sop2_pos];

    if (sop2 == FIELDS.sop2_sync) {
      return 'sync';
    } else if (sop2 == FIELDS.sop2_async) {
      return 'async';
    }

    return false;
  }

  @visibleForTesting
  int checkExpectedSize(Uint8List buffer) {
    // Size = buffer fields size (SOP1, SOP2, MSRP, SEQ and DLEN) + DLEN value
    final expectedSize = FIELDS.size + extractDlen(buffer),
        bufferSize = buffer.length;

    return (bufferSize < expectedSize) ? -1 : expectedSize;
  }

  @visibleForTesting
  bool checkMinSize(Uint8List buffer) => buffer.length >= MIN_BUFFER_SIZE;

  @visibleForTesting
  int extractDlen(Uint8List buffer) {
    if (buffer[FIELDS.sop2_pos] == FIELDS.sop2_sync) {
      return buffer[FIELDS.dlenLsb];
    }

    // We shift the dlen MSB 8 bits and then do a binary OR
    // between the two values to obtain the dlen value
    return (buffer[FIELDS.seqMsb] << 8) | buffer[FIELDS.dlenLsb];
  }
}

extension ToStringFormat on Uint8List {
  String toStringFormat(String format) {
    switch (format) {
      case 'ascii':
        return utf8.decode(this);
      case 'hex':
        final intField = bufferToInt(this);
        return intField.toRadixString(16);
    }
    throw UnimplementedError();
  }
}
