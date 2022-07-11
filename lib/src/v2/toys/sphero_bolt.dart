import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';

import 'rollable_toy.dart';
import 'types.dart';

class SpheroBolt extends RollableToy {
  SpheroBolt(BluetoothDevice peripheral) : super(peripheral);
  static final advertisement = ToyAdvertisement(
      name: 'Sphero Bolt', prefix: 'SB-', typeof: (p) => SpheroBolt(p));

  @override
  double get maxVoltage => 3.9;
  @override
  double get minVoltage => 3.55;
  @override
  APIVersion get apiVersion => APIVersion.V21;
}
