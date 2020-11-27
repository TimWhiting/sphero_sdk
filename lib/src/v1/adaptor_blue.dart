import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_blue/flutter_blue.dart';

import 'adaptor.dart';

class AdaptorV1Blue extends AdaptorV1 {
  AdaptorV1Blue(String id, [this.peripheral])
      : uuid = id.split(':').join('').toLowerCase(),
        super.empty();
  static final BLEService = Guid('22bb746f-2bb0-7554-2d6f-726568705327');
  static final WakeCharacteristic =
      Guid('22bb746f-2bbf-7554-2d6f-726568705327');
  static final TXPowerCharacteristic =
      Guid('22bb746f-2bb2-7554-2d6f-726568705327');
  static final AntiDosCharacteristic =
      Guid('22bb746f-2bbd-7554-2d6f-726568705327');
  static final RobotControlService =
      Guid('22bb746f-2ba0-7554-2d6f-726568705327');
  static final CommandsCharacteristic =
      Guid('22bb746f-2ba1-7554-2d6f-726568705327');
  static final ResponseCharacteristic =
      Guid('22bb746f-2ba6-7554-2d6f-726568705327');

  BluetoothCharacteristic _antiDosChar;
  BluetoothCharacteristic _wakeChar;
  BluetoothCharacteristic _txChar;
  BluetoothCharacteristic _commandChar;
  BluetoothCharacteristic _responseChar;

  final String uuid;
  bool isConnected = false;
  BluetoothDevice peripheral;

  @override
  Future<void> open() async {
    if (peripheral != null) {
      await _connectPeripheral();
    } else {
      final completer = Completer<void>();
      final bleManager = FlutterBlue.instance;
      var completed = false;

      bleManager.scan(timeout: const Duration(seconds: 10)).listen((sr) {
        if (sr.advertisementData.localName == uuid && !completed) {
          peripheral = sr.device;
          completed = true;
          _connectPeripheral().then((_) => completer.complete());
        }
      });
      return completer.future;
    }
  }

  @override
  Future<void> write(Uint8List data) => _commandChar.write(data);
  @override
  Future<void> close() async {
    await peripheral.disconnect();
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
    await _responseChar.setNotifyValue(true);
    _responseChar.value.asBroadcastStream().listen(
      (cWithValue) {
        final data = cWithValue;
        if (data != null && data.length > 5) {
          try {
            onRead(Uint8List.fromList(data));
          } on Exception catch (e) {
            print('Caught exception $e while reading');
          }
        }
      },
      onError: (e) =>
          print('Error: $e while monitoring the response characteristic'),
      onDone: () => print(
        '''
#########################################
Done monitoring response characteristic
#########################################''',
      ),
      cancelOnError: false,
    );
  }

  Future<void> wake() => _wakeChar.write([1]);
  // writeServiceCharacteristic(
  //  BLEService, WakeCharacteristic, Uint8List.fromList([1]), false);

  Future<void> setTXPower(int level) => _txChar.write([level]);
  //writeServiceCharacteristic(
  //  BLEService, TXPowerCharacteristic, Uint8List.fromList([level]), false);

  Future<void> setAntiDos() {
    const str = '011i3';
    final bytes = Uint8List.fromList(utf8.encode(str));
    return _antiDosChar.write(bytes); //writeServiceCharacteristic(
    //BLEService, AntiDosCharacteristic, bytes, false);
  }

  Future<void> _connectPeripheral() async {
    print('connecting peripheral');
    await _connectBLE();
    final services = await peripheral.discoverServices();
    for (final service in services) {
      for (final char in service.characteristics) {
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
    final state = await peripheral.state.first;
    if (state != BluetoothDeviceState.connected) {
      await peripheral.connect(timeout: const Duration(seconds: 2));
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
