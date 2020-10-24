// web
// export enum ServicesUUID {
//   apiV2ControlService = '00010001-574f-4f20-5370-6865726f2121',
//   nordicDfuService = '00020001-574f-4f20-5370-6865726f2121'
// }

import 'core.dart';

class ServicesUUID {
  static String apiV2ControlService = '00010001574f4f2053706865726f2121';
  static String nordicDfuService = '00020001574f4f2053706865726f2121';
}

class CharacteristicUUID {
  static String apiV2Characteristic = '00010002574f4f2053706865726f2121';
  static String dfuControlCharacteristic = '00020002574f4f2053706865726f2121';
  static String dfuInfoCharacteristic = '00020004574f4f2053706865726f2121';
  static String antiDoSCharacteristic = '00020005574f4f2053706865726f2121';
  static String subsCharacteristic = '00020003574f4f2053706865726f2121';
}

class ToyAdvertisement {
  String name;
  String prefix;
  Core typeof;
}

class Stance {
  static int tripod = 0x01;
  static int bipod = 0x02;
}

enum APIVersion { V2, V21 }

class SensorMaskValues {
  static int off = 0;
  static int locator = 1;
  static int gyro = 2;
  static int orientation = 3;
  static int accelerometer = 4;
}

class SensorControlDefaults {
  static int intervalToHz = 1000;
  static int interval = 250;
}

class SensorMaskRaw {
  List<SensorMaskV2> v2;
  List<SensorMaskV2> v21;
}

// tslint:disable:no-bitwise
class SensorMaskV2 {
  static int off = 0;
  static int velocityY = 1 << 3;
  static int velocityX = 1 << 4;
  static int locatorY = 1 << 5;
  static int locatorX = 1 << 6;

  static int gyroZFilteredV2 = 1 << 10;
  static int gyroYFilteredV2 = 1 << 11;
  static int gyroXFilteredV2 = 1 << 12;

  static int gyroZFilteredV21 = 1 << 23;
  static int gyroYFilteredV21 = 1 << 24;
  static int gyroXFilteredV21 = 1 << 25;

  static int accelerometerZFiltered = 1 << 13;
  static int accelerometerYFiltered = 1 << 14;
  static int accelerometerXFiltered = 1 << 15;
  static int imuYawAngleFiltered = 1 << 16;
  static int imuRollAngleFiltered = 1 << 17;
  static int imuPitchAngleFiltered = 1 << 18;

  static int gyroFilteredAllV2 = SensorMaskV2.gyroZFilteredV2 |
      SensorMaskV2.gyroYFilteredV2 |
      SensorMaskV2.gyroXFilteredV2;
  static int gyroFilteredAllV21 = SensorMaskV2.gyroZFilteredV21 |
      SensorMaskV2.gyroYFilteredV21 |
      SensorMaskV2.gyroXFilteredV21;
  static int imuAnglesFilteredAll = SensorMaskV2.imuYawAngleFiltered |
      SensorMaskV2.imuRollAngleFiltered |
      SensorMaskV2.imuPitchAngleFiltered;
  static int accelerometerFilteredAll = SensorMaskV2.accelerometerZFiltered |
      SensorMaskV2.accelerometerYFiltered |
      SensorMaskV2.accelerometerXFiltered;
  static int locatorAll = SensorMaskV2.locatorX |
      SensorMaskV2.locatorY |
      SensorMaskV2.velocityX |
      SensorMaskV2.velocityY;
}
// tslint:enable:no-bitwise
