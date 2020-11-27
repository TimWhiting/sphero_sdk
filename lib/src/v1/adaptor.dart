import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart' as ble;
import 'package:flutter_blue/flutter_blue.dart' as blue;

import 'adaptor_ble.dart';
import 'adaptor_blue.dart';

abstract class AdaptorV1 {
  factory AdaptorV1(String identifier, SpheroPeripheral p) {
    if (p.peripheral is ble.Peripheral) {
      return AdaptorV1BLE(identifier, p.peripheral as ble.Peripheral);
    }
    if (p.peripheral is blue.BluetoothDevice) {
      return AdaptorV1Blue(identifier, p.peripheral as blue.BluetoothDevice);
    }
    return null;
  }
  AdaptorV1.empty();

  void Function(Uint8List payload) onRead;

  Future<void> open();

  Future<void> close();

  void write(Uint8List data);
}

class SpheroPeripheral {
  SpheroPeripheral(this.peripheral);
  String get identifier {
    if (peripheral is ble.Peripheral) {
      return (peripheral as ble.Peripheral).identifier;
    }
    if (peripheral is blue.BluetoothDevice) {
      return (peripheral as blue.BluetoothDevice).id.id;
    }
    return null;
  }

  String get name {
    if (peripheral is ble.Peripheral) {
      return (peripheral as ble.Peripheral).name;
    }
    if (peripheral is blue.BluetoothDevice) {
      return (peripheral as blue.BluetoothDevice).name;
    }
    return null;
  }

  dynamic peripheral;
}
