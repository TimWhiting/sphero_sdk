import 'types.dart';
import 'utils.dart';

List<int> encodeNumberLM(int n) {
  final absN = (n * 3968).abs();
  var nFirstHalfByte1 = n == 0
      ? 0
      : n > 0
          ? 0x30
          : 0xb0;

  final nSecondHalfByte1 = (absN >> 8) & 0x0f;

  return [
    nFirstHalfByte1 | nSecondHalfByte1,
    absN & 0xff,
    (0 >> 8) & 0xff,
    0 & 0xff
  ];
}

class Driving {
  final CommandEncoder _encode;
  Driving(CommandGenerator generator) : _encode = generator(DeviceId.driving);
  Command drive(
    int speed,
    int heading,
    List<int> flags,
  ) =>
      _encode(CommandPartial(
          commandId: DrivingCommandIds.driveWithHeading,
          targetId: 0x12,
          payload: [
            speed,
            (heading >> 8) & 0xff,
            heading & 0xff,
            combineFlags(flags)
          ]));
  Command driveAsRc(int heading, int speed) => _encode(CommandPartial(
      // Value: 8d 08 16 02 8b bf 72 93 de 00 00 00 00 b2 d8
      commandId: DrivingCommandIds.driveAsRc,
      payload: [...encodeNumberLM(heading), ...encodeNumberLM(speed)]));
}
