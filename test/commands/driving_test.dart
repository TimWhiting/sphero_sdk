import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/commands/index.dart';

void main() {
  test('Drive', () {
    final f = commandsFactory(() => 51);
    final command = f.driving.drive(100, 180, []);
    expect(command.raw, [141, 26, 18, 22, 7, 51, 100, 0, 180, 0, 107, 216]);
  });
}
