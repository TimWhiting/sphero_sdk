import 'core.dart';
import 'rollable_toy.dart';
import 'types.dart';

class BB9E extends RollableToy {
  static final advertisement =
      ToyAdvertisement(name: 'BB-9E', prefix: 'GB-', typeof: (p) => BB9E(p));

  double maxVoltage = 7.8;
  double minVoltage = 6.5;

  BB9E(Peripheral peripheral) : super(peripheral);
}
