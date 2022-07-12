// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';

import 'adaptor.dart';

class AdaptorV1Blue extends AdaptorV1 {
  AdaptorV1Blue(String id, [this.peripheral])
      : uuid = id.split(':').join().toLowerCase(),
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

  late BluetoothCharacteristic _antiDosChar;
  late BluetoothCharacteristic _wakeChar;
  late BluetoothCharacteristic _txChar;
  late BluetoothCharacteristic _commandChar;
  late BluetoothCharacteristic _responseChar;

  final String uuid;
  bool isConnected = false;
  @override
  BluetoothDevice? peripheral;

  @override
  Future<void> open() async {
    if (peripheral != null) {
      await _connectPeripheral();
    } else {
      final completer = Completer<void>();
      final bleManager = FlutterBlue.instance;
      var completed = false;

      bleManager.startScan(timeout: const Duration(seconds: 10)).listen((sr) {
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
  Future<void> write(Uint8List data) {
    try {
      return _commandChar.write(data, withoutResponse: true);
    } on Exception catch (e) {
      print(e);
    }
    return Future.value();
  }

  @override
  Future<void> close() async {
    peripheral?.disconnect();
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
        if (data.length > 5) {
          try {
            onRead(Uint8List.fromList(data));
          } on Exception catch (e) {
            print('Caught exception $e while reading');
          }
        }
      },
      onError: (Object? e) =>
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

  Future<void> setTXPower(int level) => _txChar.write([level]);

  Future<void> setAntiDos() {
    const str = '011i3';
    final bytes = Uint8List.fromList(utf8.encode(str));
    return _antiDosChar.write(bytes);
  }

  Future<void> _connectPeripheral() async {
    print('connecting peripheral');
    await _connectBLE();
    final services = await peripheral!.discoverServices();
    for (final service in services) {
      for (final char in service.characteristics) {
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
    await peripheral!.connect(timeout: const Duration(seconds: 6));
    isConnected = true;
  }
}
