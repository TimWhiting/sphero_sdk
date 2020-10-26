import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/commands/utils.dart';

void main() {
  test('Combine flags', () {
    expect(combineFlags([1, 2]), 3);
  });
}
