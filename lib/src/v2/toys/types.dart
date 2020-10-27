import 'package:flutter/foundation.dart';

import 'core.dart';

class ServicesUUID {
  static const String apiV2ControlService = '00010001574f4f2053706865726f2121';
  static const String nordicDfuService = '00020001574f4f2053706865726f2121';
}

class CharacteristicUUID {
  static const String apiV2Characteristic = '00010002574f4f2053706865726f2121';
  static const String dfuControlCharacteristic =
      '00020002574f4f2053706865726f2121';
  static const String dfuInfoCharacteristic =
      '00020004574f4f2053706865726f2121';
  static const String antiDoSCharacteristic =
      '00020005574f4f2053706865726f2121';
  static const String subsCharacteristic = '00020003574f4f2053706865726f2121';
}

class ToyAdvertisement {
  final String name;
  final String prefix;
  final Core Function(Peripheral) typeof;
  const ToyAdvertisement(
      {@required this.name, @required this.prefix, @required this.typeof});
}

class Stance {
  static const int tripod = 0x01;
  static const int bipod = 0x02;
}

enum APIVersion { V2, V21 }

class SensorMaskValues {
  static const int off = 0;
  static const int locator = 1;
  static const int gyro = 2;
  static const int orientation = 3;
  static const int accelerometer = 4;
}

class SensorControlDefaults {
  static const int intervalToHz = 1000;
  static const int interval = 250;
}

class SensorMaskRaw {
  SensorMaskRaw({this.v2, this.v21});
  List<int> v2;
  List<int> v21;
}

class SensorMaskV2 {
  static const int off = 0;
  static const int velocityY = 1 << 3;
  static const int velocityX = 1 << 4;
  static const int locatorY = 1 << 5;
  static const int locatorX = 1 << 6;

  static const int gyroZFilteredV2 = 1 << 10;
  static const int gyroYFilteredV2 = 1 << 11;
  static const int gyroXFilteredV2 = 1 << 12;

  static const int gyroZFilteredV21 = 1 << 23;
  static const int gyroYFilteredV21 = 1 << 24;
  static const int gyroXFilteredV21 = 1 << 25;

  static const int accelerometerZFiltered = 1 << 13;
  static const int accelerometerYFiltered = 1 << 14;
  static const int accelerometerXFiltered = 1 << 15;
  static const int imuYawAngleFiltered = 1 << 16;
  static const int imuRollAngleFiltered = 1 << 17;
  static const int imuPitchAngleFiltered = 1 << 18;

  static const int gyroFilteredAllV2 = SensorMaskV2.gyroZFilteredV2 |
      SensorMaskV2.gyroYFilteredV2 |
      SensorMaskV2.gyroXFilteredV2;
  static const int gyroFilteredAllV21 = SensorMaskV2.gyroZFilteredV21 |
      SensorMaskV2.gyroYFilteredV21 |
      SensorMaskV2.gyroXFilteredV21;
  static const int imuAnglesFilteredAll = SensorMaskV2.imuYawAngleFiltered |
      SensorMaskV2.imuRollAngleFiltered |
      SensorMaskV2.imuPitchAngleFiltered;
  static const int accelerometerFilteredAll =
      SensorMaskV2.accelerometerZFiltered |
          SensorMaskV2.accelerometerYFiltered |
          SensorMaskV2.accelerometerXFiltered;
  static const int locatorAll = SensorMaskV2.locatorX |
      SensorMaskV2.locatorY |
      SensorMaskV2.velocityX |
      SensorMaskV2.velocityY;
}
