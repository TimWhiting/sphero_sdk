import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/devices/core.dart';

class SpheroTest extends SpheroBase {
  late int deviceId;
  late int command;
  Uint8List? data;
  @override
  Future<Map<String, Object?>> baseCommand(
    int deviceId,
    int command,
    Uint8List? data,
  ) async {
    this.deviceId = deviceId;
    this.command = command;
    this.data = data;
    return <String, Object?>{};
  }
}

void main() {
  group('Core', () {
    late SpheroTest core;
    setUp(() {
      core = SpheroTest();
    });

    group('commands', () {
      test('ping calls command with params', () async {
        await core.ping();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x01);
        expect(core.data, null);
      });

      test('version calls command with params', () async {
        await core.version();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x02);
        expect(core.data, null);
      });

      test('controlUartTx calls command with params', () async {
        await core.controlUartTX();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x03);
        expect(core.data, null);
      });

      test('setDeviceName calls command with params', () async {
        await core.setDeviceName('Esfiro');
        expect(core.deviceId, 0x00);
        expect(core.command, 0x10);
        expect(core.data, [69, 115, 102, 105, 114, 111]);
      });

      test('getBluetoothInfo calls command with params', () async {
        await core.getBluetoothInfo();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x11);
        expect(core.data, null);
      });

      test('setAutoReconnect calls command with params', () async {
        await core.setAutoReconnect(true, 0x05);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x12);
        expect(core.data, [0x01, 0x05]);
      });

      test('getAutoReconnect calls command with params', () async {
        await core.getAutoReconnect();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x13);
        expect(core.data, null);
      });

      test('getPowerState calls command with params', () async {
        await core.getPowerState();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x20);
        expect(core.data, null);
      });

      test('setPowerNotification calls command with params', () async {
        await core.setPowerNotification(true);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x21);
        expect(core.data, [0x01]);
      });

      test('sleep calls command with params', () async {
        await core.sleep(256, 255, 256);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x22);
        expect(core.data, [0x01, 0x00, 0xFF, 0x01, 0x00]);
      });

      test('getVoltageTripPoints calls command with params', () async {
        await core.getVoltageTripPoints();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x23);
        expect(core.data, null);
      });

      test('setVoltageTripPoints calls command with params', () async {
        await core.setVoltageTripPoints(0xFF00, 0x00FF);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x24);
        expect(core.data, [0xFF, 0x00, 0x00, 0xFF]);
      });

      test('setInactiveTimeout calls command with params', () async {
        await core.setInactivityTimeout(0x0F);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x25);
        expect(core.data, [0x00, 0x0F]);
      });

      test('jumpToBootloader calls command with params', () async {
        await core.jumpToBootloader();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x30);
        expect(core.data, null);
      });

      test('runL1Diags calls command with params', () async {
        await core.runL1Diag();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x40);
        expect(core.data, null);
      });

      test('runL2Diags calls command with params', () async {
        await core.runL2Diag();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x41);
        expect(core.data, null);
      });

      test('clearCounters calls command with params', () async {
        await core.clearCounters();
        expect(core.deviceId, 0x00);
        expect(core.command, 0x42);
        expect(core.data, null);
      });

      test('assignTime calls _coreTimeCmd with params', () async {
        await core.assignTime(0xFF);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x50);
        expect(core.data, [0x00, 0x00, 0x00, 0xFF]);
      });

      test('pollPacketTimes calls _coreTimeCmd with params', () async {
        await core.pollPacketTimes(0xFF);
        expect(core.deviceId, 0x00);
        expect(core.command, 0x51);
        expect(core.data, [0x00, 0x00, 0x00, 0xFF]);
      });
    });
  });
}
