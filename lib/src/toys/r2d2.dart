import 'dart:typed_data';

import 'core.dart';
import 'rollable_toy.dart';
import 'types.dart';

class R2D2 extends RollableToy {
  static final advertisement =
      ToyAdvertisement(name: 'R2-D2', prefix: 'D2-', typeof: (p) => R2D2(p));

  double maxVoltage = 3.65;
  double minVoltage = 3.4;

  R2D2(Peripheral peripheral) : super(peripheral);

  Future<QueuePayload> wake() {
    return queueCommand(commands.power.wake());
  }

  Future<QueuePayload> sleep() {
    return queueCommand(commands.power.sleep());
  }

  Future<QueuePayload> playAudioFile(int idx) {
    return queueCommand(commands.userIO.playAudioFile(idx));
  }

  Future<QueuePayload> turnDome(int angle) {
    final res = calculateDomeAngle(angle);
    return queueCommand(commands.userIO.turnDome(res));
  }

  Future<QueuePayload> setStance(int stance) {
    return queueCommand(commands.userIO.setStance(stance));
  }

  Future<QueuePayload> playAnimation(int animation) {
    return queueCommand(commands.userIO.playAnimation(animation));
  }

  Future<QueuePayload> setR2D2LEDColor(int r, int g, int b) {
    return queueCommand(commands.userIO.setR2D2LEDColor(r, g, b));
  }

  Future<QueuePayload> setR2D2FrontLEDColor(int r, int g, int b) {
    return queueCommand(commands.userIO.setR2D2FrontLEDColor(r, g, b));
  }

  Future<QueuePayload> setR2D2BackLEDcolor(int r, int g, int b) {
    return queueCommand(commands.userIO.setR2D2BackLEDcolor(r, g, b));
  }

  Future<QueuePayload> setR2D2LogicDisplaysIntensity(int i) {
    return queueCommand(commands.userIO.setR2D2LogicDisplaysIntensity(i));
  }

  Future<QueuePayload> setR2D2HoloProjectorIntensity(int i) {
    return queueCommand(commands.userIO.setR2D2HoloProjectorIntensity(i));
  }

  Future<QueuePayload> startIdleLedAnimation() {
    return queueCommand(commands.userIO.startIdleLedAnimation());
  }

  Future<QueuePayload> playR2D2Sound(int hex1, int hex2) {
    return queueCommand(commands.userIO.playR2D2Sound(hex1, hex2));
  }

  Future<QueuePayload> setAudioVolume(int vol) {
    return queueCommand(commands.userIO.setAudioVolume(vol));
  }

  // TODO: Refractor this and simplify
  /// utility calculation for dome rotation
  Uint8List calculateDomeAngle(int angle) {
    final result = Uint8List(2);
    switch (angle) {
      case -1:
        result[0] = 0xbf;
        result[1] = 0x80;
        return result;
      case 0:
        result[0] = 0x00;
        result[1] = 0x00;
        return result;
      case 1:
        result[0] = 0x3f;
        result[1] = 0x80;
        return result;
    }
    var uAngle = angle.abs();
    final hob = R2D2.hobIndex(uAngle);
    final unshift = 8 - hob < 6 ? 8 - hob : 6;
    final shift = 6 - unshift;

    uAngle = uAngle << unshift;
    if (angle < 0) {
      uAngle = 0x8000 | uAngle;
    }

    uAngle = 0x4000 | uAngle;

    final flagA = (0x04 & shift) >> 2;

    final flagB = (0x02 & shift) >> 1;

    final flagC = 0x01 & shift;
    if (flagA == 1) {
      uAngle |= 1 << 9;
    } else {
      uAngle &= uAngle ^ (1 << 9);
    }

    if (flagB == 1) {
      uAngle |= 1 << 8;
    } else {
      uAngle &= uAngle ^ (1 << 8);
    }

    if (flagC == 1) {
      uAngle |= 1 << 7;
    } else {
      uAngle &= uAngle ^ (1 << 7);
    }

    result[0] = 0x00ff & uAngle;

    result[1] = (0xff00 & uAngle) >> 8;

    return result;
  }

  static hobIndex(int val) {
    final values = Uint16List(2);
    values[1] = 0;
    values[0] = val;
    while (values[0] > 0) {
      values[0] = values[0] >> 1;
      values[1] = values[1] + 1;
    }
    return values[1];
  }
}
