import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/utils.dart';

void main() {
  group('utils', () {
    test('randomColor', () {
      final rand = randomRGBColor();
      expect(rand, isNot(randomRGBColor()));
    });
    test('rgbToHex', () {
      expect(rgbToHex(0, 0, 128), equals(0x000080));
      expect(rgbToHex(200, 10, 25), equals(0xC80A19));
    });

    test('checksum', () {
      expect('testing123'.asUint8List.checksum, equals(0x6b));
      expect('another buffer'.asUint8List.checksum, equals(0x74));
    });

    test('intToHexArray', () {
      expect(1.toHexArray(1), equals([0x01]));
      expect(255.toHexArray(1), equals([0xFF]));
      expect(256.toHexArray(1), equals([0x00]));
      expect(256.toHexArray(2), equals([0x01, 0x00]));
      expect(255.toHexArray(2), equals([0x00, 0xFF]));
      expect(257.toHexArray(2), equals([0x01, 0x01]));
      expect(256.toHexArray(4), equals([0x00, 0x00, 0x01, 0x00]));
      expect(257.toHexArray(4), equals([0x00, 0x00, 0x01, 0x01]));
      expect(65535.toHexArray(4), equals([0x00, 0x00, 0xFF, 0xFF]));
      expect(65535.toHexArray(2), equals([0xFF, 0xFF]));
    });

    test('twosToInt', () {
      expect(twosToInt(0x9828), equals(-26584));
      expect(twosToInt(0xCED8), equals(-12584));
    });

    test('xor32bit', () {
      var tmpVal = xor32bit(0xFF00F0F0).toHexArray(4);
      expect(tmpVal, equals([0, 255, 15, 15]));
      tmpVal = xor32bit(0x00FF00FF).toHexArray(4);
      expect(tmpVal, equals([255, 0, 255, 0]));
    });
  });
}
