import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/packet.dart';

void main() {
  PacketParser packet;
  group('packet', (){
     setUp(() {
    packet =  PacketParser(emitPacketErrors: true);
  });

  group('#create', () {
    Uint8List buffer;
Map<String, dynamic> opts;
    setUp(() {
     opts = { sop2: 0xFE,
        did: 0x01,
        cid: 0x02,
        seq: 0x03,
        data: Uint8List.fromList([0x04, 0x05, 0x06, 0x07, 0x08]);
     }
      buffer = packet.create().packet;
    });


    test('sets 1st byte of the array (SOP1) the value passed', () {
      opts.sop1 = 0xF0;
      buffer = packet.create(opts);
      expect(buffer[0]).to.be.eql(0xF0);
    });

    test('sets 2nd byte of the array (SOP2) to 0xFE', () {
      expect(buffer[1]).to.be.eql(0xFE);
    });

    test('sets 3rd byte of the array (DID) to 0x01', () {
      expect(buffer[2]).to.be.eql(0x01);
    });

    test('sets 4th byte of the array (CID) to 0x02', () {
      expect(buffer[3]).to.be.eql(0x02);
    });

    test('sets 5th byte of the array (SEQ) to 0x03', () {
      expect(buffer[4]).to.be.eql(0x03);
    });

    test('sets 6th byte of the array (DLEN) to 0x03', () {
      expect(buffer[5]).to.be.eql(0x06);
    });

    test('sets the checksum (last byte) of the array to 0xD5', () {
      expect(buffer[buffer.length - 1]).to.be.eql(0xD5);
    });

    group('when packet opts not specified', () {
      setUp(() {
        buffer = packet.create();
      });

      test('sets 1st byte of the array (SOP1) to 0xFF', () {
        expect(buffer[0]).to.be.eql(0xFF);
      });

      test('sets 2nd byte of the array (SOP2) defult value', () {
        expect(buffer[1]).to.be.eql(0xFF);
      });

      test('sets 3rd byte of the array (DID) to 0x01', () {
        expect(buffer[2]).to.be.eql(0x00);
      });

      test('sets 4th byte of the array (CID) to 0x02', () {
        expect(buffer[3]).to.be.eql(0x01);
      });

      test('sets 5th byte of the array (SEQ) to 0x03', () {
        expect(buffer[4]).to.be.eql(0x00);
      });

      test('sets data of the array (data) to []', () {
        expect(buffer[5]).to.be.eql(1);
      });
    });
  });

  group('#parse', () {
    group('with sync response', () {
      var buffer, res, data;

      setUp(() {
        data = [0x05, 0x04, 0x03, 0x02, 0x01];
        buffer = new Buffer([0xFF, 0xFF, 0x00, 0x02, 0x06].concat(data, 0xE8));

        res = packet.parse(buffer);
      });

      test('turns a sphero buffer response into a response obj', () {
        expect(res).to.be.an.instanceOf(Object);
      });

      test('res@sop1 should be 0xFF', () {
        expect(res.sop1).to.be.eql(0xFF);
      });

      test('res@sop2 should be 0xFF', () {
        expect(res.sop2).to.be.eql(0xFF);
      });

      test('res@mrsp should be 0x00', () {
        expect(res.mrsp).to.be.eql(0x00);
      });

      test('res@seq should be 0x02', () {
        expect(res.seq).to.be.eql(0x02);
      });

      test('res@dlen should be 0x06', () {
        expect(res.dlen).to.be.eql(0x06);
      });

      test('res@data should be a buffer 6 bytes long', () {
        expect(res.data).to.be.an.instanceOf(Buffer);
        expect(res.data.length).to.be.eql(res.dlen - 1);
      });

      test('res@data should be eql', () {
        var tmpBuffer = new Buffer(data);
        expect(res.data).to.be.eql(tmpBuffer);
      });

      test('res@checksum should be 0xFE', () {
        expect(res.checksum).to.be.eql(0xE8);
      });

      group(' when checksum is incorrect', () {
        setUp(() {
          var tmpBuffer = [0xFF, 0xFF, 0x00, 0x02, 0x06];

          data = [0x05, 0x04, 0x03, 0x02, 0x01];
          buffer = new Buffer(tmpBuffer.concat(data, 0xEE));

          stub(packet, 'emit');

          packet.emitPacketV1Errors = true;
          res = packet.parse(buffer);
        });

        afterEach(() {
          packet.emit.restore;
        });

        test('emits an error event with a checksum Error param', () {
          expect(packet.emit).to.be.calledOnce;
          expect(packet.emit)
            .to.be.calledWith(
              'error',
              new Error('Incorrect checksum, packet discarded')
            );
        });

        test('@partialBuffer should be empty', () {
          expect(packet.partialBuffer.length).to.be.eql(0);
        });

        test('res should be null', () {
          expect(res).to.be.null;
        });
      });

      group('buffer length is less than minSizeReq', () {
        setUp(() {
          buffer = new Buffer([0xFF, 0xFF, 0x00, 0x02]);

          res = packet.parse(buffer);
        });

        test('partialBuffer should not be empty', () {
          expect(packet.partialBuffer.length).to.be.eql(4);
        });

        test('res should be null', () {
          expect(res).to.be.null;
        });
      });

      group('buffer length is less than expectedSize', () {
        setUp(() {
          buffer = new Buffer([0xFF, 0xFF, 0x00, 0x02, 0x06, 0x01, 0x02]);

          res = packet.parse(buffer);
        });

        test('partialBuffer should not be empty', () {
          expect(packet.partialBuffer.length).to.be.eql(7);
        });

        test('res should be null', () {
          expect(res).to.be.null;
        });
      });

      group('buffer length is greater than expectedSize', () {
        setUp(() {
          buffer = new Buffer(
            [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC, 0xFF, 0xFF, 0x00]
          );

          res = packet.parse(buffer);
        });

        test('partialBuffer should not be empty', () {
          expect(packet.partialBuffer.length).to.be.eql(3);
        });

        test('partialBuffer should be eql to', () {
          var tmpBuffer = new Buffer([0xFF, 0xFF, 0x00]);
          expect(packet.partialBuffer).to.be.eql(tmpBuffer);
        });

        test('res should be a packet obj', () {
          expect(res).to.not.be.null;
          expect(res).to.be.eql({
            sop1: 0xFF,
            sop2: 0xFF,
            mrsp: 0x00,
            seq: 0x02,
            dlen: 0x01,
            data: new Buffer(0),
            checksum: 0xFC,
          });
        });
      });

      group('SOPs don't pass validation', () {
        setUp(() {
          buffer = new Buffer([0xF0, 0x00, 0x02, 0x01].concat(0xFC));
        });

        group('and @partialBuffer is empty', () {
          setUp(() {
            res = packet.parse(buffer);
          });

          test('partialBuffer should not be empty', () {
            expect(packet.partialBuffer.length).to.be.eql(5);
          });

          test('res should be null', () {
            expect(res).to.be.null;
          });
        });

        group('and @partialBuffer is NOT empty', () {
          setUp(() {
            packet.partialBuffer = new Buffer([0xFF]);
            res = packet.parse(buffer);
          });

          test('partialBuffer should be empty', () {
            expect(packet.partialBuffer.length).to.be.eql(0);
          });

          test('res should be null', () {
            expect(res).to.be.null;
          });
        });
      });

      group('when partialResponse is not empty', () {
        setUp(() {
          buffer = new Buffer([0xFF, 0x00, 0x02, 0x01].concat(0xFC));
          packet.partialBuffer = new Buffer([0xFF]);

          res = packet.parse(buffer);
        });

        test('returns a packet obj when calling parse', () {
          expect(res).to.not.be.null;
          expect(res).to.be.eql({
            sop1: 0xFF,
            sop2: 0xFF,
            mrsp: 0x00,
            seq: 0x02,
            dlen: 0x01,
            data: new Buffer(0),
            checksum: 0xFC,
          });
        });

        test('packet@partialBuffer is empty', () {
          expect(packet.partialBuffer.length).to.be.eql(0);
        });
      });
    });

    group('sync response', () {
      var buffer, res, data;

      setUp(() {
        data = [0x05, 0x04, 0x03, 0x02, 0x01];
        buffer = new Buffer([0xFF, 0xFE, 0x0A, 0x00, 0x06].concat(data, 0xE0));

        res = packet.parse(buffer);
      });

      test('turns a sphero buffer response into a response obj', () {
        expect(res).to.be.an.instanceOf(Object);
      });

      test('packet res@idCode should be 0x0A', () {
        expect(res.idCode).to.be.eql(0x0A);
      });

      test('packet res@dlenMsb should be 0x00', () {
        expect(res.dlenMsb).to.be.eql(0x00);
      });

      test('packet res@dlenLsb should be 0x06', () {
        expect(res.dlenLsb).to.be.eql(0x06);
      });

      test('packet res@dlen should be 0x06', () {
        expect(res.dlen).to.be.eql(0x06);
      });

      test('packet res@checksum should be 0xFE', () {
        expect(res.checksum).to.be.eql(0xE0);
      });
    });
  });

  group('#parseResponseData', () {
    var payload;

    setUp(() {
      payload = {
        sop1: 0xFF,
        sop2: 0xFF,
        mrsp: 0x00,
        seq: 0x02,
        dlen: 0x01,
        data: new Buffer(0),
        checksum: 0xFC,
      };

      stub(packet, '_parseData');
      packet._parseData.returns({ val1: 'uno' });

      packet.parseResponseData({ did: 0x02, cid: 0x07 }, payload);
    });

    test('returns payload if cmd is not valid', () {
      var res = packet.parseResponseData({}, payload);
      expect(res).to.be.eql(payload);
    });

    test('calls #_parseData with params', () {
      var parser = {
        desc: 'Get Chassis Id',
        did: 2,
        cid: 7,
        event: 'chassisId',
        fields: [{ name: 'chassisId', type: 'number' }]
      };
      expect(packet._parseData).to.be.calledWith(parser, payload);
    });
  });

  group('#_parseData', () {
    var parser, payload;

    setUp(() {
      payload = {
        sop1: 0xFF,
        sop2: 0xFF,
        mrsp: 0x00,
        seq: 0x02,
        dlen: 0x01,
        data: new Buffer([0xff]),
        checksum: 0xFC,
      };

      parser = {
        desc: 'Get Chassis Id',
        did: 2,
        cid: 7,
        event: 'chassisId',
        fields: [{ name: 'chassisId', type: 'number' }]
      };

      stub(packet, '_checkDSMasks');
    });

    afterEach(() {
      packet._checkDSMasks.restore();
    });

    group('when dsMasks return -1', () {
      setUp(() {
        packet._checkDSMasks.returns(-1);
        packet._parseData(parser, payload);
      });

      test('calls #_checkDSMasks once', () {
        expect(packet._checkDSMasks).to.be.calledOnce;
      });

      test('returns payload inmmediately', () {
        expect(packet._parseData(parser, payload)).to.be.eql(payload);
      });
    });

    group('when dsBit returs 1', () {
      setUp(() {
        stub(packet, '_checkDSBit');
        stub(packet, '_parseField');

        packet._checkDSMasks.returns(0);
        packet._checkDSBit.returns(1);
        packet._parseField.returns(255);

        packet._parseData(parser, payload, { did: 0x02, cid: 0x07 });
      });

      afterEach(() {
        packet._checkDSBit.restore();
        packet._parseField.restore();
      });

      test('calls #_checkDSBit once', () {
        expect(packet._checkDSBit).to.be.calledOnce;
      });

      test('calls #_parseField with params', () {
        var field = parser.fields[0];
        field.from = 0;
        field.to = 2;
        expect(packet._parseField).to.be.calledOnce;
      });
    });

    group('when dsBit returs 0', () {
      setUp(() {
        stub(packet, '_incParserIndex');
        stub(packet, '_checkDSBit');
        stub(packet, '_parseField');

        packet._checkDSMasks.returns(0);
        packet._incParserIndex.returns(1);
        packet._checkDSBit.returns(0);
        packet._parseField.returns(255);

        packet._parseData(parser, payload, { did: 0x02, cid: 0x07 });
      });

      afterEach(() {
        packet._incParserIndex.restore();
        packet._checkDSBit.restore();
        packet._parseField.restore();
      });

      test('calls #_incParserIndex once with params', () {
        expect(packet._incParserIndex).to.be.calledOnce;
        expect(packet._incParserIndex)
          .to.be.calledWith(0, parser.fields, payload.data, 0, 0);
      });
    });

    group('parser is null or data length is 0', () {
      setUp(() {
        payload.data = new Buffer(0);
        spy(packet, '_parseData');
        packet._parseData(null, payload, { did: 0x02, cid: 0x07 });
      });

      test('calls #_incParserIndex once with params', () {
        expect(packet._parseData).returned(payload);
      });
    });
  });

  group('#CheckdsMasks', () {
    setUp(() {
      spy(packet, '_checkDSMasks');
    });

    afterEach(() {
      packet._checkDSMasks.restore();
    });

    test('returns null when idCode !== 0x03', () {
      packet._checkDSMasks({}, { idCode: 0x07 });
      expect(packet._checkDSMasks).to.have.returned(null);
    });

    test('returns ds obj when ds is valid and idCode == 0x03', () {
      var ds = { mask1: 0xFF00, mask2: 0x00FF };
      packet._checkDSMasks(ds, { idCode: 0x03 });
      expect(packet._checkDSMasks).to.have.returned(ds);
    });

    test('returns -1 when ds is invalid and idCode == 0x03', () {
      var ds = { mask1: 0xFF00 };
      packet._checkDSMasks(ds, { idCode: 0x03 });
      expect(packet._checkDSMasks).to.have.returned(-1);
    });
  });

  group('#_incParserIndex', () {
    setUp(() {
      spy(packet, '_incParserIndex');
    });

    afterEach(() {
      packet._incParserIndex.restore();
    });

    test('returns i++ with dsFlag < 0', () {
      packet._incParserIndex(0, [], [], -1, 0);
      expect(packet._incParserIndex).to.have.returned(1);
    });

    test('returns i++ with i < fields.length', () {
      packet._incParserIndex(0, [1, 2, 3], [4, 5, 6]);
      expect(packet._incParserIndex).to.have.returned(1);
    });

    test('returns i++ with dsIndex = data.length', () {
      packet._incParserIndex(0, [1, 2, 3], [4, 5, 6, 7], 0, 4);
      expect(packet._incParserIndex).to.have.returned(1);
    });

    test('returns i = 0 when all conditions met', () {
      packet._incParserIndex(3, [1, 2, 3, 4], [4, 5, 6, 7], 0, 2);
      expect(packet._incParserIndex).to.have.returned(0);
    });
  });

  group('checker', () {
    test('#_checksum should return 0xFC', () {
      var buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
          check = utils.checksum(buffer.slice(3, 5));
      expect(check).to.be.eql(0xFC);
    });

    test('#_checkSOPs with SOP2 0xFF should return 'sync'', () {
      var buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
          check = packet._checkSOPs(buffer);
      expect(check).to.be.eql('sync');
    });

    test('#_checkSOPs with SOP2 0xFE should return 'async'', () {
      var buffer = [0xFF, 0xFE, 0x00, 0x02, 0x01, 0xFC],
          check = packet._checkSOPs(buffer);
      expect(check).to.be.eql('async');
    });

    test('#_checkSOPs with SOP2 0xFE should return 'async'', () {
      var buffer = [0xFF, 0xFC, 0x00, 0x02, 0x01, 0xFC],
          check = packet._checkSOPs(buffer);
      expect(check).to.be.eql(false);
    });

    test('#_checkExpectedSize should return 6 when size == expected', () {
      var buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
          check = packet._checkExpectedSize(buffer);
      expect(check).to.be.eql(6);
    });

    test('#_checkExpectedSize should return -1 when size < expected', () {
      var buffer = [0xFF, 0xFC, 0x00, 0x02, 0x04, 0x02, 0x03],
          check = packet._checkExpectedSize(buffer);
      expect(check).to.be.eql(-1);
    });

    test('#_checkMinSize should return true when size >= min', () {
      var buffer = [0xFF, 0xFF, 0x00, 0x02, 0x01, 0xFC],
          check = packet._checkMinSize(buffer);
      expect(check).to.be.eql(true);
    });

    test('#_checkMinSize should return false when size < min', () {
      var buffer = [0xFF, 0xFC, 0x00, 0x02, 0x01],
          check = packet._checkMinSize(buffer);
      expect(check).to.be.eql(false);
    });
  });

  group('#checkDSBit', () {
    setUp(() {
      spy(packet, '_checkDSBit');
    });

    afterEach(() {
      packet._checkDSBit.restore();
    });

    test('returns -1 when DS is invalid', () {
      packet._checkDSBtest(null);
      expect(packet._checkDSBit).to.have.returned(-1);
    });

    test('returns 1 when DS valid and field in mask1|2', () {
      packet._checkDSBtest(
        { mask1: 0xFFFF },
        { bitmask: 0x1000, maskField: 'mask1'
      });
      expect(packet._checkDSBit).to.have.returned(1);
    });

    test('returns 0 when DS valid and field not in mask1|2', () {
      packet._checkDSBtest(
        { mask1: 0x0FFF },
        { bitmask: 0x1000, maskField: 'mask1'
      });
      expect(packet._checkDSBit).to.have.returned(0);
    });
  });

  group('#_parseField', () {
    var data, field;

    setUp(() {
      field = {
        name: 'chassisId',
        type: 'number',
      };

      data = {
        slice: stub()
      };

      data.slice.returns(new Buffer([0xFF, 0xFE, 0x00, 0x01]));
      spy(utils, 'bufferToInt');

      spy(packet, '_parseField');

      packet._parseField(field, data);
    });

    afterEach(() {
      utils.bufferToInt.restore();
    });

    test('calls data#slice', () {
      expect(data.slice).to.be.calledOnce;
      expect(data.slice).to.be.calledWith(undefined, undefined);
    });

    test('calls utils#bufferToInt', () {
      expect(utils.bufferToInt).to.be.calledOnce;
    });

    group('when field type is: ', () {
      setUp(() {
        data.slice.reset();
        utils.bufferToInt.reset();
        packet._parseField.reset();
        packet._parseField(field, [255]);
      });

      test(''number' returns the value', () {
        expect(packet._parseField).to.have.returned(255);
      });

      test(''signed' returns the signed value', () {
        field.type = 'signed';
        field.from = 0;
        field.to = 1;
        var tmpVal = packet._parseField(field, new Buffer([0xFF, 0xFE, 0x00, 0x01]));
        expect(tmpVal).to.be.eql(-1);
      });

      test(''number' returns a hex string when format == 'hex'', () {
        field.format = 'hex';
        packet._parseField(field, [255]);
        expect(packet._parseField).to.have.returned('0xFF');
        field.format = undefined;
      });

      test(''string' returns a string with format == 'ascii'', () {
        field.type = 'string';
        field.format = 'ascii';
        packet._parseField(field, new Buffer([0x48, 0x6F, 0x6C, 0x61, 0x21]));
        expect(packet._parseField).to.have.returned('Hola!');
        field.format = undefined;
      });

      test(''raw' returns the raw array', () {
        var buffer = new Buffer([0x48, 0x6F, 0x6C, 0x61, 0x21]);
        field.type = 'raw';
        var tmpVal = packet._parseField(field, buffer);
        expect(tmpVal).to.be.eql(buffer);
      });

      test(''predefined' returns 'battery OK'', () {
        var buffer = new Buffer([0x02]);
        field.type = 'predefined';
        field.values = { 0x02: 'battery OK' };
        packet._parseField(field, buffer);
        expect(packet._parseField).to.have.returned('battery OK');
        field.values = undefined;
      });

      test(''predefined' returns 'true' with mask', () {
        var buffer = new Buffer([0x0F]);
        field.type = 'predefined';
        field.mask = '0x01';
        field.values = { 0x01: true };
        packet._parseField(field, buffer);
        expect(packet._parseField).to.have.returned(true);
        field.values = undefined;
      });

      test(''bitmask' calls #_parseBotmaskField', () {
        stub(packet, '_parseBitmaskField');
        packet._parseBitmaskField.returns({ val: 'all Good' });
        field.type = 'bitmask';
        packet._parseField(field, [0x01, 0x02], { val1: 'one' });
        expect(packet._parseBitmaskField).to.be.calledOnce;
        expect(packet._parseBitmaskField)
          .to.be.calledWith(
            258, field, { val1: 'one' }
          );
        packet._parseBitmaskField.restore();
      });

      test(''bitmask' calls #_parseBotmaskField', () {
        field.type = 'thevoid';
        stub(packet, 'emit');
        packet._parseField(field, [0x01, 0x02]);
        expect(packet.emit).to.be.calledOnce;
        var error = new Error('Data could not be parsed!');
        expect(packet.emit).to.be.calledWith('error', error);
        expect(packet._parseField)
          .to.have.returned('Data could not be parsed!');
      });
    });
  });

  group('#_parseBitmaskField', () {
    var field;

    setUp(() {
      field = {
        name: 'gyro',
        sensor: 'gyro',
        units: 'gyrons',
        range: {
          top: 0x0FFF,
          bottom: -255,
        },
        value: [1]
      };

      stub(utils, 'twosToInt');
      utils.twosToInt.returns(255);
      spy(packet, '_parseBitmaskField');
    });

    afterEach(() {
      utils.twosToInt.restore();
      packet._parseBitmaskField.restore();
    });

    test(' if val > field.range.top calls utils#twosToInt', () {
      packet._parseBitmaskField(0xFF00, field, {});
      expect(utils.twosToInt).to.be.calledOnce;
      expect(utils.twosToInt).to.be.calledWith(0xFF00, 2);
    });

    test('adds to the array if field already exist', () {
      packet._parseBitmaskField(0xFE, field, { gyro: field });
      field.value.push(255);
      expect(packet._parseBitmaskField)
        .to.have.returned(field);
    });
  });
  });
}
