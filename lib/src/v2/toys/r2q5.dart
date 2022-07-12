import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';

import 'r2d2.dart';
import 'types.dart';

class R2Q5 extends R2D2 {
  R2Q5(BluetoothDevice peripheral) : super(peripheral);
  static const advertisement =
      ToyAdvertisement(name: 'R2-Q5', prefix: 'Q5-', typeof: R2Q5.new);
}
