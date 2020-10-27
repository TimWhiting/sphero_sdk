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
    final cwithValue = await peripheral.readCharacteristic(
        RobotControlService, ResponseCharacteristic);
    final data = cwithValue.value;
    if (data != null && data.length > 5) {
      readHandler(data);
    }
  }

  void readHandler(Uint8List data) {
    // TODO:
    throw UnimplementedError();
  }

  Future<void> wake() {
    return writeServiceCharacteristic(
        BLEService, WakeCharacteristic, Uint8List.fromList([1]));
  }

  Future<void> setTXPower(int level) {
    return writeServiceCharacteristic(
        BLEService, TXPowerCharacteristic, Uint8List.fromList([level]));
  }

  Future<void> setAntiDos() {
    final str = '011i3';
    final bytes = Uint8List.fromList(str.codeUnits);
    return writeServiceCharacteristic(BLEService, AntiDosCharacteristic, bytes);
  }

  Future<void> _connectPeripheral() async {
    await peripheral.discoverAllServicesAndCharacteristics();
    return await devModeOn();
  }

  Future<void> _connectBLE() async {
    if (!await peripheral.isConnected()) {
      await peripheral.connect();
      isConnected = true;
    }
  }

  Future<void> writeServiceCharacteristic(
    String serviceId,
    String characteristicId,
    Uint8List data,
  ) async {
    await peripheral.writeCharacteristic(
        serviceId, characteristicId, data, true);
  }
}
