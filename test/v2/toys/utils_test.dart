import 'package:flutter_test/flutter_test.dart';
import 'package:sphero_sdk/src/v2/toys/index.dart';

void main() {
  test('Sensor-Parse', () {
    final mask = sensorValuesToRaw([
      SensorMaskValues.accelerometer,
      SensorMaskValues.orientation,
      SensorMaskValues.locator
    ]);
    final output = parseSensorEvent(payload, mask);
    expect(
      output,
      const SensorResponse(
        angles: AngleSensor(
          pitch: 5.656248092651367,
          roll: -0.11342836171388626,
          yaw: 0.0003869668871629983,
        ),
        accelerometer: ThreeAxisSensor(
          x: -0.006151249632239342,
          y: -0.10022957623004913,
          z: 1.0062620639801025,
        ),
        position: TwoAxisSensor(
          x: -0.000015292712873815617,
          y: -0.0002353802983634523,
        ),
        velocity:
            TwoAxisSensor(x: -0.0003802337232627906, y: -0.00783980285632424),
      ),
    );
  });
}

const payload = [
  64,
  180,
  255,
  252,
  189,
  232,
  77,
  33,
  57,
  202,
  225,
  209,
  187,
  201,
  144,
  108,
  189,
  205,
  69,
  42,
  63,
  128,
  205,
  50,
  180,
  36,
  52,
  74,
  182,
  29,
  246,
  7,
  182,
  127,
  43,
  168,
  184,
  164,
  105,
  159
];
