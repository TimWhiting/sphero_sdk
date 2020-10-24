import 'types.dart';

class SomethingAPI {
  final CommandEncoder _encode;
  SomethingAPI(CommandGenerator generator)
      : _encode = generator(DeviceId.somethingAPI);
  Command something5() =>
      _encode(CommandPartial(commandId: SomethingApi.something5));
}
