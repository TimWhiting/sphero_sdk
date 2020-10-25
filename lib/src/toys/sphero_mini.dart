import 'package:sphero_sdk/src/toys/types.dart';

import 'core.dart';
import 'rollable_toy.dart';

class SpheroMini extends RollableToy {
  static final advertisement = ToyAdvertisement(
      name: 'Sphero Mini', prefix: 'SM-', typeof: (p) => SpheroMini(p));

  double maxVoltage = 3.65;
  double minVoltage = 3.4;

  SpheroMini(Peripheral peripheral) : super(peripheral);

  Future<QueuePayload> something1() {
    return queueCommand(commands.systemInfo.something());
  }

  Future<QueuePayload> something2() {
    return queueCommand(commands.power.something2());
  }

  Future<QueuePayload> something3() {
    return queueCommand(commands.power.something3());
  }

  Future<QueuePayload> something4() {
    return queueCommand(commands.power.something4());
  }

  Future<QueuePayload> something5() {
    return queueCommand(commands.somethingApi.something5());
  }

  Future<QueuePayload> something6() {
    return queueCommand(commands.systemInfo.something6());
  }

  Future<QueuePayload> something7() {
    return queueCommand(commands.systemInfo.something7());
  }
}
