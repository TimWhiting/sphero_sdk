import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class AdaptorV1 {
  AdaptorV1(String id, [this.peripheral])
      : uuid = id.split(':').join('').toLowerCase();
  static const BLEService = '22bb746f2bb075542d6f726568705327';
  static const WakeCharacteristic = '22bb746f2bbf75542d6f726568705327';
  static const TXPowerCharacteristic = '22bb746f2bb275542d6f726568705327';
  static const AntiDosCharacteristic = '22bb746f2bbd75542d6f726568705327';
  static const RobotControlService = '22bb746f2ba075542d6f726568705327';
  static const CommandsCharacteristic = '22bb746f2ba175542d6f726568705327';
  static const ResponseCharacteristic = '22bb746f2ba675542d6f726568705327';

  final String uuid;
  bool isConnected = false;
  Peripheral peripheral;

  Future<void> open() async {
    if (peripheral != null) {
      await _connectPeripheral();
    } else {
      final completer = Completer<void>();
      final bleManager = BleManager();
      await bleManager.createClient();
      bleManager.startPeripheralScan().listen((sr) {
        if (sr.advertisementData.localName == uuid) {
          bleManager.stopPeripheralScan();
          peripheral = sr.peripheral;
          _connectPeripheral();
          completer.complete();
        }
      });
      return completer.future;
    }
  }

  /// Writes data to the BLE device on the
  /// RobotControlService/CommandsCharacteristic.
  Future<void> write(Uint8List data) => writeServiceCharacteristic(
      RobotControlService, CommandsCharacteristic, data);

  void Function(Uint8List) onRead;
  Future<void> Function() close;

  Future<void> devModeOn() async {
    await setAntiDos();
    await setTXPower(7);
    await wake();
    peripheral
        .monitorCharacteristic(RobotControlService, ResponseCharacteristic)
        .listen((cWithValue) {
      final data = cWithValue.value;
      if (data != null && data.length > 5) {
        onRead(data);
      }
    });
  }

  Future<void> wake() => writeServiceCharacteristic(
      BLEService, WakeCharacteristic, Uint8List.fromList([1]));

  Future<void> setTXPower(int level) => writeServiceCharacteristic(
      BLEService, TXPowerCharacteristic, Uint8List.fromList([level]));

  Future<void> setAntiDos() {
    const str = '011i3';
    final bytes = Uint8List.fromList(str.codeUnits);
    return writeServiceCharacteristic(BLEService, AntiDosCharacteristic, bytes);
  }

  Future<void> _connectPeripheral() async {
    await _connectBLE();
    await peripheral.discoverAllServicesAndCharacteristics();
    for (final service in await peripheral.services()) {
      for (final char in await service.characteristics()) {
        if (service.uuid == BLEService) {
          if (char.uuid == AntiDosCharacteristic) {
            print('Found Anti Dos characteristic');
          }
          if (char.uuid == WakeCharacteristic) {
            print('Found wake characteristic');
          }
          if (char.uuid == TXPowerCharacteristic) {
            print('Found tx power characteristic');
          }
        }
        if (service.uuid == RobotControlService) {
          if (char.uuid == CommandsCharacteristic) {
            print('Found commands characteristic');
          }
          if (char.uuid == ResponseCharacteristic) {
            print('Found response characteristic');
          }
        }
      }
    }
    return devModeOn();
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
