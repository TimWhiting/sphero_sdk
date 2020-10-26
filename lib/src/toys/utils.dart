import 'package:buffer/buffer.dart';
import 'package:sphero_sdk/src/commands/types.dart';

import 'types.dart';

List<int> sensorValuesToRawV2(List<int> sensorMask,
        [APIVersion apiVersion = APIVersion.V2]) =>
    sensorMask.fold([], (v2, m) {
      int mask;
      switch (m) {
        case SensorMaskValues.accelerometer:
          mask = SensorMaskV2.accelerometerFilteredAll;
          break;
        case SensorMaskValues.locator:
          mask = SensorMaskV2.locatorAll;
          break;
        case SensorMaskValues.orientation:
          mask = SensorMaskV2.imuAnglesFilteredAll;
          break;
      }

      if (m == SensorMaskValues.gyro && apiVersion == APIVersion.V2) {
        mask = SensorMaskV2.gyroFilteredAllV2;
      }

      if (mask != null) {
        return [...v2, mask];
      }
      return v2;
    });

List<int> sensorValuesToRawV21(List<int> sensorMask,
        [APIVersion apiVersion = APIVersion.V2]) =>
    sensorMask.fold<List<int>>([], (v21, m) {
      int mask;
      if (m == SensorMaskValues.gyro && apiVersion == APIVersion.V21) {
        mask = SensorMaskV2.gyroFilteredAllV21;
      }
      if (mask != null) {
        return [...v21, mask];
      }
      return v21;
    });

SensorMaskRaw sensorValuesToRaw(List<int> sensorMask,
    [APIVersion apiVersion = APIVersion.V2]) {
  return SensorMaskRaw(
      v2: sensorValuesToRawV2(sensorMask, apiVersion),
      v21: sensorValuesToRawV21(sensorMask, apiVersion));
}

int flatSensorMask(List<int> sensorMask) => sensorMask.fold(0, (bits, m) {
      return (bits |= m);
    });

double convertBinaryToFloat(List<int> nums, int offset) {
  // Extract binary data from payload array at the specific position in the array
  // Position in array is defined by offset variable
  // 1 Float value is always 4 bytes!
  if (offset + 4 > nums.length) {
    print('offset exceeded Limit of array ${nums.length}');
    return 0;
  }
  final reader = ByteDataReader();
  reader.add(
      [nums[0 + offset], nums[1 + offset], nums[2 + offset], nums[3 + offset]]);

  // return the float value as function of dataView class
  return reader.readFloat32();
}

class ParserState {
  final int location;
  final SensorResponse response;
  final List<double> floats;
  final SensorMaskRaw sensorMask;

  ParserState({this.location, this.response, this.floats, this.sensorMask});
}

ParserState fillAngles(ParserState state) {
  final floats = state.floats;
  final sensorMask = state.sensorMask;
  final response = state.response;
  final location = state.location;
  if (sensorMask.v2.indexOf(SensorMaskV2.imuAnglesFilteredAll) >= 0) {
    response.angles = AngleSensor(
        pitch: floats[location],
        roll: floats[location + 1],
        yaw: floats[location + 2]);

    return ParserState(
        floats: floats,
        sensorMask: sensorMask,
        response: response,
        location: location + 3);
  }
  return state;
}

ParserState fillAccelerometer(ParserState state) {
  final floats = state.floats;
  final sensorMask = state.sensorMask;
  final response = state.response;
  final location = state.location;
  if (state.sensorMask.v2.indexOf(SensorMaskV2.accelerometerFilteredAll) >= 0) {
    response.accelerometer = ThreeAxisSensor(
        x: floats[location], y: floats[location + 1], z: floats[location + 2]);
    return ParserState(
        floats: floats,
        sensorMask: sensorMask,
        response: response,
        location: location + 3);
  }
  return state;
}

ParserState fillLocator(ParserState state) {
  final floats = state.floats;
  final sensorMask = state.sensorMask;
  final response = state.response;
  final location = state.location;
  if (sensorMask.v2.indexOf(SensorMaskV2.locatorAll) >= 0) {
    final metersToCentimeters = 100.0;
    response.position = TwoAxisSensor(
        x: floats[location] * metersToCentimeters,
        y: floats[location + 1] * metersToCentimeters);
    response.velocity = TwoAxisSensor(
        x: floats[location + 2] * metersToCentimeters,
        y: floats[location + 3] * metersToCentimeters);
    return ParserState(
        floats: floats,
        response: response,
        sensorMask: sensorMask,
        location: location + 4);
  }

  return state;
}

ParserState fillGyroV2(ParserState state) {
  final floats = state.floats;
  final sensorMask = state.sensorMask;
  final response = state.response;
  final location = state.location;
  if (sensorMask.v2.indexOf(SensorMaskV2.gyroFilteredAllV2) >= 0) {
    final multiplier = 2000.0 / 32767.0;
    response.gyro = ThreeAxisSensor(
        x: floats[location] * multiplier,
        y: floats[location + 1] * multiplier,
        z: floats[location + 2] * multiplier);

    return ParserState(
        floats: floats,
        sensorMask: sensorMask,
        response: response,
        location: location + 3);
  }
  return state;
}

ParserState fillGyroV21(ParserState state) {
  final floats = state.floats;
  final sensorMask = state.sensorMask;
  final response = state.response;
  final location = state.location;
  if (sensorMask.v21.indexOf(SensorMaskV2.gyroFilteredAllV21) >= 0) {
    response.gyro = ThreeAxisSensor(
        x: floats[location], y: floats[location + 1], z: floats[location + 2]);

    return ParserState(
        floats: floats,
        sensorMask: sensorMask,
        response: response,
        location: location + 3);
  }
  return state;
}

List<double> tranformToFloat(List<int> bytes) {
  final floats = <double>[];

  for (var i = 0; i < bytes.length; i += 4) {
    floats.add(convertBinaryToFloat(bytes, i));
  }
  return floats;
}

SensorResponse parseSensorEvent(List<int> payload, SensorMaskRaw sensorMask) {
  ParserState state = ParserState(
    floats: tranformToFloat(payload),
    sensorMask: sensorMask,
    location: 0,
    response: SensorResponse(),
  );

  state = fillAngles(state);
  state = fillAccelerometer(state);
  state = fillGyroV2(state);
  state = fillLocator(state);
  state = fillGyroV21(state);

  return state.response;
}
