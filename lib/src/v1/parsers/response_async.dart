import 'response.dart';

const ASYNC_PARSER = {
  0x01: APIV1(
      desc: 'Battery Power State',
      idCode: 0x01,
      did: 0x00,
      cid: 0x21,
      event: 'battery',
      fields: [
        APIField(
          name: 'state',
          type: 'predefined',
          values: {
            0x01: 'Battery Charging',
            0x02: 'Battery OK',
            0x03: 'Battery Low',
            0x04: 'Battery Critical'
          },
        ),
      ]),
  0x02: APIV1(
      desc: 'Level 1 Diagnostic Response',
      idCode: 0x02,
      did: 0x00,
      cid: 0x40,
      event: 'level1Diagnostic',
      fields: [
        APIField(
            name: 'diagnostic',
            type: 'string',
            format: 'ascii',
            from: 0,
            to: null)
      ]),
  0x03: APIV1(
      desc: 'Sensor Data Streaming',
      idCode: 0x03,
      did: 0x02,
      cid: 0x11,
      event: 'dataStreaming',
      fields: [
        APIField(
            name: 'xAccelRaw',
            type: 'bitmask',
            bitmask: 0x80000000,
            maskField: 'mask1',
            sensor: 'accelerometer axis X, raw',
            rangeBottom: -2048,
            rangeTop: 2047,
            units: '4mg'),
        APIField(
            name: 'yAccelRaw',
            type: 'bitmask',
            bitmask: 0x40000000,
            maskField: 'mask1',
            sensor: 'accelerometer axis Y, raw',
            rangeBottom: -2048,
            rangeTop: 2047,
            units: '4mG'),
        APIField(
            name: 'zAccelRaw',
            type: 'bitmask',
            bitmask: 0x20000000,
            maskField: 'mask1',
            sensor: 'accelerometer axis Z, raw',
            rangeBottom: -2048,
            rangeTop: 2047,
            units: '4mG'),
        APIField(
            name: 'xGyroRaw',
            type: 'bitmask',
            bitmask: 0x10000000,
            maskField: 'mask1',
            sensor: 'gyroscope axis X, raw',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '0.068 degrees'),
        APIField(
            name: 'yGyroRaw',
            type: 'bitmask',
            bitmask: 0x08000000,
            maskField: 'mask1',
            sensor: 'gyroscope axis Y, raw',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '0.068 degrees'),
        APIField(
            name: 'zGyroRaw',
            type: 'bitmask',
            bitmask: 0x04000000,
            maskField: 'mask1',
            sensor: 'gyroscope axis Z, raw',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '0.068 degrees'),
        APIField(
            name: 'rMotorBackEmfRaw',
            type: 'bitmask',
            bitmask: 0x00400000,
            maskField: 'mask1',
            sensor: 'right motor back EMF, raw',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '22.5cm'),
        APIField(
            name: 'lMotorBackEmfRaw',
            type: 'bitmask',
            bitmask: 0x00200000,
            maskField: 'mask1',
            sensor: 'left motor back EMF, raw',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '22.5cm'),
        APIField(
            name: 'lMotorPWMRaw',
            type: 'bitmask',
            bitmask: 0x00100000,
            maskField: 'mask1',
            sensor: 'left motor PWM, raw',
            rangeBottom: -2048,
            rangeTop: 2047,
            units: 'dutyCycle'),
        APIField(
            name: 'rMotorPWMRaw',
            type: 'bitmask',
            bitmask: 0x00080000,
            maskField: 'mask1',
            sensor: 'right motor PWM, raw',
            rangeBottom: -2048,
            rangeTop: 2047,
            units: 'dutyCycle'),
        APIField(
            name: 'pitchAngle',
            type: 'bitmask',
            bitmask: 0x00040000,
            maskField: 'mask1',
            sensor: 'IMU pitch angle, filtered',
            rangeBottom: -179,
            rangeTop: 180,
            units: 'degrees'),
        APIField(
            name: 'rollAngle',
            type: 'bitmask',
            bitmask: 0x00020000,
            maskField: 'mask1',
            sensor: 'IMU roll angle, filtered',
            rangeBottom: -179,
            rangeTop: 180,
            units: 'degrees'),
        APIField(
            name: 'yawAngle',
            type: 'bitmask',
            bitmask: 0x00010000,
            maskField: 'mask1',
            sensor: 'IMU yaw angle, filtered',
            rangeBottom: -179,
            rangeTop: 180,
            units: 'degrees'),
        APIField(
            name: 'xAccel',
            type: 'bitmask',
            bitmask: 0x00008000,
            maskField: 'mask1',
            sensor: 'accelerometer axis X, filtered',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '1/4096 G'),
        APIField(
            name: 'yAccel',
            type: 'bitmask',
            bitmask: 0x00004000,
            maskField: 'mask1',
            sensor: 'accelerometer axis Y, filtered',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '1/4096 G'),
        APIField(
            name: 'zAccel',
            type: 'bitmask',
            bitmask: 0x00002000,
            maskField: 'mask1',
            sensor: 'accelerometer axis Z, filtered',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '1/4096 G'),
        APIField(
            name: 'xGyro',
            type: 'bitmask',
            bitmask: 0x00001000,
            maskField: 'mask1',
            sensor: 'gyro axis X, filtered',
            rangeBottom: -20000,
            rangeTop: 20000,
            units: '0.1 dps'),
        APIField(
            name: 'yGyro',
            type: 'bitmask',
            bitmask: 0x00000800,
            maskField: 'mask1',
            sensor: 'gyro axis Y, filtered',
            rangeBottom: -20000,
            rangeTop: 20000,
            units: '0.1 dps'),
        APIField(
            name: 'zGyro',
            type: 'bitmask',
            bitmask: 0x00000400,
            maskField: 'mask1',
            sensor: 'gyro axis Z, filtered',
            rangeBottom: -20000,
            rangeTop: 20000,
            units: '0.1 dps'),
        APIField(
            name: 'rMotorBackEmf',
            type: 'bitmask',
            bitmask: 0x00000040,
            maskField: 'mask1',
            sensor: 'right motor back EMF, filtered',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '22.5 cm'),
        APIField(
            name: 'lMotorBackEmf',
            type: 'bitmask',
            bitmask: 0x00000020,
            maskField: 'mask1',
            sensor: 'left motor back EMF, filtered',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: '22.5 cm'),
        APIField(
            name: 'quaternionQ0',
            type: 'bitmask',
            bitmask: 0x80000000,
            maskField: 'mask2',
            sensor: 'quaternion Q0',
            rangeBottom: -10000,
            rangeTop: 10000,
            units: '1/10000 Q'),
        APIField(
            name: 'quaternionQ1',
            type: 'bitmask',
            bitmask: 0x40000000,
            maskField: 'mask2',
            sensor: 'quaternion Q1',
            rangeBottom: -10000,
            rangeTop: 10000,
            units: '1/10000 Q'),
        APIField(
            name: 'quaternionQ2',
            type: 'bitmask',
            bitmask: 0x20000000,
            maskField: 'mask2',
            sensor: 'quaternion Q2',
            rangeBottom: -10000,
            rangeTop: 10000,
            units: '1/10000 Q'),
        APIField(
            name: 'quaternionQ3',
            type: 'bitmask',
            bitmask: 0x10000000,
            maskField: 'mask2',
            sensor: 'quaternion Q3',
            rangeBottom: -10000,
            rangeTop: 10000,
            units: '1/10000 Q'),
        APIField(
            name: 'xOdometer',
            type: 'bitmask',
            bitmask: 0x08000000,
            maskField: 'mask2',
            sensor: 'odometer X',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: 'cm'),
        APIField(
            name: 'yOdometer',
            type: 'bitmask',
            bitmask: 0x04000000,
            maskField: 'mask2',
            sensor: 'odometer Y',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: 'cm'),
        APIField(
            name: 'accelOne',
            type: 'bitmask',
            bitmask: 0x02000000,
            maskField: 'mask2',
            sensor: 'acceleration one',
            rangeBottom: 0,
            rangeTop: 8000,
            units: '1mG'),
        APIField(
            name: 'xVelocity',
            type: 'bitmask',
            bitmask: 0x01000000,
            maskField: 'mask2',
            sensor: 'velocity X',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: 'mm/s'),
        APIField(
            name: 'yVelocity',
            type: 'bitmask',
            bitmask: 0x00800000,
            maskField: 'mask2',
            sensor: 'velocity Y',
            rangeBottom: -32768,
            rangeTop: 32767,
            units: 'mm/s')
      ]),
  0x04: APIV1(
      desc: 'Config Block Contents',
      idCode: 0x04,
      did: 0x02,
      cid: 0x40,
      event: 'configBlock',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x05: APIV1(
      desc: 'Pre-sleep Warning',
      idCode: 0x05,
      did: null,
      cid: null,
      event: 'preSleepWarning',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x06: APIV1(
      desc: 'Macro Markers',
      idCode: 0x06,
      did: null,
      cid: null,
      event: 'macroMarkers',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x07: APIV1(
      desc: 'Collision detected',
      idCode: 0x07,
      did: 0x02,
      cid: 0x12,
      event: 'collision',
      fields: [
        APIField(
          name: 'x',
          type: 'number',
          from: 0,
          to: 2,
        ),
        APIField(
          name: 'y',
          type: 'number',
          from: 2,
          to: 4,
        ),
        APIField(
          name: 'z',
          type: 'number',
          from: 4,
          to: 6,
        ),
        APIField(
          name: 'axis',
          type: 'number',
          from: 6,
          to: 7,
        ),
        APIField(
          name: 'xMagnitude',
          type: 'number',
          from: 7,
          to: 9,
        ),
        APIField(
          name: 'yMagnitude',
          type: 'number',
          from: 9,
          to: 11,
        ),
        APIField(
          name: 'speed',
          type: 'number',
          from: 11,
          to: 12,
        ),
        APIField(name: 'timestamp', type: 'number', from: 12, to: 16),
      ]),
  0x08: APIV1(
      desc: 'Orb-basic Print Message',
      idCode: 0x08,
      did: null,
      cid: null,
      event: 'obPrint',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x09: APIV1(
      desc: 'Orb-basic ASCII Error Message',
      idCode: 0x09,
      did: null,
      cid: null,
      event: 'obAsciiError',
      fields: [
        APIField(
            name: 'content', type: 'string', format: 'ascii', from: 0, to: null)
      ]),
  0x0A: APIV1(
      desc: 'Orb-basic Binary Error Message',
      idCode: 0x0A,
      did: null,
      cid: null,
      event: 'obBinaryError',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x0B: APIV1(
      desc: 'Self Level',
      idCode: 0x0B,
      did: 0x02,
      cid: 0x09,
      event: 'selfLevel',
      fields: [
        APIField(
          name: 'result',
          type: 'predefined',
          values: {
            0x00: 'Unknown',
            0x01: 'Timed Out (level was not achieved)',
            0x02: 'Sensors Error',
            0x03: 'Self Level Disabled (see Option flags)',
            0x04: 'Aborted (by API call)',
            0x05: 'Charger Not Found',
            0x06: 'Success',
          },
        )
      ]),
  0x0C: APIV1(
      desc: 'Gyro Axis Limit Exceeded',
      idCode: 0x0C,
      did: null,
      cid: null,
      event: 'gyroAxisExceeded',
      fields: [
        APIField(
            name: 'x',
            type: 'predefined',
            mask: 0x03,
            values: {0x00: 'none', 0x01: 'positive', 0x02: 'negative'}),
        APIField(
            name: 'y',
            type: 'predefined',
            mask: 0x0C,
            values: {0x00: 'none', 0x04: 'positive', 0x08: 'negative'}),
        APIField(
            name: 'z',
            type: 'predefined',
            mask: 0x30,
            values: {0x00: 'none', 0x10: 'positive', 0x20: 'negative'})
      ]),
  0x0D: APIV1(
      desc: 'Sphero\'s Soul Data',
      idCode: 0x0D,
      did: 0x02,
      cid: 0x43,
      event: 'spheroSoulData',
      fields: [
        APIField(
          name: 'content',
          type: 'raw',
        )
      ]),
  0x0E: APIV1(
      desc: 'Level Up',
      idCode: 0x0E,
      did: null,
      cid: null,
      event: 'levelUp',
      fields: [
        APIField(
          name: 'robotLevel',
          type: 'number',
          from: 0,
          to: 2,
        ),
        APIField(name: 'attributePoints', type: 'number', from: 2, to: 4),
      ]),
  0x0F: APIV1(
      desc: 'Shield Damage',
      idCode: 0x0F,
      did: null,
      cid: null,
      event: 'shieldDamage',
      fields: [
        APIField(
          name: 'robotLevel',
          type: 'number',
          from: 0,
          to: 1,
        )
      ]),
  0x10: APIV1(
      desc: 'XP % towards next robot level (0 = 0%, 255 = 100%)',
      idCode: 0x10,
      did: null,
      cid: null,
      event: 'xpUpdate',
      fields: [
        APIField(
          name: 'cp',
          type: 'number',
          from: 0,
          to: 1,
        )
      ]),
  0x11: APIV1(
      desc: 'Boost power left (0 = 0%, 255 = 100%)',
      idCode: 0x11,
      did: null,
      cid: null,
      event: 'boostUpdate',
      fields: [
        APIField(
          name: 'boost',
          type: 'number',
          from: 0,
          to: 1,
        )
      ]),
};
