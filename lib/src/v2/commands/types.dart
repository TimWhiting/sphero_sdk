import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'encoder.dart';
part 'types.freezed.dart';

// TODO: Make some things enums and have extensions to get the int values
class DeviceId {
  static const int apiProcessor = 0x10;
  static const int systemInfo = 0x11;
  static const int powerInfo = 0x13;
  static const int driving = 0x16;
  static const int animatronics = 0x17;
  static const int sensor = 0x18;
  static const int userIO = 0x1a;
  static const int somethingAPI = 0x1f;
}

class SomethingApi {
  static const int something5 = 0x27;
}

class APIProcessCommandIds {
  static const int echo = 0x00;
}

class SystemInfoCommandIds {
  static const int mainApplicationVersion = 0x00;
  static const int bootloaderVersion = 0x01;
  static const int something = 0x06;
  static const int something6 = 0x12;
  static const int something7 = 0x28;
}

class PowerCommandIds {
  static const int deepSleep = 0x00;
  static const int sleep = 0x01;
  static const int batteryVoltage = 0x03;
  static const int wake = 0x0d;
  static const int something2 = 0x10; // every x time
  static const int something3 = 0x04; // every x time
  static const int something4 = 0x1e;
}

class DrivingCommandIds {
  static const int rawMotor = 0x01;
  static const int resetYaw = 0x06;
  static const int driveAsSphero = 0x04;
  static const int driveAsRc = 0x02;
  static const int driveWithHeading = 0x07;
  static const int stabilization = 0x0c;
}

class AnimatronicsCommandIds {
  static const int animationBundle = 0x05;
  static const int shoulderAction = 0x0d;
  static const int domePosition = 0x0f;
  static const int shoulderActionComplete = 0x26;
  static const int enableShoulderActionCompleteAsync = 0x2a;
}

class SensorCommandIds {
  static const int sensorMask = 0x00;
  static const int sensorResponse = 0x02;
  static const int configureCollision = 0x11;
  static const int collisionDetectedAsync = 0x12;
  static const int resetLocator = 0x13;
  static const int enableCollisionAsync = 0x14;
  static const int sensor1 = 0x0f;
  static const int sensor2 = 0x17;
  static const int sensorMaskExtended = 0x0c;
}

class UserIOCommandIds {
  static const int allLEDs = 0x0e;
  static const int allLEDsV21 = 0x1c;
  static const int playAudioFile = 0x07;
  static const int audioVolume = 0x08;
  static const int stopAudio = 0xa;
  static const int testSound = 0x18;
  static const int startIdleLedAnimation = 0x19;
  static const int matrixPixel = 0x2d;
  static const int matrixColor = 0x2f;
  static const int clearMatrix = 0x38;
  static const int matrixRotation = 0x3a;
  static const int matrixScrollText = 0x3b;
  static const int matrixLine = 0x3d;
  static const int matrixFill = 0x3e;
}

class Flags {
  static const int isResponse = 1;
  static const int requestsResponse = 2;
  static const int requestsOnlyErrorResponse = 4;
  static const int resetsInactivityTimeout = 8;
  static const int commandHasTargetId = 16;
  static const int commandHasSourceId = 32;
}

class APIConstants {
  static const int escape = 0xab;
  static const int startOfPacket = 0x8d;
  static const int endOfPacket = 0xd8;
  static const int escapeMask = 0x88;
  static const int escapedEscape =
      APIConstants.escape & ~APIConstants.escapeMask;
  static const int escapedStartOfPacket =
      APIConstants.startOfPacket & ~APIConstants.escapeMask;
  static const int escapedEndOfPacket =
      APIConstants.endOfPacket & ~APIConstants.escapeMask;
}

class DriveFlag {
  static const int reverse = 0x01;
  static const int boost = 0x02;
  static const int fastTurnMode = 2 << 1;
  static const int tankDriveLeftMotorReverse = 2 << 2;
  static const int tankDriveRightMotorReverse = 2 << 3;
}

class AllFlags {
  AllFlags({
    this.isResponse,
    this.requestsResponse,
    this.requestsOnlyErrorResponse,
    this.resetsInactivityTimeout,
    this.commandHasTargetId,
    this.commandHasSourceId,
  });
  final bool isResponse;
  final bool requestsResponse;
  final bool requestsOnlyErrorResponse;
  final bool resetsInactivityTimeout;
  final bool commandHasTargetId;
  final bool commandHasSourceId;
}

enum CommandId {
  UserIOCommandIds,
  AnimatronicsCommandIds,
  DrivingCommandIds,
  PowerCommandIds,
  SystemInfoCommandIds,
  APIProcessCommandIds,
  SensorCommandIds,
  SomethingApi
}

class CommandOutput {
  CommandOutput({this.bytes, this.checksum});
  final List<int> bytes;
  int checksum;
}

class CommandPartial {
  CommandPartial({
    this.commandId,
    this.payload,
    this.targetId,
    this.sourceId,
  });
  List<int> payload;
  final int commandId;
  int targetId;
  int sourceId;
}

class Command extends CommandPartial {
  Command({
    List<int> payload,
    int commandId,
    int targetId,
    int sourceId,
    this.deviceId,
    this.commandFlags,
    this.sequenceNumber,
  }) : super(
          payload: payload,
          commandId: commandId,
          targetId: targetId,
          sourceId: sourceId,
        );
  Command.fromPart({
    CommandPartial part,
    this.deviceId,
    this.commandFlags,
    this.sequenceNumber,
  }) : super(
          commandId: part.commandId,
          payload: part.payload,
          targetId: part.targetId,
          sourceId: part.sourceId,
        );

  final int deviceId;
  final List<int> commandFlags;
  final int sequenceNumber;

  Uint8List get raw => encode();
}

typedef CommandGenerator = CommandEncoder Function(int deviceId);

typedef CommandEncoder = Command Function(CommandPartial partial);

@freezed
abstract class ThreeAxisSensor with _$ThreeAxisSensor {
  const factory ThreeAxisSensor({double x, double y, double z}) =
      _ThreeAxisSensor;
}

@freezed
abstract class TwoAxisSensor with _$TwoAxisSensor {
  const factory TwoAxisSensor({double x, double y}) = _TwoAxisSensor;
}

@freezed
abstract class AngleSensor with _$AngleSensor {
  const factory AngleSensor({double pitch, double roll, double yaw}) =
      _AngleSensor;
}

@freezed
abstract class SensorResponse with _$SensorResponse {
  const factory SensorResponse({
    @nullable AngleSensor angles,
    @nullable ThreeAxisSensor accelerometer,
    @nullable ThreeAxisSensor gyro,
    @nullable TwoAxisSensor position,
    @nullable TwoAxisSensor velocity,
  }) = _SensorResponse;
}
