import 'dart:typed_data';
import 'package:mockito/mockito.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/devices/core.dart';

void main() {
  group('Core', () {
    setUp(() {
      print('here');
    });

    group('commands', () {
      test('ping calls command with params', () async {
        // when(core.ping()).thenAnswer((realInvocation) => core.klass.ping());
        // await core.ping();

        // verify(core.baseCommand(any, any, any)).called(1);
        // final captured =
        //     verify(core.baseCommand(captureAny, captureAny, captureAny))
        //         .captured;
        // expect(captured[0], 0x00);
        // expect(captured[1], 0x01);
        // expect(captured[2], null);
      });
    });
  });
}
