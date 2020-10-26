import 'package:sphero_sdk/src/toys/core.dart';
import 'package:sphero_sdk/src/toys/types.dart';

import 'rollable_toy.dart';

class SpheroBolt extends RollableToy {
  static final advertisement = ToyAdvertisement(
      name: 'Sphero Bolt', prefix: 'SB-', typeof: (p) => SpheroBolt(p));

  @override
  double maxVoltage = 3.9;
  @override
  double minVoltage = 3.55;
  @override
  APIVersion apiVersion = APIVersion.V21;

  SpheroBolt(Peripheral peripheral) : super(peripheral);
}