import 'rollable_toy.dart';
import 'types.dart';

class BB9E extends RollableToy {
  BB9E(super.peripheral);
  static const advertisement =
      ToyAdvertisement(name: 'BB-9E', prefix: 'GB-', typeof: BB9E.new);

  @override
  double get maxVoltage => 7.8;
  @override
  double get minVoltage => 6.5;
}
