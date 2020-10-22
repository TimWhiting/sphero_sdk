import 'dart:typed_data';

/// SensorData event when sensor data is received
const ERROR = 'error';

/// SensorData event when sensor data is received
const SensorData = 'sensordata';

/// Collision event when collision is detected
const Collision = 'collision';

class Packet {
  const Packet(this.header, this.body, this.checksum);
  final Uint8List header;
  final Uint8List body;
  final int checksum;
}

class SpheroDriver {
  SpheroDriver({this.name = 'Sphero'});
  final String name;
  dynamic _connection;
  int _seq;
  final asyncResponse = <Uint8List>[];
  final syncResponse = <Uint8List>[];
}
