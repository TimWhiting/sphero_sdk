import 'types.dart';

class Power {
  Power(CommandGenerator generator) : _encode = generator(DeviceId.powerInfo);

  final CommandEncoder _encode;
  Command batteryVoltage() => _encode(CommandPartial(
      targetId: 0x11, commandId: PowerCommandIds.batteryVoltage));
  Command sleep() =>
      _encode(CommandPartial(targetId: 0x11, commandId: PowerCommandIds.sleep));
  Command something2() =>
      _encode(CommandPartial(commandId: PowerCommandIds.something2));
  Command something3() =>
      _encode(CommandPartial(commandId: PowerCommandIds.something3));
  Command something4() =>
      _encode(CommandPartial(commandId: PowerCommandIds.something4));
  Command wake() =>
      _encode(CommandPartial(targetId: 0x11, commandId: PowerCommandIds.wake));
}
