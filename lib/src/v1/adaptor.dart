import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class AdaptorV1 {
  AdaptorV1(String id, [this.peripheral])
      : uuid = id.split(':').join('').toLowerCase();
  static const BLEService = '22bb746f-2bb0-7554-2d6f-726568705327';
  static const WakeCharacteristic = '22bb746f-2bbf-7554-2d6f-726568705327';
  static const TXPowerCharacteristic = '22bb746f-2bb2-7554-2d6f-726568705327';
  static const AntiDosCharacteristic = '22bb746f-2bbd-7554-2d6f-726568705327';
  static const RobotControlService = '22bb746f-2ba0-7554-2d6f-726568705327';
  static const CommandsCharacteristic = '22bb746f-2ba1-7554-2d6f-726568705327';
  static const ResponseCharacteristic = '22bb746f-2ba6-7554-2d6f-726568705327';

  Characteristic _antiDosChar;
  Characteristic _wakeChar;
  Characteristic _txChar;
  Characteristic _commandChar;
  Characteristic _responseChar;

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
  Future<void> write(Uint8List data) => _commandChar.write(data, false);
  //writeServiceCharacteristic(
  //   RobotControlService,
  //   CommandsCharacteristic,
  //   data,
  //   false, //data[0] == FIELDS.sop2_sync,
  // );

  void Function(Uint8List) onRead;
  Future<void> close() async {
    await peripheral.disconnectOrCancelConnection();
    isConnected = false;
    peripheral = null;
  }

  Future<void> devModeOn() async {
    print('Setting anti-dos############################');
    await setAntiDos();
    print('Setting tx power!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
    await setTXPower(7);
    print('Waking##########################');
    await wake();
    _responseChar.monitor().asBroadcastStream().listen(
      (cWithValue) {
        final data = cWithValue;
        if (data != null && data.length > 5) {
          try {
            onRead(data);
          } on Exception catch (e) {
            print('Caught exception $e while reading');
          }
        }
      },
      onError: (e) =>
          print('Error: $e while monitoring the response characteristic'),
      onDone: () => print(
        'Done monitoring response characteristic#################!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!',
      ),
      cancelOnError: false,
    );
  }

  Future<void> wake() => _wakeChar.write(Uint8List.fromList([1]), false);
  // writeServiceCharacteristic(
  //  BLEService, WakeCharacteristic, Uint8List.fromList([1]), false);

  Future<void> setTXPower(int level) =>
      _txChar.write(Uint8List.fromList([level]), false);
  //writeServiceCharacteristic(
  //  BLEService, TXPowerCharacteristic, Uint8List.fromList([level]), false);

  Future<void> setAntiDos() {
    const str = '011i3';
    final bytes = Uint8List.fromList(utf8.encode(str));
    return _antiDosChar.write(bytes, false); //writeServiceCharacteristic(
    //BLEService, AntiDosCharacteristic, bytes, false);
  }

  Future<void> _connectPeripheral() async {
    print('connecting peripheral');
    await _connectBLE();
    await peripheral.discoverAllServicesAndCharacteristics();
    for (final service in await peripheral.services()) {
      for (final char in await service.characteristics()) {
        // print('Found service: ${service.uuid}, char: ${char.uuid}');
        if (service.uuid == BLEService) {
          if (char.uuid == AntiDosCharacteristic) {
            print('Found Anti Dos characteristic');
            _antiDosChar = char;
          }
          if (char.uuid == WakeCharacteristic) {
            print('Found wake characteristic');
            _wakeChar = char;
          }
          if (char.uuid == TXPowerCharacteristic) {
            print('Found tx power characteristic');
            _txChar = char;
          }
        }
        if (service.uuid == RobotControlService) {
          if (char.uuid == CommandsCharacteristic) {
            print('Found commands characteristic');
            _commandChar = char;
          }
          if (char.uuid == ResponseCharacteristic) {
            print('Found response characteristic');
            _responseChar = char;
          }
        }
      }
    }
    return devModeOn();
  }

  Future<void> _connectBLE() async {
    if (!await peripheral.isConnected()) {
      await peripheral.connect(isAutoConnect: true);
      isConnected = true;
    }
  }

  // Future<void> writeServiceCharacteristic(
  //   String serviceId,
  //   String characteristicId,
  //   Uint8List data,
  //   bool withResponse,
  // ) async {
  //   await peripheral.writeCharacteristic(
  //       serviceId, characteristicId, data, true);
  // }
}
