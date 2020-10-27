import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'parsers/response.dart';
import 'parsers/response_async.dart';
import 'parsers/response_sync.dart';
import 'utils.dart';

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
  Uint8List data;
  int partialCounter = 0;
  PacketV1();
  PacketV1.create({
    this.sop1 = FIELDS.sop1_hex,
    this.sop2 = FIELDS.sop2_sync,
    this.cid = FIELDS.cidHex,
    this.did = FIELDS.didHex,
    this.seq = FIELDS.seqHex,
    this.checksum = 0x00,
    Uint8List data,
  })  : data = data == null ? Uint8List(0) : data,
        dlen = data.length = 1;
  int sop1, sop2, did, cid, seq, checksum, dlen; // adds checksum
  int mrsp, idCode, dlenMsb, dlenLsb;
  Uint8List get packet {
    final p = Uint8List.fromList([sop1, sop2, did, cid, seq, dlen, ...data]);
    checksum = p.sublist(2).toList().checksum;
    p.add(checksum);
    return p;
  }
}

class PacketParser {
  PacketParser({
    this.emitPacketErrors = false,
  });
  bool emitPacketErrors;

  Uint8List partialBuffer = Uint8List(0);
  parse(Uint8List buffer) {
    var b = buffer;
    if (partialBuffer.length > 0) {
      b = Uint8List.fromList([...partialBuffer, ...b]);
      partialBuffer = Uint8List(0);
    } else {
      partialBuffer = b;
    }
    if (_checkSOPs(b)) {
      if (_checkMinSize(b) && _checkExpectedSize(b) > -1) {
        return _parse(b);
      }
      partialBuffer = Uint8List.fromList(b);
    }
    return null;
  }

  PacketV1 _parse(Uint8List b) {
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

    packet.dlen = _extractDlen(b);

    // Copy data from buffer into packet.data
    packet.data = Uint8List.fromList([
      for (final byte in b.sublist(FIELDS.size, FIELDS.size + packet.dlen - 1))
        byte
    ]);
    packet.checksum = b[FIELDS.size + packet.dlen - 1];

    _dealWithExtraBytes(b);

    return _verifyChecksum(b, packet);
  }

  void _dealWithExtraBytes(Uint8List b) {
    // If the packet was parsed successfully, and the buffer and
    // expected size of the buffer are the same, clean up the
    // partialBuffer, otherwise assign extrabytes to partialBuffer
    final expectedSize = _checkExpectedSize(b);
    if (b.length > expectedSize) {
      partialBuffer = Uint8List.fromList(
          [for (final byte in b.sublist(expectedSize)) byte]);
    } else {
      partialBuffer = Uint8List(0);
    }
  }

  PacketV1 _verifyChecksum(Uint8List buffer, PacketV1 packet) {
    final bSlice =
        buffer.sublist(FIELDS.mrspIdCode, FIELDS.checksum + packet.dlen - 1);
    final checksum = bSlice.checksum;

    // If we got an incorrect checksum we cleanup the packet,
    // partialBuffer, return null and emit an error event
    if (checksum != packet.checksum) {
      partialBuffer = Uint8List(0);
      if (emitPacketErrors) {
        throw Exception("Incorrect checksum, packet discarded!");
      }
    }
    return packet;
  }

  Map<String, dynamic> parseAsyncData(PacketV1 payload, Map<String, int> ds) {
    final parser = ASYNC_PARSER[payload.idCode];

    return _parseData(parser, payload, ds);
  }

  Map<String, dynamic> parseResponseData(APIV1 cmd, PacketV1 payload) {
    if (cmd == null || cmd.did == null || cmd.cid == null) {
      throw Exception(payload);
    }

    final parserId =
            cmd.did.toRadixString(16) + ":" + cmd.cid.toRadixString(16),
        parser = RES_PARSER[parserId];

    return _parseData(parser, payload);
  }

