import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/utils.dart';

void main() {
  group('utils', () {
    test('randomColor', () {
      final rand = randomRGBColor();
      expect(rand, isNot(randomRGBColor()));
    });
  });
}
