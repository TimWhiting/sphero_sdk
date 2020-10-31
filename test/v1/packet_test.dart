import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/packet.dart';
import 'package:sphero_sdk/src/v1/parsers/response.dart';
import 'package:sphero_sdk/src/v1/parsers/response_async.dart';

void main() {
  PacketParser packet;
  group('packet', () {
    setUp(() {
      packet = PacketParser(emitPacketErrors: true);
    });

    group('create', () {
      Uint8List buffer;
      Map<String, dynamic> opts;

      Uint8List optsToPacket(Map<String, dynamic> opts) {
        if (opts.containsKey('sop1')) {
          return packet
              .create(
                sop1: opts['sop1'] as int,
                sop2: opts['sop2'] as int,
                cid: opts['cid'] as int,
                did: opts['did'] as int,
                seq: opts['seq'] as int,
                data: opts['data'] as Uint8List,
              )
              .packet;
        } else {
          return packet
              .create(
                sop2: opts['sop2'] as int,
                cid: opts['cid'] as int,
                did: opts['did'] as int,
                seq: opts['seq'] as int,
                data: opts['data'] as Uint8List,
              )
              .packet;
        }
      }

      setUp(() {
        opts = {
          'sop2': 0xFE,
          'did': 0x01,
          'cid': 0x02,
          'seq': 0x03,
          'data': Uint8List.fromList([0x04, 0x05, 0x06, 0x07, 0x08])
        };

        buffer = optsToPacket(opts);
      });

      test('sets 1st byte of the array (SOP1) the value passed', () {
        opts['sop1'] = 0xF0;
        buffer = optsToPacket(opts);
        expect(buffer[0], 0xF0);
      });

      test('sets 2nd byte of the array (SOP2) to 0xFE', () {
        expect(buffer[1], 0xFE);
      });

      test('sets 3rd byte of the array (DID) to 0x01', () {
        expect(buffer[2], 0x01);
      });

      test('sets 4th byte of the array (CID) to 0x02', () {
        expect(buffer[3], 0x02);
      });

      test('sets 5th byte of the array (SEQ) to 0x03', () {
        expect(buffer[4], 0x03);
      });

      test('sets 6th byte of the array (DLEN) to 0x06', () {
        expect(buffer[5], 0x06);
      });

      test('sets the checksum (last byte) of the array to 0xD5', () {
        expect(buffer[buffer.length - 1], 0xD5);
      });

      group('when packet opts not specified', () {
        setUp(() {
          buffer = packet.create().packet;
        });

        test('sets 1st byte of the array (SOP1) to 0xFF', () {
          expect(buffer[0], 0xFF);
        });

        test('sets 2nd byte of the array (SOP2) defult value', () {
          expect(buffer[1], 0xFF);
        });

        test('sets 3rd byte of the array (DID) to 0x01', () {
          expect(buffer[2], 0x00);
        });

        test('sets 4th byte of the array (CID) to 0x02', () {
          expect(buffer[3], 0x01);
        });

        test('sets 5th byte of the array (SEQ) to 0x03', () {
          expect(buffer[4], 0x00);
        });

        test('sets data of the array (data) to []', () {
          expect(buffer[5], 1);
        });
      });
    });

    group('parse', () {
      group('with sync response', () {
        Uint8List buffer;
        PacketV1 res;
        List<int> data;

        setUp(() {
          data = [0x05, 0x04, 0x03, 0x02, 0x01];
          buffer = Uint8List.fromList(
            [
              0xFF,
              0xFF,
              0x00,
              0x02,
              0x06,
              ...data,
              0xE8,
            ],
          );

          res = packet.parse(buffer);
        });

        test('res@sop1 should be 0xFF', () {
          expect(res.sop1, 0xFF);
        });

        test('res@sop2 should be 0xFF', () {
          expect(res.sop2, 0xFF);
        });

        test('res@mrsp should be 0x00', () {
          expect(res.mrsp, 0x00);
        });

        test('res@seq should be 0x02', () {
          expect(res.seq, 0x02);
        });

        test('res@dlen should be 0x06', () {
          expect(res.dlen, 0x06);
        });

        test('res@data should be a buffer 6 bytes long', () {
          expect(res.data.length, res.dlen - 1);
        });

        test('res@data should be eql', () {
          final tmpBuffer = Uint8List.fromList(data);
          expect(res.data, tmpBuffer);
        });

        test('res@checksum should be 0xFE', () {
          expect(res.checksum, 0xE8);
        });

        group(' when checksum is incorrect', () {
          setUp(() {
            final tmpBuffer = [0xFF, 0xFF, 0x00, 0x02, 0x06];

            data = [0x05, 0x04, 0x03, 0x02, 0x01];
            buffer = Uint8List.fromList([...tmpBuffer, ...data, 0xEE]);

            packet.emitPacketErrors = true;
          });

          test('emits an error event with a checksum Error param', () {
            expect(
                () => packet.parse(buffer),
                throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                    'Exception: Incorrect checksum, packet discarded!')));
          });

          test('partialBuffer should be empty', () {
            try {
              packet.parse(buffer);
            } on Exception catch (_) {}
            expect(packet.partialBuffer.length, 0);
          });

          // test('res should be null', () { // Throws instead
          //   try {
          //     res = packet.parse(buffer);
          //   } on Exception catch (_) {}
          //   expect(res, null);
          // });
        });

        group('buffer length is less than minSizeReq', () {
          setUp(() {
            buffer = Uint8List.fromList([0xFF, 0xFF, 0x00, 0x02]);

            res = packet.parse(buffer);
          });

          test('partialBuffer should not be empty', () {
            expect(packet.partialBuffer.length, 4);
          });

          test('res should be null', () {
            expect(res, null);
          });
        });

        group('buffer length is less than expectedSize', () {
          setUp(() {
            buffer =
                Uint8List.fromList([0xFF, 0xFF, 0x00, 0x02, 0x06, 0x01, 0x02]);

            res = packet.parse(buffer);
          });

          test('partialBuffer should not be empty', () {
            expect(packet.partialBuffer.length, 7);
          });

          test('res should be null', () {
            expect(res, null);
          });
        });

        group('buffer length is greater than expectedSize', () {
          setUp(() {
            buffer = Uint8List.fromList(
                [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC, 0xFF, 0xFF, 0x00]);

            res = packet.parse(buffer);
          });

          test('partialBuffer should not be empty', () {
            expect(packet.partialBuffer.length, 3);
          });

          test('partialBuffer should be eql to', () {
            final tmpBuffer = Uint8List.fromList([0xFF, 0xFF, 0x00]);
            expect(packet.partialBuffer, tmpBuffer);
          });

          test('res should be a packet obj', () {
            expect(res, isNotNull);
            expect(res.sop1, 0xFF);
            expect(res.sop2, 0xFF);
            expect(res.seq, 0x02);
            expect(res.data, Uint8List.fromList([]));
            expect(res.checksum, 0xFC);
            expect(res.mrsp, 0x00);
          });
        });

        group('SOPs don\'t pass validation', () {
          setUp(() {
            buffer = Uint8List.fromList([0xF0, 0x00, 0x02, 0x01, 0xFC]);
          });

          group('and @partialBuffer is empty', () {
            setUp(() {
              res = packet.parse(buffer);
            });

            test('partialBuffer should not be empty', () {
              expect(packet.partialBuffer.length, 5);
            });

            test('res should be null', () {
              expect(res, null);
            });
          });

          group('and @partialBuffer is NOT empty', () {
            setUp(() {
              packet.partialBuffer = Uint8List.fromList([0xFF]);
              res = packet.parse(buffer);
            });

            test('partialBuffer should be empty', () {
              expect(packet.partialBuffer.length, 0);
            });

            test('res should be null', () {
              expect(res, null);
            });
          });
        });

        group('when partialResponse is not empty', () {
          setUp(() {
            buffer = Uint8List.fromList([0xFF, 0x00, 0x02, 0x01, 0xFC]);
            packet.partialBuffer = Uint8List.fromList([0xFF]);

            res = packet.parse(buffer);
          });

          test('returns a packet obj when calling parse', () {
            expect(res, isNotNull);
            expect(res.sop1, 0xFF);
            expect(res.sop2, 0xFF);
            expect(res.mrsp, 0x00);
            expect(res.seq, 0x02);
            expect(res.dlen, 0x01);
            expect(res.data, Uint8List(0));
            expect(res.checksum, 0xFC);
          });
        });

        test('packet@partialBuffer is empty', () {
          expect(packet.partialBuffer.length, 0);
        });
      });
    });

    group('sync response', () {
      Uint8List buffer;
      PacketV1 res;
      List<int> data;

      setUp(() {
        data = [0x05, 0x04, 0x03, 0x02, 0x01];
        buffer =
            Uint8List.fromList([0xFF, 0xFE, 0x0A, 0x00, 0x06, ...data, 0xE0]);

        res = packet.parse(buffer);
      });

      test('packet res@idCode should be 0x0A', () {
        expect(res.idCode, 0x0A);
      });

      test('packet res@dlenMsb should be 0x00', () {
        expect(res.dlenMsb, 0x00);
      });

      test('packet res@dlenLsb should be 0x06', () {
        expect(res.dlenLsb, 0x06);
      });

      test('packet res@dlen should be 0x06', () {
        expect(res.dlen, 0x06);
      });

      test('packet res@checksum should be 0xFE', () {
        expect(res.checksum, 0xE0);
      });
    });
    group('parseResponseData', () {
      PacketV1 payload;
      Map<String, dynamic> res;
      setUp(() {
        payload = PacketV1.create(
          sop1: 0xFF,
          sop2: 0xFF,
          seq: 0x02,
          data: Uint8List.fromList([
            0,
            0,
            0,
            0,
            0,
          ]),
          checksum: 0xFC,
        )..mrsp = 0x00;

        // stub(packet, '_parseData');
        // packet.parseDataMap.returns({val1: 'uno'});

        res = packet.parseResponseData({'did': 0x02, 'cid': 0x07}, payload);
      });

      test('throws if cmd is not valid', () {
        expect(
            () => packet.parseResponseData({}, payload),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                'Exception: Instance of \'PacketV1\'')));
      });

      test('calls parseDataMap with params', () {
        const parser = APIV1(
            desc: 'Get Chassis Id',
            did: 2,
            cid: 7,
            event: 'chassisId',
            fields: [APIField(name: 'chassisId', type: 'number')]);
        expect(res.containsKey('chassisId'), true);
        expect(res['chassisId'], null);
      });
    });

    group('CheckdsMasks', () {
      test('returns null when idCode != 0x03', () {
        final res = packet.checkDSMasks({}, const APIV1(idCode: 0x07));
        expect(res, isNull);
      });

      test('returns ds obj when ds is valid and idCode == 0x03', () {
        final ds = {'mask1': 0xFF00, 'mask2': 0x00FF};
        final res = packet.checkDSMasks(
            {'mask1': 0xFF00, 'mask2': 0x00FF}, const APIV1(idCode: 0x03));
        expect(res, ds);
      });

      test('returns -1 when ds is invalid and idCode == 0x03', () {
        final ds = {'mask1': 0xFF00};
        expect(() => packet.checkDSMasks(ds, const APIV1(idCode: 0x03)),
            throwsA(isA<Exception>()));
      });
    });

    group('incParserIndex', () {
      test('returns i++ with dsFlag < 0', () {
        final res = packet.incParserIndex(0, [], Uint8List.fromList([]), -1, 0);
        expect(res, equals(1));
      });

      test('returns i++ with i < fields.length', () {
        final res = packet.incParserIndex(
            0, [null, null, null], Uint8List.fromList([4, 5, 6]));
        expect(res, equals(1));
      });

      test('returns i++ with dsIndex = data.length', () {
        final res = packet.incParserIndex(
            0, [null, null, null], Uint8List.fromList([4, 5, 6, 7]), 0, 4);
        expect(res, equals(1));
      });

      test('returns i = 0 when all conditions met', () {
        final res = packet.incParserIndex(3, [null, null, null, null],
            Uint8List.fromList([4, 5, 6, 7]), 0, 2);
        expect(res, equals(0));
      });
    });

    group('checker', () {
      test('_checksum should return 0xFC', () {
        final buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
            check = buffer.sublist(3, 5).checksum;
        expect(check, 0xFC);
      });

      test('checkSOPs with SOP2 0xFF should return true', () {
        final buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
            check = packet.checkSOPs(buffer.asUint8List);
        expect(check, true);
      });

      test('checkSOPs with SOP2 0xFE should return true', () {
        final buffer = [0xFF, 0xFE, 0x00, 0x02, 0x01, 0xFC],
            check = packet.checkSOPs(buffer.asUint8List);
        expect(check, true);
      });

      test('checkSOPs with SOP2 0xFC should return false', () {
        final buffer = [0xFF, 0xFC, 0x00, 0x02, 0x01, 0xFC],
            check = packet.checkSOPs(buffer.asUint8List);
        expect(check, false);
      });

      test('checkExpectedSize should return 6 when size == expected', () {
        final buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
            check = packet.checkExpectedSize(buffer.asUint8List);
        expect(check, 6);
      });

      test('checkExpectedSize should return -1 when size < expected', () {
        final buffer = [0xFF, 0xFC, 0x00, 0x02, 0x04, 0x02, 0x03],
            check = packet.checkExpectedSize(buffer.asUint8List);
        expect(check, -1);
      });

      test('checkMinSize should return true when size >= min', () {
        final buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
            check = packet.checkMinSize(buffer.asUint8List);
        expect(check, true);
      });

      test('checkMinSize should return false when size < min', () {
        final buffer = [0xFF, 0xFC, 0x00, 0x02, 0x01],
            check = packet.checkMinSize(buffer.asUint8List);
        expect(check, false);
      });
    });

    group('checkDSBit', () {
      test('returns -1 when DS is invalid', () {
        final res = packet.checkDSBit(null, null);
        expect(res, equals(-1));
      });

      test('returns 1 when DS valid and field in mask1|2', () {
        final res = packet.checkDSBit(
          {'mask1': 0xFFFF},
          const APIField(bitmask: 0x1000, maskField: 'mask1'),
        );
        expect(res, equals(1));
      });

      test('returns 0 when DS valid and field not in mask1|2', () {
        final res = packet.checkDSBit({'mask1': 0x0FFF},
            const APIField(bitmask: 0x1000, maskField: 'mask1'));
        expect(res, equals(0));
      });
    });

    group('parseField', () {
      Uint8List data;
      APIField field;

      setUp(() {
        field = const APIField(
          name: 'chassisId',
          type: 'number',
        );

        data = [0xFF, 0xFE, 0x00, 0x01].asUint8List;
      });

      group('when field type is: ', () {
        test('"number" returns the value', () {
          final res = packet.parseField(field, [255].asUint8List);
          expect(res, equals(255));
        });

        test('"signed" returns the signed value', () {
          field = field.copyWith(type: 'signed', from: 0, to: 1);
          final tmpVal = packet.parseField(
            field,
            [0xFF, 0xFE, 0x00, 0x01].asUint8List,
          );
          expect(tmpVal, -1);
        });

        test('"number" returns a hex string when format == "hex"', () {
          field = field.copyWith(format: 'hex');
          final res = packet.parseField(field, [255].asUint8List);
          expect(res, equals('0xFF'));
        });

        test('"string" returns a string with format == "ascii"', () {
          field = field.copyWith(type: 'string', format: 'ascii');
          final res = packet.parseField(
              field, [0x48, 0x6F, 0x6C, 0x61, 0x21].asUint8List);
          expect(res, equals('Hola!'));
        });

        test('"raw" returns the raw array', () {
          final buffer = Uint8List.fromList([0x48, 0x6F, 0x6C, 0x61, 0x21]);
          field = field.copyWith(type: 'raw');
          final tmpVal = packet.parseField(field, buffer);
          expect(tmpVal, buffer);
        });

        test('"predefined" returns "battery OK"', () {
          final buffer = Uint8List.fromList([0x02]);
          field =
              field.copyWith(type: 'predefined', values: {0x02: 'battery OK'});
          final res = packet.parseField(field, buffer);
          expect(res, equals('battery OK'));
        });

        test('"predefined" returns "true" with mask', () {
          final buffer = Uint8List.fromList([0x0F]);
          field = field
              .copyWith(type: 'predefined', mask: 0x01, values: {0x01: true});
          final res = packet.parseField(field, buffer);
          expect(res, equals(true));
        });

        test('"bitmask" calls parseBitmaskField', () {
          // packet.parseBitmaskField.returns({val: 'all Good'});
          field = ASYNC_PARSER[0x03].fields.first;
          final res = packet
              .parseField(field, [0x01, 0x02].asUint8List, {'val1': 'one'});
          expect(
              res,
              equals({
                'sensor': 'accelerometer axis X, raw',
                'range': {'top': 2047, 'bottom': -2048},
                'units': '4mg',
                'value': [258]
              }));
        });

        test('"bitmask" calls parseBitmaskField and errors', () {
          field = field.copyWith(type: 'thevoid');
          expect(
              () => packet.parseField(field, [0x01, 0x02].asUint8List),
              throwsA(isA<Exception>().having((e) => e.toString(), 'message',
                  'Exception: Data could not be parsed!')));
        });
      });
    });

    group('_parseBitmaskField', () {
      Map<String, dynamic> fieldMap;
      APIField field;

      setUp(() {
        fieldMap = {
          'name': 'gyro',
          'sensor': 'gyro',
          'units': 'gyrons',
          'range': {
            'top': 0x0FFF,
            'bottom': -255,
          },
          'value': [1]
        };
        field = const APIField(
          name: 'gyro',
          sensor: 'gyro',
          units: 'gyrons',
          rangeTop: 0x0FFF,
          rangeBottom: -255,
        );
      });

      test(' if val > field.range.top calls utilstwosToInt', () {
        final res = packet.parseBitmaskField(0xFF00, field, {});
        expect(res['value'].length, 1);
      });

      test('adds to the array if field already exist', () {
        final res = packet.parseBitmaskField(0xFF, field, {'gyro': fieldMap});
        expect(res['value'].length, 2);
        expect(res['value'][1], 255);
      });
    });
  });
}
