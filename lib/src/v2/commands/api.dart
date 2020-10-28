import 'types.dart';

class API {
  API(CommandGenerator generator) : _encode = generator(DeviceId.apiProcessor);

  final CommandEncoder _encode;
  Command echo() =>
      _encode(CommandPartial(commandId: APIProcessCommandIds.echo));
}
