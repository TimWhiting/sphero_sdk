import 'package:dartx/dartx.dart';

import 'core.dart';

class RollableToy extends Core {
  RollableToy(super.peripheral);

  /// Rolls the toy at [speed] (0 to 255) and [heading] (0 to 360) with [flags]
  Future<QueuePayload> roll(int speed, int heading, List<int> flags) =>
      queueCommand(commands.driving.drive(speed, heading, flags));

  /// Rolls the toy at [speed] (0 to 255) and [heading]
  /// (0 to 360) for [time] milliseconds with [flags]
  Future<QueuePayload> rollTime(
    int speed,
    int heading,
    int time,
    List<int> flags,
  ) async {
    var drive = true;
    Future.delayed(time.milliseconds, () => drive = false);
    while (drive) {
      await queueCommand(commands.driving.drive(speed, heading, flags));
    }
    return queueCommand(commands.driving.drive(0, heading, flags));
  }

  Future<QueuePayload> allLEDsRaw(List<int> payload) =>
      queueCommand(commands.userIO.allLEDsRaw(payload));

  /// Sets the intensity [i] (0 to 255) of the backlight LED
  Future<QueuePayload> setBackLedIntensity(int i) =>
      queueCommand(commands.userIO.setBackLedIntensity(i));

  /// Sets the intensity [i] (0 to 255) of the blue main LED
  Future<QueuePayload> setMainLedBlueIntensity(int i) =>
      queueCommand(commands.userIO.setMainLedBlueIntensity(i));

  /// Sets the color of the main LEDs with red [r] (0 to 255)
  /// green [g] (0 to 255) and blue [b] (0 to 255)
  Future<QueuePayload> setMainLedColor(int r, int g, int b) =>
      queueCommand(commands.userIO.setMainLedColor(r, g, b));

  /// Sets the intensity [i] (0 to 255) of the green main LED
  Future<QueuePayload> setMainLedGreenIntensity(int i) =>
      queueCommand(commands.userIO.setMainLedGreenIntensity(i));

  /// Sets the intensity [i] (0 to 255) of the red main LED
  Future<QueuePayload> setMainLedRedIntensity(int i) =>
      queueCommand(commands.userIO.setMainLedRedIntensity(i));
}
