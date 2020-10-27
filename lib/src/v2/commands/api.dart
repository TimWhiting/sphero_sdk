import 'types.dart';

class API {
  final CommandEncoder _encode;
  API(CommandGenerator generator) : _encode = generator(DeviceId.apiProcessor);
  Command echo() =>
      _encode(CommandPartial(commandId: APIProcessCommandIds.echo));
}
