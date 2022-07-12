import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'encoder.dart';
part 'types.freezed.dart';

abstract class IntValueEnum {
  int get value;
}

enum DeviceId<T extends IntValueEnum> implements IntValueEnum {
  apiProcessor(0x10, APIProcessCommandIds.values),
  systemInfo(0x11, SystemInfoCommandIds.values),
  powerInfo(0x13, PowerCommandIds.values),
  driving(0x16, DrivingCommandIds.values),
  animatronics(0x17, AnimatronicsCommandIds.values),
  sensor(0x18, SensorCommandIds.values),
  userIO(0x1a, UserIOCommandIds.values),
  somethingAPI(0x1f, SomethingApi.values);

  const DeviceId(this.value, this.commands);
  @override
  final int value;
  final List<T> commands;
}

enum SomethingApi implements IntValueEnum {
  something5(0x27);

  const SomethingApi(this.value);
  @override
  final int value;
}

enum APIProcessCommandIds implements IntValueEnum {
  echo(0x00);

  const APIProcessCommandIds(this.value);
  @override
  final int value;
}

enum SystemInfoCommandIds implements IntValueEnum {
  mainApplicationVersion(0x00),
  bootloaderVersion(0x01),
  something(0x06),
  something6(0x12),
  something7(0x28);

  const SystemInfoCommandIds(this.value);
  @override
  final int value;
}

enum PowerCommandIds implements IntValueEnum {
  deepSleep(0x00),
  sleep(0x01),
  batteryVoltage(0x03),
  wake(0x0d),
  something2(0x10), // every x time
  something3(0x04), // every x time
  something4(0x1e);

  const PowerCommandIds(this.value);
  @override
  final int value;
}

enum DrivingCommandIds implements IntValueEnum {
  rawMotor(0x01),
  resetYaw(0x06),
  driveAsSphero(0x04),
  driveAsRc(0x02),
  driveWithHeading(0x07),
  stabilization(0x0c);

  const DrivingCommandIds(this.value);
  @override
  final int value;
}

enum AnimatronicsCommandIds implements IntValueEnum {
  animationBundle(0x05),
  shoulderAction(0x0d),
  domePosition(0x0f),
  shoulderActionComplete(0x26),
  enableShoulderActionCompleteAsync(0x2a);

  const AnimatronicsCommandIds(this.value);
  @override
  final int value;
}

enum SensorCommandIds implements IntValueEnum {
  sensorMask(0x00),
  sensorResponse(0x02),
  configureCollision(0x11),
  collisionDetectedAsync(0x12),
  resetLocator(0x13),
  enableCollisionAsync(0x14),
  sensor1(0x0f),
  sensor2(0x17),
  sensorMaskExtended(0x0c);

  const SensorCommandIds(this.value);
  @override
  final int value;
}

enum UserIOCommandIds implements IntValueEnum {
  allLEDs(0x0e),
  allLEDsV21(0x1c),
  playAudioFile(0x07),
  audioVolume(0x08),
  stopAudi(0xa),
  testSound(0x18),
  startIdleLedAnimation(0x19),
  matrixPixel(0x2d),
  matrixColor(0x2f),
  clearMatrix(0x38),
  matrixRotation(0x3a),
  matrixScrollText(0x3b),
  matrixLine(0x3d),
  matrixFill(0x3e);

  const UserIOCommandIds(this.value);
  @override
  final int value;
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
    required this.isResponse,
    required this.requestsResponse,
    required this.requestsOnlyErrorResponse,
    required this.resetsInactivityTimeout,
    required this.commandHasTargetId,
    required this.commandHasSourceId,
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
  CommandOutput({required this.bytes, required this.checksum});
  final List<int> bytes;
  int checksum;
}

class CommandPartial<T extends IntValueEnum> {
  CommandPartial({
    required this.commandId,
    this.payload = const [],
    this.targetId,
    this.sourceId,
  });
  List<int> payload;
  final T commandId;
  int? targetId;
  int? sourceId;
}

class Command<T extends IntValueEnum> extends CommandPartial<T> {
  Command({
    required List<int> payload,
    required T commandId,
    required this.sequenceNumber,
    required this.deviceId,
    int? targetId,
    int? sourceId,
    this.commandFlags = const [],
  }) : super(
          payload: payload,
          commandId: commandId,
          targetId: targetId,
          sourceId: sourceId,
        );
  Command.fromPart({
    required CommandPartial<T> part,
    required this.deviceId,
    required this.sequenceNumber,
    this.commandFlags = const [],
  }) : super(
          commandId: part.commandId,
          payload: part.payload,
          targetId: part.targetId,
          sourceId: part.sourceId,
        );

  final DeviceId deviceId;
  final List<int> commandFlags;
  final int sequenceNumber;

  Uint8List get raw => encode();
}

typedef CommandGenerator = CommandEncoder Function(DeviceId deviceId);

typedef CommandEncoder = Command Function(CommandPartial partial);

@freezed
class ThreeAxisSensor with _$ThreeAxisSensor {
  const factory ThreeAxisSensor({
    required double x,
    required double y,
    required double z,
  }) = _ThreeAxisSensor;
}

@freezed
class TwoAxisSensor with _$TwoAxisSensor {
  const factory TwoAxisSensor({required double x, required double y}) =
      _TwoAxisSensor;
}

@freezed
class AngleSensor with _$AngleSensor {
  const factory AngleSensor({
    required double pitch,
    required double roll,
    required double yaw,
  }) = _AngleSensor;
}

@freezed
class SensorResponse with _$SensorResponse {
  const factory SensorResponse({
    AngleSensor? angles,
    ThreeAxisSensor? accelerometer,
    ThreeAxisSensor? gyro,
    TwoAxisSensor? position,
    TwoAxisSensor? velocity,
  }) = _SensorResponse;
}
