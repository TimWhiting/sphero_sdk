import 'dart:typed_data';

/// SensorData event when sensor data is received
const ERROR = 'error';

/// SensorData event when sensor data is received
const SensorData = 'sensordata';

/// Collision event when collision is detected
const Collision = 'collision';
int calculateChecksum(List<int> header, List<int> body) {
  final buf = [...header, ...body];
  return calculateChecksum2(buf.skip(2).toList());
}

int calculateChecksum2(List<int> buf) {
  var calculatedChecksum = 0;
  for (var i = 0; i < buf.length; i++) {
    calculatedChecksum += buf[i];
  }
  return ~(calculatedChecksum % 256);
}

class Packet {
  Packet(this.header, this.body) : checksum = calculateChecksum(header, body);
  final List<int> header;
  final List<int> body;
  final int checksum;
}

/// LocatorConfig provides configuration for the Location api.
/// https://github.com/orbotix/DeveloperResources/blob/master/docs/Sphero_API_1.50.pdf
/// The current (X,Y) coordinates of Sphero on the ground plane in centimeters.
class LocatorConfig {
  const LocatorConfig({
    this.flags = 0x1,
    this.x = 0,
    this.y = 0,
    this.yawTare = 0,
  });

  /// Determines whether calibrate commands automatically correct the yaw tare value
  final int flags;

  /// Controls how the X-plane is aligned with Sphero’s heading coordinate system.
  final int x;

  /// Controls how the Y-plane is aligned with Sphero’s heading coordinate system.
  final int y;

  /// Controls how the X,Y-plane is aligned with Sphero’s heading coordinate system.
  final int yawTare;

  List<int> toBytes() {}
}

/// CollisionConfig provides configuration for the collision detection alogorithm.
/// For more information refer to the official api specification https://github.com/orbotix/DeveloperResources/blob/master/docs/Collision%20detection%201.2.pdf.
class CollisionConfig {
  const CollisionConfig({
    this.method = 0x1,
    this.xt = 0x80,
    this.yt = 0x80,
    this.xs = 0x80,
    this.ys = 0x80,
    this.dead = 0x60,
  });

  /// Detection method type to use. Methods 01h and 02h are supported as
  /// of FW ver 1.42. Use 00h to completely disable this service.
  final int method;

  /// An 8-bit settable threshold for the X (left/right) axes of Sphero.
  /// A value of 00h disables the contribution of that axis.
  final int xt;

  /// An 8-bit settable threshold for the Y (front/back) axes of Sphero.
  /// A value of 00h disables the contribution of that axis.
  final int yt;

  /// An 8-bit settable speed value for the X axes. This setting is ranged
  /// by the speed, then added to Xt to generate the final threshold value.
  final int xs;

  /// An 8-bit settable speed value for the Y axes. This setting is ranged
  /// by the speed, then added to Yt to generate the final threshold value.
  final int ys;

  /// An 8-bit post-collision dead time to prevent retriggering; specified
  /// in 10ms increments.
  final int dead;
}

/// CollisionPacket represents the response from a Collision event
class CollisionPacket {
  CollisionPacket(
      {this.x,
      this.y,
      this.z,
      this.axis,
      this.xMagnitude,
      this.yMagnitude,
      this.speed,
      this.timestamp});

  /// Normalized impact components (direction of the collision event):
  final int x, y, z;

  /// Thresholds exceeded by X (1h) and/or Y (2h) axis (bitmask): byte
  final int axis;

  /// Power that cross threshold Xt + Xs:
  final int xMagnitude, yMagnitude;

  /// Sphero's speed when impact detected:
  final int speed;

  /// Millisecond timer
  final int timestamp;

  /// Big Endian
  factory CollisionPacket.fromBytes(List<int> list) {}
}

/// DataStreamingConfig provides configuration for Sensor Data Streaming.
/// For more information refer to the official api specification https://github.com/orbotix/DeveloperResources/blob/master/docs/Sphero_API_1.50.pdf page 28
class DataStreamingConfig {
  /// DefaultDataStreamingConfig returns a DataStreamingConfig with a sampling rate of 40hz, 1 sample frame per package, unlimited streaming, and will stream all available sensor information
  DataStreamingConfig(
      {this.n = 10,
      this.m = 1,
      this.mask = 4294967295,
      this.pCnt = 0,
      this.mask2 = 4294967295});

  /// Divisor of the maximum sensor sampling rate
  final int n;

  /// Number of sample frames emitted per packet
  final int m;

  /// Bitwise selector of data sources to stream
  final int mask;

  /// Packet count 1-255 (or 0 for unlimited streaming)
  final int pCnt;

  /// Bitwise selector of more data sources to stream (optional)
  final int mask2;

  List<int> toBytes() {}
}

