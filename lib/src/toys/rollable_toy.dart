import 'package:dartx/dartx.dart';
import 'core.dart';

class RollableToy extends Core {
  RollableToy(Peripheral peripheral) : super(peripheral);

  /**
   * Rolls the toy
   * @param  speed   speed to roll the toy (0 to 255)
   * @param  heading heading in degrees (0 to 360)
   * @param  flags   [description]
   * @return         [description]
   */
  Future<QueuePayload> roll(int speed, int heading, List<int> flags) {
    return queueCommand(commands.driving.drive(speed, heading, flags));
  }

  /**
   * Rolls the toy
   * @param  speed   speed to roll the toy (0 to 255)
   * @param  heading heading in degrees (0 to 360)
   * @param  time    time to roll in milliseconds
   * @param  flags   [description]
   * @return         [description]
   */
  Future<QueuePayload> rollTime(
      int speed, int heading, int time, List<int> flags) async {
    var drive = true;
    Future.delayed(time.milliseconds, () => (drive = false));
    while (drive) {
      await queueCommand(commands.driving.drive(speed, heading, flags));
    }
    await queueCommand(commands.driving.drive(0, heading, flags));
  }

  Future<QueuePayload> allLEDsRaw(List<int> payload) {
    return queueCommand(commands.userIO.allLEDsRaw(payload));
  }

  /**
   * Sets the intensity of the backlight LED
   * @param  i intensity (0 to 255)
   */
  Future<QueuePayload> setBackLedIntensity(int i) {
    return queueCommand(commands.userIO.setBackLedIntensity(i));
  }

  /**
   * Sets the intensity of the blue main LED
   * @param  i intensity (0 to 255)
   */
  Future<QueuePayload> setMainLedBlueIntensity(int i) {
    return queueCommand(commands.userIO.setMainLedBlueIntensity(i));
  }

  /**
   * Sets the color of the main LEDs
   * @param  r intensity of the red LED (0 to 255)
   * @param  g intensity of the green LED (0 to 255)
   * @param  b intensity of the blue LED (0 to 255)
   * @return   [description]
   */
  Future<QueuePayload> setMainLedColor(int r, int g, int b) {
    return queueCommand(commands.userIO.setMainLedColor(r, g, b));
  }

  /**
   * Sets the intensity of the green main LED
   * @param  i intensity (0 to 255)
   */
  Future<QueuePayload> setMainLedGreenIntensity(int i) {
    return queueCommand(commands.userIO.setMainLedGreenIntensity(i));
  }

  /**
   * Sets the intensity of the red main LED
   * @param  i intensity (0 to 255)
   */
  Future<QueuePayload> setMainLedRedIntensity(int i) {
    return queueCommand(commands.userIO.setMainLedRedIntensity(i));
  }
}
