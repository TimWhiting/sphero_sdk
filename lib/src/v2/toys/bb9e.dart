import 'core.dart';
import 'rollable_toy.dart';
import 'types.dart';

class BB9E extends RollableToy {
  BB9E(Peripheral peripheral) : super(peripheral);
  static final advertisement =
      ToyAdvertisement(name: 'BB-9E', prefix: 'GB-', typeof: (p) => BB9E(p));

  @override
  double get maxVoltage => 7.8;
  @override
  double get minVoltage => 6.5;
}
