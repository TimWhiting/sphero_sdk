import 'types.dart';

class SomethingAPI {
  SomethingAPI(CommandGenerator generator)
      : _encode = generator(DeviceId.somethingAPI);
  final CommandEncoder _encode;

  Command something5() =>
      _encode(CommandPartial(commandId: SomethingApi.something5));
}
