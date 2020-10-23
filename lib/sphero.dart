import 'dart:async';
import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'src/packets.dart';

class SpheroDriver {
  SpheroDriver({this.name = 'Sphero'});
  final String name;
  dynamic _connection;
  int _seq;
  final asyncResponse = <Uint8List>[];
  final syncResponse = <Uint8List>[];
  final packetChannel = BehaviorSubject<Packet>();
  final responseChannel = BehaviorSubject<DataStreamingPacket>();
  final events = BehaviorSubject<String>();

  /// Halt halts the SpheroDriver and sends a SpheroDriver.Stop command to the Sphero.
  /// Returns true on successful halt.
  void halt() {}
}
