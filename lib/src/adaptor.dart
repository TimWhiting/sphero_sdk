import 'package:dartx/dartx.dart';
import 'package:flutter_sphero_sdk/src/bluetooth.dart';
import 'dart:typed_data';

import 'packets.dart';

class Adaptor {
  Adaptor(this.name, this.port, this.serialConnect);
  final String name;
  final Function(String) serialConnect;
  String port;
  IBluetooth _serialPort;
  bool connected = false;
  int _seq = 0;
  void connect() {
    try {
      _serialPort = serialConnect(port);
      connected = true;
    } on Exception {}
  }

  void disconnect() {
    if (connected) {
      try {
        _serialPort.close();
        connected = false;
      } on Exception {}
    }
  }

  void reconnect() {
    if (connected) {
      disconnect();
    }
    connect();
  }

  void dispose() {
    disconnect();
  }

  Future<Uint8List> readHeader() {
    return readNextChunk(5);
  }

  Future<Uint8List> readBody(int length) {
    return readNextChunk(length);
  }

  Future<Uint8List> readNextChunk(int length) async {
    List<int> read = [];
    var bytesRead = 0;

    while (bytesRead < length) {
      await Future.delayed(1.milliseconds);
      read.addAll(_serialPort.read());

      bytesRead = read.length;
    }
    return read;
  }

  void sendPacketRaw(Packet packet) {
    final buf = [...packet.header, ...packet.body, packet.checksum];

    final length = _serialPort.write(buf);
    if (length != buf.length) {
      throw Exception("Not enough bytes written");
    }
    _seq++;
  }

  Packet sendPacket(List<int> body, int did, int cid) {
    final packet = _craftPacket(body, did, cid);
    sendPacketRaw(packet);
    return packet;
  }

  Packet _craftPacket(List<int> body, int did, int cid) {
    return Packet([0xff, 0xff, did, _seq, body.length], body);
  }
}
