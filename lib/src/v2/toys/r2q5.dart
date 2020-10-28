import 'core.dart';
import 'r2d2.dart';
import 'types.dart';

class R2Q5 extends R2D2 {
  R2Q5(Peripheral peripheral) : super(peripheral);
  static final advertisement =
      ToyAdvertisement(name: 'R2-Q5', prefix: 'Q5-', typeof: (p) => R2Q5(p));
}
