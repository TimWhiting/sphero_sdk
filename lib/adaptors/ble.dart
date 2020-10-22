import 'package:flutter_ble_lib/flutter_ble_lib.dart';

class Peripheral {
  var peripheral;
  var services = {};
  Peripheral(this.peripheral, this.services);
}

class Adaptor {
  static const BLEService = "22bb746f2bb075542d6f726568705327",
      WakeCharacteristic = "22bb746f2bbf75542d6f726568705327",
      TXPowerCharacteristic = "22bb746f2bb275542d6f726568705327",
      AntiDosCharacteristic = "22bb746f2bbd75542d6f726568705327",
      RobotControlService = "22bb746f2ba075542d6f726568705327",
      CommandsCharacteristic = "22bb746f2ba175542d6f726568705327",
      ResponseCharacteristic = "22bb746f2ba675542d6f726568705327";
  var uuid;
  Peripheral peripheral;
  var connectedPeripherals = {};
  var isConnected = false;
  var readHandler;
  final bleManager = BleManager();
  Adaptor(peripheralId, options) {
    uuid = peripheralId.split(":").join("").toLowerCase();
    var opts = options ?? {};
    peripheral = opts['peripheral'] ?? null;
    init();
  }
  Future<void> init() async {
    await bleManager.createClient();
  }

  open(callback) {
    if (peripheral == null) {
      //peripheral was passed in
      _connectPeripheral(peripheral, callback);
    } else {
      //need to discover
      bleManager.observeBluetoothState().listen((state) {
        if (state == BluetoothState.POWERED_ON) {
          bleManager.startPeripheralScan(
              scanMode: ScanMode.lowPower,
              callbackType: CallbackType.allMatches,
              uuids: [uuid]).listen((result) {
            bleManager.stopPeripheralScan();
            final peripheral = result.peripheral;
            peripheral
                .connect()
                .then((device) => _connectPeripheral(peripheral, callback));
          });
        } else if (state == BluetoothState.POWERED_OFF) {
          connectedPeripherals = {};
        }
      });
    }
  }

  write(data, callback) {
    writeServiceCharacteristic(
        RobotControlService, CommandsCharacteristic, data, callback);
  }

  onRead(callback) {
    readHandler = callback;
  }

  close(callback) {
    callback();
  }

  wake(callback) {
    writeServiceCharacteristic(BLEService, WakeCharacteristic, 1, callback);
  }

  setTXPower(level, callback) {
    writeServiceCharacteristic(
        BLEService, TXPowerCharacteristic, level, callback);
  }

  setAntiDos(callback) {
    var str = "011i3";
    var bytes = [];
    for (var i = 0; i < str.length; ++i) {
      bytes.insert(0, str.codeUnitAt(i));
    }
    writeServiceCharacteristic(
        BLEService, AntiDosCharacteristic, bytes, callback);
  }

  readServiceCharacteristic(serviceId, characteristicId, callback) {
    getCharacteristic(serviceId, characteristicId, (error, c) {
      if (error) {
        return callback(error);
      }
      c.read(callback);
    });
  }

  writeServiceCharacteristic(serviceId, characteristicId, value, callback) {
    getCharacteristic(serviceId, characteristicId, (error, c) {
      if (error) {
        return callback(error);
      }
      c.write(value, true, () {
        if (callback != null) {
          callback(null);
        }
      });
    });
  }

  getCharacteristic(serviceId, characteristicId, callback) {
    _connectBLE(() {
      _connectService(serviceId, (error) {
        if (error) {
          callback(error, null);
        }
        _connectCharacteristic(
            serviceId, characteristicId, (e, c) => callback(e, c));
      });
    });
  }

  _connectPeripheral(np, callback) {
    peripheral = np;
    var p = Peripheral(peripheral, {});
    connectedPeripherals[this.uuid] = p;
    devModeOn(() => callback());
  }

  _connectBLE(callback) {
    var p = _connectedPeripheral();
    if (p.state == "connected") {
      callback();
    } else {
      p.connect(() {
        isConnected = true;
        callback();
      });
    }
  }

  _connectService(serviceId, callback) async {
    var p = _connectedPeripheral();
    if (_connectedServices()) {
      callback(null, _connectedService(serviceId));
    } else {
      final services = peripheral.services;
      if (services.length > 0) {
        var service = _connectedService(serviceId);
        callback(null, service);
      } else {
        callback("No services found", null);
      }
    }
  }

  _connectCharacteristic(serviceId, characteristicId, callback) {
    if (_connectedCharacteristics(serviceId)) {
      callback(null, _connectedCharacteristic(serviceId, characteristicId));
    } else {
      var s = _connectedService(serviceId);
      FlutterBleLib.instance
          .characteristicsForService(s)
          .then((characteristics) {
        if (characteristics.length > 0) {
          var characteristic =
              _connectedCharacteristic(serviceId, characteristicId);
          callback(null, characteristic);
        } else {
          callback("No characteristics found", null);
        }
      }).catchError((error) {
        callback("Error");
      });
    }
  }

  _connectedPeripheral() {
    return connectedPeripherals[this.uuid].peripheral;
  }

  _connectedServices() {
    var p = this._connectedPeripheral();

    if (p.state != "connected") {
      return null;
    }

    return p.services;
  }

  _connectedService(serviceId) {
    var services = _connectedServices();
    for (var s in services) {
      if (services[s].uuid == serviceId) {
        return services[s];
      }
    }
    return null;
  }

  _connectedCharacteristics(serviceId) {
    return _connectedService(serviceId).characteristics;
  }

  _connectedCharacteristic(serviceId, characteristicId) {
    var characteristics = _connectedCharacteristics(serviceId);
    for (var c in characteristics) {
      if (characteristics[c].uuid == characteristicId) {
        return characteristics[c];
      }
    }
    return null;
  }

  devModeOn(callback) {
    setAntiDos(() {
      setTXPower(7, () {
        wake(() {
          getCharacteristic(RobotControlService, ResponseCharacteristic,
              (e, c) {
            if (e) {
              return callback(e);
            }
            c.on("read", (data) {
              if (data && data.length > 5) {
                readHandler(data);
              }
            });
            c.notify(true, () => callback());
          });
        });
      });
    });
  }
}
