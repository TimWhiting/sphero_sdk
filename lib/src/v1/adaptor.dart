// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:typed_data';

import 'package:flutter_blue_plugin/flutter_blue_plugin.dart' as blue;

import 'adaptor_blue.dart';

abstract class AdaptorV1 {
  factory AdaptorV1(String identifier, SpheroPeripheral p) {
    if (p.peripheral is blue.BluetoothDevice) {
      return AdaptorV1Blue(identifier, p.peripheral as blue.BluetoothDevice);
    }
    throw Exception('Unknown peripheral type');
  }
  AdaptorV1.empty();

  late void Function(Uint8List payload) onRead;

  blue.BluetoothDevice get peripheral;

  Future<void> open();

  Future<void> close();

  void write(Uint8List data);
}

class SpheroPeripheral {
  SpheroPeripheral(this.peripheral);
  String get identifier {
    if (peripheral is blue.BluetoothDevice) {
      return (peripheral as blue.BluetoothDevice).id.id;
    }
    throw Exception('Unknown peripheral type');
  }

  String get name {
    if (peripheral is blue.BluetoothDevice) {
      return (peripheral as blue.BluetoothDevice).name;
    }
    throw Exception('Unknown peripheral type');
  }

  blue.BluetoothDevice get peripheral;
}
