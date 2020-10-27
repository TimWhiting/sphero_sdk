import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class AdaptorV1 {
  static const BLEService = "22bb746f2bb075542d6f726568705327";
  static const WakeCharacteristic = "22bb746f2bbf75542d6f726568705327";
  static const TXPowerCharacteristic = "22bb746f2bb275542d6f726568705327";
  static const AntiDosCharacteristic = "22bb746f2bbd75542d6f726568705327";
  static const RobotControlService = "22bb746f2ba075542d6f726568705327";
  static const CommandsCharacteristic = "22bb746f2ba175542d6f726568705327";
  static const ResponseCharacteristic = "22bb746f2ba675542d6f726568705327";
  AdaptorV1(String id, [this.peripheral])
      : uuid = id.split(':').join('').toLowerCase();
  final String uuid;
  bool isConnected = false;
  Peripheral peripheral;

  Future<void> open() async {
    if (peripheral != null) {
      _connectPeripheral();
    } else {
      final bleManager = BleManager();
      await bleManager.createClient();
      await bleManager.enableRadio();
      bleManager.startPeripheralScan().listen((sr) {
        if (sr.advertisementData.localName == uuid) {
          bleManager.stopPeripheralScan();
          peripheral = sr.peripheral;
          _connectPeripheral();
        }
      });
      await bleManager.destroyClient();
    }
  }

  /// Writes data to the BLE device on the
  /// RobotControlService/CommandsCharacteristic.
  Future<void> write(Uint8List data) {
    return writeServiceCharacteristic(
        RobotControlService, CommandsCharacteristic, data);
  }

  void Function(Uint8List) onRead;
  void Function() close;

  Future<void> devModeOn() async {
    await setAntiDos();
    await setTXPower(7);
    await wake();
  }

  void _connectPeripheral() {}
  Future<void> writeServiceCharacteristic(
    String robotControlService,
    String commandsCharacteristic,
    Uint8List data,
  ) {}
}
