import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v1/devices/core.dart';
import 'package:sphero_sdk/src/v1/devices/sphero.dart';

class SpheroTest extends SpheroBase {
  late int deviceId;
  late int command;
  Uint8List? data;
  @override
  Future<Map<String, dynamic>> baseCommand(
      int deviceId, int command, Uint8List? data) async {
    this.deviceId = deviceId;
    this.command = command;
    this.data = data;
    return {};
  }
}

void main() {
  group('Sphero', () {
    late SpheroTest sphero;
    setUp(() {
      sphero = SpheroTest();
    });
    test('setHeading calls command with params', () async {
      await sphero.setHeading(180);
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x01);
      expect(sphero.data, [0x00, 0xB4]);
    });

    test('setStabilization calls command with params', () async {
      await sphero.setStabilization(true);
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x02);
      expect(sphero.data, [0x01]);
    });

    test('setRotationRate calls command with params', () async {
      await sphero.setRotationRate(180);
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x03);
      expect(sphero.data, [0xB4]);
    });

    test('getChassisId calls command with params', () async {
      await sphero.getChassisId();
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x07);
      expect(sphero.data, null);
    });

    test('setChassisId calls command with params', () async {
      await sphero.setChassisId(0xB0);
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x08);
      expect(sphero.data, [0x00, 0xB0]);
    });

    test('selfLevel calls command with params', () async {
      await sphero.selfLevel(
          options: 0xF0, angleLimit: 0xB4, timeout: 0xFF, trueTime: 0x0F);
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x09);
      expect(sphero.data, [0xF0, 0xB4, 0xFF, 0x0F]);
    });

    test('setDataStreaming calls command with params', () async {
      final byteArray = [
        0x00,
        0x0F,
        0x00,
        0xF0,
        0x00,
        0x00,
        0x0F,
        0x0F,
        0x0F,
        0x00,
        0x00,
        0x00,
        0xFF
      ];

      await sphero.setDataStreaming(
        n: 0x0F,
        m: 0xF0,
        mask1: 0x0F0F,
        mask2: 0x00FF,
        pcnt: 0x0F,
      );

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x11);
      expect(sphero.data, byteArray);
    });

    test('configureCollisions calls command with params', () async {
      final byteArray = [0x0F, 0xF0, 0x01, 0x02, 0x03, 0xFF];
      await sphero.configureCollisions(
          meth: 0x0F, xt: 0xF0, xs: 0x01, yt: 0x02, ys: 0x03, dead: 0xFF);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x12);
      expect(sphero.data, byteArray);
    });

    test('configureLocator calls command with params', () async {
      final byteArray = [0x0F, 0xF0, 0xF0, 0x02, 0x02, 0xFF, 0xFF];
      await sphero.configureLocator(0x0F, 0xF0F0, 0x0202, 0xFFFF);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x13);
      expect(sphero.data, byteArray);
    });

    test('setAccelRange calls command with params', () async {
      await sphero.setAccelRange(180);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x14);
      expect(sphero.data, [0xB4]);
    });

    test('readLocator calls command with params', () async {
      await sphero.readLocator();
      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x15);
      expect(sphero.data, null);
    });

    test('setRgbLed defaults flag if not present', () async {
      final byteArray = [0xFF, 0xFE, 0xFD, 0x01];
      await sphero.setRgbLed(0xFF, 0xFE, 0xFD);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x20);
      expect(sphero.data, byteArray);
    });

    test('setRgbLed calls command with params', () async {
      final byteArray = [0xFF, 0xFE, 0xFD, 0x01];
      await sphero.setRgbLed(0xFF, 0xFE, 0xFD, 0x01);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x20);
      expect(sphero.data, byteArray);
    });

    test('setBackLed calls command with params', () async {
      await sphero.setBackLed(0xFF);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x21);
      expect(sphero.data, [0xFF]);
    });

    test('getRgbLed calls command with params', () async {
      await sphero.getRgbLed();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x22);
      expect(sphero.data, null);
    });

    test('roll calls command with params', () async {
      await sphero.roll(0xFF, 0xB4, 0x02);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x30);
      expect(sphero.data, [0xFF, 0x00, 0xB4, 0x02]);
    });

    test('roll sets state if not provided', () async {
      await sphero.roll(0xFF, 0xB4);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x30);
      expect(sphero.data, [0xFF, 0x00, 0xB4, 0x01]);
    });

    test('boost calls command with params', () async {
      await sphero.boost(true);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x31);
      expect(sphero.data, [0x01]);
    });

    test('setRawMotors calls command with params', () async {
      final byteArray = [0x03, 0xFE, 0x02, 0xFF];
      await sphero.setRawMotors(0x03, 0xFE, 0x02, 0xFF);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x33);
      expect(sphero.data, byteArray);
    });

    test('setMotionTimeout calls command with params', () async {
      await sphero.setMotionTimeout(0xAABB);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x34);
      expect(sphero.data, [0xAA, 0xBB]);
    });

    test('setPermOptionFlags calls command with params', () async {
      await sphero.setPermOptionFlags(0xAABBCCDD);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x35);
      expect(sphero.data, [0xAA, 0xBB, 0xCC, 0xDD]);
    });

    test('getPermOptionFlags calls command with params', () async {
      await sphero.getPermOptionFlags();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x36);
      expect(sphero.data, null);
    });

    test('setTempOptionFlags calls command with params', () async {
      await sphero.setTempOptionFlags(0xAABBCCDD);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x37);
      expect(sphero.data, [0xAA, 0xBB, 0xCC, 0xDD]);
    });

    test('getTempOptionFlags calls command with params', () async {
      await sphero.getTempOptionFlags();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x38);
      expect(sphero.data, null);
    });

    test('getConfigBlock calls command with params', () async {
      await sphero.getConfigBlock(0xB4);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x40);
      expect(sphero.data, [0xB4]);
    });

    test('setSsbModBlock calls command with params', () async {
      await sphero.setSsbModBlock(0xAABBCCDD,
          Uint8List.fromList(Uint8List.fromList([0x01, 0x02, 0x03])));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x41);
      expect(sphero.data, [0xAA, 0xBB, 0xCC, 0xDD, 0x01, 0x02, 0x03]);
    });

    test('setDeviceMode calls command with params', () async {
      await sphero.setDeviceMode(false);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x42);
      expect(sphero.data, [0x00]);
    });

    test('setConfigBlock calls command with params', () async {
      await sphero.setConfigBlock(Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x43);
      expect(sphero.data, [0x01, 0x02, 0x03]);
    });

    test('getDeviceMode calls command with params', () async {
      await sphero.getDeviceMode();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x44);
      expect(sphero.data, null);
    });

    test('getSsb calls command with params', () async {
      await sphero.getSsb();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x46);
      expect(sphero.data, null);
    });

    test('setSsb calls command with params', () async {
      await sphero.setSsb(0xAABBCCDD, Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x47);
      expect(sphero.data, [0xAA, 0xBB, 0xCC, 0xDD, 0x01, 0x02, 0x03]);
    });

    test('refillBank calls command with params', () async {
      await sphero.refillBank(0xAA);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x48);
      expect(sphero.data, [0xAA]);
    });

    test('buyConsumable calls command with params', () async {
      await sphero.buyConsumable(0xCC, 0x0F);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x49);
      expect(sphero.data, [0xCC, 0x0F]);
    });

    test('useConsumable calls command with params', () async {
      await sphero.useConsumable(0xCC);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4A);
      expect(sphero.data, [0xCC]);
    });

    test('grantCores calls command with params', () async {
      await sphero.grantCores(0xAA, 0xBB, 0xCC);
      final byteArray = [0x00, 0x00, 0x00, 0xAA, 0x00, 0x00, 0x00, 0xBB, 0xCC];

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4B);
      expect(sphero.data, byteArray);
    });

    test('addXp calls command with params', () async {
      await sphero.addXp(0xCC, 0xFF);
      final byteArray = [0x00, 0x00, 0x00, 0xCC, 0xFF];

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4C);
      expect(sphero.data, byteArray);
    });

    test('levelUpAttr calls command with params', () async {
      await sphero.levelUpAttr(0xCC, 0xFF);
      final byteArray = [0x00, 0x00, 0x00, 0xCC, 0xFF];

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4D);
      expect(sphero.data, byteArray);
    });

    test('getPasswordSeed calls command with params', () async {
      await sphero.getPasswordSeed();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4E);
      expect(sphero.data, null);
    });

    test('enableSsbAsyncMsg calls command with params', () async {
      await sphero.enableSsbAsyncMsg(true);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x4F);
      expect(sphero.data, [0x01]);
    });

    test('runMacro calls command with params', () async {
      await sphero.runMacro(0x0F);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x50);
      expect(sphero.data, [0x0F]);
    });

    test('saveTempMacro calls command with params', () async {
      await sphero.saveTempMacro(Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x51);
      expect(sphero.data, [0x01, 0x02, 0x03]);
    });

    test('saveMacro calls command with params', () async {
      await sphero.saveMacro(Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x52);
      expect(sphero.data, [0x01, 0x02, 0x03]);
    });

    test('reInitMacroExec calls command with params', () async {
      await sphero.reInitMacroExec();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x54);
      expect(sphero.data, null);
    });

    test('abortMacro calls command with params', () async {
      await sphero.abortMacro();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x55);
      expect(sphero.data, null);
    });

    test('getMacroStatus calls command with params', () async {
      await sphero.getMacroStatus();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x56);
      expect(sphero.data, null);
    });

    test('setMacroParam calls command with params', () async {
      await sphero.setMacroParam(0x01, 0x02, 0x03);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x57);
      expect(sphero.data, [0x01, 0x02, 0x03]);
    });

    test('appendMacroChunk calls command with params', () async {
      await sphero.appendMacroChunk(Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x58);
      expect(sphero.data, [0x01, 0x02, 0x03]);
    });

    test('eraseOrbBasicStorage calls command with params', () async {
      await sphero.eraseOrbBasicStorage(0x0F);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x60);
      expect(sphero.data, [0x0F]);
    });

    test('appendOrbBasicFragment calls command with params', () async {
      await sphero.appendOrbBasicFragment(
          0x0F, Uint8List.fromList([0x01, 0x02, 0x03]));

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x61);
      expect(sphero.data, [0x0F, 0x01, 0x02, 0x03]);
    });

    test('executeOrbBasicProgram calls command with params', () async {
      await sphero.executeOrbBasicProgram(0x0F, 0x0F, 0x0B);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x62);
      expect(sphero.data, [0x0F, 0x0F, 0x0B]);
    });

    test('abortOrbBasicProgram calls command with params', () async {
      await sphero.abortOrbBasicProgram();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x63);
      expect(sphero.data, null);
    });

    test('submitValueToInput calls command with params', () async {
      await sphero.submitValueToInput(0x0F);

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x64);
      expect(sphero.data, [0x00, 0x00, 0x00, 0x0F]);
    });

    test('commitToFlash calls command with params', () async {
      await sphero.commitToFlash();

      expect(sphero.deviceId, 0x02);
      expect(sphero.command, 0x65);
      expect(sphero.data, null);
    });
  });
}