/// DataStreamingPacket represents the response from a Data Streaming event
class DataStreamingPacket {
  const DataStreamingPacket({
    this.rawAccX,
    this.rawAccY,
    this.rawAccZ,
    this.rawGyroX,
    this.rawGyroY,
    this.rawGyroZ,
    this.rsrv1,
    this.rsrv2,
    this.rsrv3,
    this.rawRMotorBack,
    this.rawLMotorBack,
    this.rawLMotor,
    this.rawRMotor,
    this.filtPitch,
    this.filtRoll,
    this.filtYaw,
    this.filtAccX,
    this.filtAccY,
    this.filtAccZ,
    this.filtGyroX,
    this.filtGyroY,
    this.filtGyroZ,
    this.rsrv4,
    this.rsrv5,
    this.rsrv6,
    this.filtRMotorBack,
    this.filtLMotorBack,
    this.rsrv7,
    this.rsrv8,
    this.rsrv9,
    this.rsrv10,
    this.rsrv11,
    this.quat0,
    this.quat1,
    this.quat2,
    this.quat3,
    this.odomX,
    this.odomY,
    this.accelOne,
    this.veloX,
    this.veloY,
  }); // int16

  factory DataStreamingPacket.fromBytes(List<int> list) {}

  /// 8000 0000h	accelerometer axis X, raw	-2048 to 2047	4mG
  final int rawAccX; // int16
  /// 4000 0000h	accelerometer axis Y, raw	-2048 to 2047	4mG
  final int rawAccY; //int16
  /// 2000 0000h	accelerometer axis Z, raw	-2048 to 2047	4mG
  final int rawAccZ; //int16
  /// 1000 0000h	gyro axis X, raw	-32768 to 32767	0.068 degrees
  final int rawGyroX; // int16
  /// 0800 0000h	gyro axis Y, raw	-32768 to 32767	0.068 degrees
  final int rawGyroY; // int16
  /// 0400 0000h	gyro axis Z, raw	-32768 to 32767	0.068 degrees
  final int rawGyroZ; // int16
  /// 0200 0000h	Reserved
  final int rsrv1; // int16
  /// 0100 0000h	Reserved
  final int rsrv2; // int16
  /// 0080 0000h	Reserved
  final int rsrv3; // int16
  /// 0040 0000h	right motor back EMF, raw	-32768 to 32767	22.5 cm
  final int rawRMotorBack; // int16
  /// 0020 0000h	left motor back EMF, raw	-32768 to 32767	22.5 cm
  final int rawLMotorBack; //int16
  /// 0010 0000h	left motor, PWM, raw	-2048 to 2047	duty cycle
  final int rawLMotor; //int16
  /// 0008 0000h	right motor, PWM raw	-2048 to 2047	duty cycle
  final int rawRMotor; // int16
  /// 0004 0000h	IMU pitch angle, filtered	-179 to 180	degrees
  final int filtPitch; //int16
  /// 0002 0000h	IMU roll angle, filtered	-179 to 180	degrees
  final int filtRoll; // int16
  /// 0001 0000h	IMU yaw angle, filtered	-179 to 180	degrees
  final int filtYaw; //int16
  /// 0000 8000h	accelerometer axis X, filtered	-32768 to 32767	1/4096 G
  final int filtAccX; //int16
  /// 0000 4000h	accelerometer axis Y, filtered	-32768 to 32767	1/4096 G
  final int filtAccY; // int16
  /// 0000 2000h	accelerometer axis Z, filtered	-32768 to 32767	1/4096 G
  final int filtAccZ; //int16
  /// 0000 1000h	gyro axis X, filtered	-20000 to 20000	0.1 dps
  final int filtGyroX; // int16
  /// 0000 0800h	gyro axis Y, filtered	-20000 to 20000	0.1 dps
  final int filtGyroY; // int16
  /// 0000 0400h	gyro axis Z, filtered	-20000 to 20000	0.1 dps
  final int filtGyroZ; //int16
  /// 0000 0200h	Reserved
  final int rsrv4; // int16
  /// 0000 0100h	Reserved
  final int rsrv5; // int16
  /// 0000 0080h	Reserved
  final int rsrv6; // int16
  /// 0000 0040h	right motor back EMF, filtered	-32768 to 32767	22.5 cm
  final int filtRMotorBack; // int16
  /// 0000 0020h	left motor back EMF, filtered	-32768 to 32767	22.5 cm
  final int filtLMotorBack; //int16
  /// 0000 0010h	Reserved 1
  final int rsrv7; //int16
  /// 0000 0008h	Reserved 2
  final int rsrv8; // int16
  /// 0000 0004h	Reserved 3
  final int rsrv9; // int16
  /// 0000 0002h	Reserved 4
  final int rsrv10; // int16
  /// 0000 0001h	Reserved 5
  final int rsrv11; // int16
  /// 8000 0000h	Quaternion Q0	-10000 to 10000	1/10000 Q
  final int quat0; //int16
  /// 4000 0000h	Quaternion Q1	-10000 to 10000	1/10000 Q
  final int quat1; // int16
  /// 2000 0000h	Quaternion Q2	-10000 to 10000	1/10000 Q
  final int quat2; // int16
  /// 1000 0000h	Quaternion Q3	-10000 to 10000	1/10000 Q
  final int quat3; // int16
  /// 0800 0000h	Odometer X	-32768 to 32767	cm
  final int odomX; // int16
  /// 0400 0000h	Odometer Y	-32768 to 32767	cm
  final int odomY; // int16
  /// 0200 0000h	AccelOne	0 to 8000	1 mG
  final int accelOne; // int16
  /// 0100 0000h	Velocity X	-32768 to 32767	mm/s
  final int veloX; // int16
  /// 0080 0000h	Velocity Y	-32768 to 32767	mm/s
  final int veloY;
}
