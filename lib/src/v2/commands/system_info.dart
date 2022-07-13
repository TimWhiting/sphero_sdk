import 'types.dart';

class SystemInfo {
  SystemInfo(CommandGenerator generator)
      : _encode = generator(DeviceId.systemInfo);
  final CommandEncoder _encode;

  Command appVersion() => _encode(
        CommandPartial(
          commandId: SystemInfoCommandIds.mainApplicationVersion,
          payload: [],
        ),
      );
  Command something() => _encode(
        CommandPartial(commandId: SystemInfoCommandIds.something, payload: []),
      );
  Command something6() => _encode(
        CommandPartial(commandId: SystemInfoCommandIds.something6, payload: []),
      );
  Command something7() => _encode(
        CommandPartial(commandId: SystemInfoCommandIds.something7, payload: []),
      );
}