  Map<String, dynamic> _parseData(APIV1 parser, PacketV1 payload,
      [Map<String, int> ds]) {
    var data = payload.data, pData, fields, field;

    if (parser != null && (data.length > 0)) {
      try {
        ds = _checkDSMasks(ds, parser);
      } catch (e) {
        throw Exception(payload);
      }

      fields = parser.fields;

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

        dsFlag = _checkDSBit(ds, field);

        if (dsFlag == 1) {
          field.from = dsIndex;
          field.to = dsIndex = dsIndex + 2;
        } else if (dsFlag == 0) {
          i = _incParserIndex(i, fields, data, dsFlag, dsIndex);
          continue;
        }

        pData[field.name] = _parseField(field, data, pData);

        i = _incParserIndex(i, fields, data, dsFlag, dsIndex);
      }
    } else {
      pData = payload;
    }

    return pData;
  }

  Map<String, int> _checkDSMasks(Map<String, int> ds, APIV1 parser) {
    if (parser.idCode == 0x03) {
      if (!(ds != null && ds['mask1'] != null && ds['mask2'] != null)) {
        throw Exception();
      }
    } else {
      return null;
    }

    return ds;
  }

  int _incParserIndex(
      int i, List<APIField> fields, Uint8List data, int dsFlag, int dsIndex) {
    i++;

    if ((dsFlag >= 0) && (i == fields.length) && (dsIndex < data.length)) {
      i = 0;
    }

    return i;
  }

  int _checkDSBit(Map<String, int> ds, APIField field) {
    if (ds == null) {
      return -1;
    }

    if ((ds[field.maskField] & field.bitmask).abs() > 0) {
      return 1;
    }

    return 0;
  }

  dynamic _parseField(
      APIField field, Uint8List data, Map<String, dynamic> pData) {
    var pField;
    data = data.sublist(field.from, field.to);
    final intField = bufferToInt(data);

    switch (field.type) {
      case "number":
        if (field.format == "hex") {
          pField = "0x" + intField.toRadixString(16).toUpperCase();
        }
        break;
      case "string":
        pField = data.toStringFormat(field.format).replaceAll('\0', "0");
        break;
      case "raw":
        pField = data;
        break;
      case "predefined":
        if (field.mask != null) {
          pField = intField & field.mask;
        }
        pField = field.values[intField];
        break;
      case "bitmask":
        pField = _parseBitmaskField(intField, field, pData);
        break;
      case "signed":
        final width = 8 * (field.to - field.from);
        pField = intField;
        if (pField >= pow(2, width - 1)) {
          pField = pField - pow(2, width);
        }
        break;
      default:
        throw Exception("Data could not be parsed!");
        pField = "Data could not be parsed!";
        break;
    }

    return pField;
  }

  Map<String, dynamic> _parseBitmaskField(
      int val, APIField field, Map<String, dynamic> pData) {
    var pField = {};

    if (val > field.range_top) {
      val = twosToInt(val, 2);
    }

    if (pData[field.name] != null) {
      pField = pData[field.name];
      pField['value'].add(val);
    } else {
      pField = {
        'sensor': field.sensor,
        'range': {'top': field.range_top, 'bottom': field.range_bottom},
        'units': field.units,
        'value': [val]
      };
    }

    return pField;
  }

  bool _checkSOPs(Uint8List buffer) {
    return _checkSOP1(buffer) ? _checkSOP2(buffer) != false : false;
  }

  bool _checkSOP1(Uint8List buffer) {
    return buffer[FIELDS.sop1_pos] == FIELDS.sop1_hex;
  }

  dynamic _checkSOP2(Uint8List buffer) {
    final sop2 = buffer[FIELDS.sop2_pos];

    if (sop2 == FIELDS.sop2_sync) {
      return "sync";
    } else if (sop2 == FIELDS.sop2_async) {
      return "async";
    }

    return false;
  }

  int _checkExpectedSize(Uint8List buffer) {
    // Size = buffer fields size (SOP1, SOP2, MSRP, SEQ and DLEN) + DLEN value
    final expectedSize = FIELDS.size + _extractDlen(buffer),
        bufferSize = buffer.length;

    return (bufferSize < expectedSize) ? -1 : expectedSize;
  }

  bool _checkMinSize(Uint8List buffer) {
    return (buffer.length >= MIN_BUFFER_SIZE);
  }

  int _extractDlen(Uint8List buffer) {
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
