import 'core.dart';
import 'rollable_toy.dart';
import 'types.dart';

class LightningMcQueen extends RollableToy {
  LightningMcQueen(Peripheral peripheral) : super(peripheral);
  static final advertisement = ToyAdvertisement(
      name: 'Lightning McQueen',
      prefix: 'LM-',
      typeof: (p) => LightningMcQueen(p));

  Future<QueuePayload> driveAsRc(int heading, int speed) {
    final cmd = commands.driving.driveAsRc(heading, speed);
    // print(cmd.raw.map((x) => x.toString(16).padStart(2, '0')).join(':'));
    return queueCommand(cmd);
  }
}
