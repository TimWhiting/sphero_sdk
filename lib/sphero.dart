import 'dart:async';
import 'dart:typed_data';
import 'package:buffer/buffer.dart';
import 'package:rxdart/rxdart.dart';
import 'package:dartx/dartx.dart';
import 'src/adaptor.dart';
import 'src/bluetooth.dart';
import 'src/packets.dart';

class SpheroDriver {
  SpheroDriver(
      {this.name = 'Sphero',
      String port,
      IBluetooth Function(String) serialConnect})
      : adaptor = Adaptor(name, port, serialConnect);
  final String name;
  final Adaptor adaptor;
  final syncResponse = <Uint8List>[];
  final responseChannel = BehaviorSubject<List<int>>();

  void dispose() {
    responseChannel.close();
  }

  /// Halt halts the SpheroDriver and sends a SpheroDriver.Stop command to the Sphero.
  /// Returns true on successful halt.
  Future<bool> halt() async {
    if (adaptor.connected) {
      Timer.periodic(10.milliseconds, (_) => stop());
      await Future.delayed(1.seconds);
    }
    return true;
  }

// SetRGB sets the Sphero to the given r, g, and b values
  void setRGB(int r, int g, int b) {
    assert(r >= 0 && r <= 255);
    assert(g >= 0 && g <= 255);
    assert(b >= 0 && b <= 255);
    adaptor.sendPacket([r, g, b, 0x01], 0x02, 0x20);
  }

// GetRGB returns the current r, g, b value of the Sphero
  Future<List<int>> getRGB() async {
    final buf = await getResponse([], 0x02, 0x22);
    if (buf.length == 9) {
      return [buf[5], buf[6], buf[7]];
    }
    return [];
  }

// ReadLocator reads Sphero's current position (X,Y), component velocities and SOG (speed over ground).
  Future<List<int>> readLocator() async {
    final buf = await getResponse([], 0x02, 0x15);
    if (buf.length == 16) {
      final reader = ByteDataReader(endian: Endian.big);
      reader.add(buf.sublist(5, 15));

      return [for (final _ in 0.rangeTo(4)) reader.readInt16()];
    }
    return [];
  }

// SetBackLED sets the Sphero Back LED to the specified brightness
  void setBackLED(int level) {
    adaptor.sendPacket([level], 0x02, 0x21);
  }

// SetRotationRate sets the Sphero rotation rate
// A value of 255 jumps to the maximum (currently 400 degrees/sec).
  void setRotationRate(int level) {
    adaptor.sendPacket([level], 0x02, 0x03);
  }

// SetHeading sets the heading of the Sphero
  void setHeading(int heading) {
    adaptor.sendPacket([heading >> 8, heading & 0xFF], 0x02, 0x01);
  }

// SetStabilization enables or disables the built-in auto stabilizing features of the Sphero
  void setStabilization(bool on) {
    var b = 0x01;
    if (!on) {
      b = 0x00;
    }
    adaptor.sendPacket([b], 0x02, 0x02);
  }

// Roll sends a roll command to the Sphero gives a speed and heading
  void roll(int speed, int heading) {
    adaptor.sendPacket([speed, heading >> 8, heading & 0xFF, 0x01], 0x02, 0x30);
  }

// ConfigureLocator configures and enables the Locator
  void configureLocator(LocatorConfig d) {
    adaptor.sendPacket(d.toBytes(), 0x02, 0x13);
  }

// SetDataStreaming enables sensor data streaming
  void setDataStreaming(DataStreamingConfig d) {
    adaptor.sendPacket(d.toBytes(), 0x02, 0x11);
  }

// Stop sets the Sphero to a roll speed of 0
  void stop() {
    roll(0, 0);
  }

// ConfigureCollisionDetection configures the sensitivity of the detection.
  void configureCollisionDetection(CollisionConfig cc) {
    adaptor.sendPacket(
        [cc.method, cc.xt, cc.yt, cc.xs, cc.ys, cc.dead], 0x02, 0x12);
  }

  void enableStopOnDisconnect() {
    adaptor.sendPacket([0x00, 0x00, 0x00, 0x01], 0x02, 0x37);
  }

  void handleCollisionDetected(List<int> data) {
    // ensure data is the right length:
    if (data.length != 22 || data[4] != 17) {
      return;
    }

    final collision = CollisionPacket.fromBytes(data.skip(5).toList());
    publish(Collision, collision);
  }

  void handleDataStreaming(List<int> data) {
    // ensure data is the right length:
    if (data.length != 90) {
      return;
    }
    final dataPacket = DataStreamingPacket.fromBytes(data.skip(5).toList());

    publish(SensorData, dataPacket);
  }

  Future<List<int>> getResponse(List<int> body, int did, int cid) async {
    final packet = adaptor.sendPacket(body, did, cid);
    for (var i = 0; i < 500; i++) {
      for (final value in syncResponse) {
        if (value[3] == packet.header[4] && value.length > 6) {
          syncResponse.remove(value);
          return value;
        }
      }
      await Future.delayed(100.microseconds);
    }
    return [];
  }

  void publish(String type, dynamic data) {}
}
