import 'types.dart';

class Sensor {
  final CommandEncoder _encode;
  Sensor(CommandGenerator generator) : _encode = generator(DeviceId.sensor);
  Command enableCollisionAsync() =>
      _encode(CommandPartial(commandId: SensorCommandIds.enableCollisionAsync));

  /**
     * @param  {number} xThreshold An 8-bit settable threshold for the X (left/right)
     * and Y (front/back) axes of Sphero. A value of 00h disables the contribution of that axis.
     * @param  {number} yThreshold An 8-bit settable threshold for the X (left/right)
     * and Y (front/back) axes of Sphero. A value of 00h disables the contribution of that axis.
     * @param  {number} xSpeed An 8-bit settable speed value for the X and Y axes.
     * This setting is ranged by the speed, then added to Xt, Yt to generate the final threshold value.
     * @param  {number} ySpeed An 8-bit settable speed value for the X and Y axes.
     * This setting is ranged by the speed, then added to Xt, Yt to generate the final threshold value.
     * @param  {number} deadTime An 8-bit post-collision dead time to prevent retriggering; specified in 10ms increments.
     * @param  {number=0x01} method Detection method type to use. Currently the only method
     * supported is 01h. Use 00h to completely disable this service.
     */
  Command configureCollision(
          int xThreshold, int yThreshold, int xSpeed, int ySpeed, int deadTime,
          {int method = 0x01}) =>
      _encode(CommandPartial(
          commandId: SensorCommandIds.configureCollision,
          targetId: 0x12,
          payload: [method, xThreshold, xSpeed, yThreshold, ySpeed, deadTime]));

  Command sensorMask(int sensorRawValue, int streamingRate) {
    final bytes = [
      (streamingRate >> 8) & 0xff,
      streamingRate & 0xff,
      0,
      (sensorRawValue >> 24) & 0xff,
      (sensorRawValue >> 16) & 0xff,
      (sensorRawValue >> 8) & 0xff,
      sensorRawValue & 0xff
    ];
    return _encode(CommandPartial(
        commandId: SensorCommandIds.sensorMask,
        targetId: 0x12,
        payload: bytes));
  }

  Command sensorMaskExtended(int mask) {
    final bytes = [
      (mask >> 24) & 0xff,
      (mask >> 16) & 0xff,
      (mask >> 8) & 0xff,
      mask & 0xff
    ];
    return _encode(CommandPartial(
        commandId: SensorCommandIds.sensorMaskExtended,
        targetId: 0x12,
        payload: bytes));
  }
}
