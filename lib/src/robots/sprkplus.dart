const RobotControlService = '22bb746f2ba075542d6f726568705327';
const BLEService = '22bb746f2bb075542d6f726568705327';
const AntiDosCharacteristic = '22bb746f2bbd75542d6f726568705327';
const TXPowerCharacteristic = '22bb746f2bb275542d6f726568705327';
const WakeCharacteristic = '22bb746f2bbf75542d6f726568705327';
const ResponseCharacteristic = '22bb746f2ba675542d6f726568705327';
const CommandsCharacteristic = '22bb746f2ba175542d6f726568705327';

const PacketHeaderSize = 5;
const ResponsePacketMaxSize = 20;
const CollisionDataSize = 17;
const CollisionResponseSize = PacketHeaderSize + CollisionDataSize;

enum MotorModes { Off, Forward, Reverse, Brake, Ignore }

extension MotorModesX on MotorModes {
  int get asInt {
    switch (this) {
      case MotorModes.Off:
        return 0;
      case MotorModes.Forward:
        return 1;
      case MotorModes.Reverse:
        return 2;
      case MotorModes.Brake:
        return 3;
      case MotorModes.Ignore:
        return 4;
    }
  }
}

class Point2D {
  const Point2D(this.x, this.y);
  final int x;
  final int y;
}
