import 'types.dart';

class SystemInfo {
  final CommandEncoder _encode;
  SystemInfo(CommandGenerator generator)
      : _encode = generator(DeviceId.systemInfo);
  Command appVersion() => _encode(
      CommandPartial(commandId: SystemInfoCommandIds.mainApplicationVersion));
  Command something() =>
      _encode(CommandPartial(commandId: SystemInfoCommandIds.something));
  Command something6() =>
      _encode(CommandPartial(commandId: SystemInfoCommandIds.something6));
  Command something7() =>
      _encode(CommandPartial(commandId: SystemInfoCommandIds.something7));
}
