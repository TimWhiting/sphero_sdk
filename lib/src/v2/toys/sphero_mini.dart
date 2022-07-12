import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';

import 'core.dart';
import 'rollable_toy.dart';
import 'types.dart';

class SpheroMini extends RollableToy {
  SpheroMini(BluetoothDevice peripheral) : super(peripheral);

  static const advertisement = ToyAdvertisement(
      name: 'Sphero Mini', prefix: 'SM-', typeof: SpheroMini.new);

  @override
  double get maxVoltage => 3.65;
  @override
  double get minVoltage => 3.4;

  Future<QueuePayload> something1() =>
      queueCommand(commands.systemInfo.something());

  Future<QueuePayload> something2() =>
      queueCommand(commands.power.something2());

  Future<QueuePayload> something3() =>
      queueCommand(commands.power.something3());

  Future<QueuePayload> something4() =>
      queueCommand(commands.power.something4());

  Future<QueuePayload> something5() =>
      queueCommand(commands.somethingApi.something5());

  Future<QueuePayload> something6() =>
      queueCommand(commands.systemInfo.something6());

  Future<QueuePayload> something7() =>
      queueCommand(commands.systemInfo.something7());
}
