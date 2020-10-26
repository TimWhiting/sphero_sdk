import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
export 'package:flutter_ble_lib/flutter_ble_lib.dart' show Peripheral;
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:sphero_sdk/src/commands/decoder.dart';
import 'package:sphero_sdk/src/commands/index.dart';
import 'package:sphero_sdk/src/commands/types.dart';
import 'package:sphero_sdk/src/toys/queue.dart';
import 'package:sphero_sdk/src/toys/types.dart';
import 'package:sphero_sdk/src/toys/utils.dart';

class QueuePayload {
  Command command;
  Characteristic characteristic;
  QueuePayload({this.characteristic, this.command});
}

class Event {
  static const String onCollision = 'onCollision';
  static const String onSensor = 'onSensor';
}

/// The core class handling most basic functionality
class Core {
  /// Override in child class to get right percent
  double maxVoltage = 0;
  double minVoltage = 1;
  APIVersion apiVersion = APIVersion.V2;

  Device commands;
  Peripheral peripheral;
  Characteristic apiV2Characteristic;
  Characteristic dfuControlCharacteristic;
  Characteristic subsCharacteristic;
  Characteristic antiDoSCharacteristic;
  Function(int) decoder;
  bool started;
  Queue<QueuePayload> queue;
  Completer<void> initCompleter;
  Map<String, Future<void> Function(dynamic args)> eventsListeners;
  SensorMaskRaw sensorMask = SensorMaskRaw(v2: [], v21: []);

  Core(this.peripheral);

  /// Determines and returns the current battery charging state
  Future<double> batteryVoltage() async {
    final response = await queueCommand(commands.power.batteryVoltage());
    return number(response.command.payload, 1) / 100;
  }

  /// returns battery level from [0, 1] range.
  ///  Child class must implement max voltage and min voltage to get correct %
  Future<double> batteryLevel() async {
    final voltage = await batteryVoltage();
    final percent = (voltage - minVoltage) / (maxVoltage - minVoltage);
    return percent > 1 ? 1 : percent;
  }

  /// Wakes up the toy from sleep mode
  Future<void> wake() {
    return queueCommand(commands.power.wake());
  }

  /// Sets the to into sleep mode
  Future<void> sleep() {
    return queueCommand(commands.power.sleep());
  }

  /// Starts the toy
  Future<void> start() async {
    print('start-start');
    // start
    await init();

    print('start-usetheforce...band');
    await write(antiDoSCharacteristic, 'usetheforce...band');

    // TODO: This
    print('start-dfuControlCharacteristic-subscribe');
    dfuControlCharacteristic.monitor();
    print('start-apiV2Characteristic-subscribe');
    apiV2Characteristic.monitor();

    started = true;

    try {
      print('start-wake');
      await wake();
    } catch (e) {
      print('error $e');
    }
    print('start-end');
  }

  /// Determines and returns the system app version of the toy
  Future<Map<String, dynamic>> appVersion() async {
    final response = await queueCommand(commands.systemInfo.appVersion());
    return {
      'major': number(response.command.payload, 1),
      'minor': number(response.command.payload, 3)
    };
  }

  void on(String eventName, void Function(Command) handler) {
    eventsListeners[eventName] = handler;
  }

  Future<void> destroy() async {
    // TODO handle all unbind, disconnect, etc
    eventsListeners = {}; // remove references
    await peripheral.disconnectOrCancelConnection();
  }

  Future<void> configureSensorStream() async {
    // save it so on response we can parse it
    final sensorMask = sensorValuesToRaw([
      SensorMaskValues.accelerometer,
      SensorMaskValues.orientation,
      SensorMaskValues.locator,
      SensorMaskValues.gyro
    ], apiVersion);

    await queueCommand(commands.sensor.sensorMask(
        flatSensorMask(sensorMask.v2), SensorControlDefaults.interval));
    if (sensorMask.v21.length > 0) {
      await queueCommand(
          commands.sensor.sensorMaskExtended(flatSensorMask(sensorMask.v21)));
    }
  }

  Future<QueuePayload> enableCollisionDetection() {
    return queueCommand(commands.sensor.enableCollisionAsync());
  }

  Future<QueuePayload> configureCollisionDetection({
    int xThreshold = 100,
    int yThreshold = 100,
    int xSpeed = 100,
    int ySpeed = 100,
    int deadTime = 10,
    int method = 0x01,
  }) async {
    return queueCommand(commands.sensor.configureCollision(
        xThreshold, yThreshold, xSpeed, ySpeed, deadTime,
        method: method));
  }

  Future<QueuePayload> queueCommand(Command command) async {
    return queue.queue(
        QueuePayload(characteristic: apiV2Characteristic, command: command));
  }

  Future<void> init() async {
    print('init-start');
    final p = peripheral;

    initCompleter = Completer();

    queue = Queue<QueuePayload>(
      QueueListener(
          match: (cA, cB) => match(cA, cB),
          onExecute: (item) => onExecute(item)),
    );
    eventsListeners = {};
    commands = commandsFactory();
    decoder = decodeFactory((error, [packet]) => onPacketRead(error, packet));
    started = false;

    print('init-connect');
    await p.connect(isAutoConnect: true);

    print('init-discoverAllServicesAndCharacteristics');
    await p.discoverAllServicesAndCharacteristics();

    await bindServices();
    await bindListeners();

    print('init-done');
  }

  Future<void> onExecute(QueuePayload item) async {
    if (!started) {
      return;
    }

    await write(item.characteristic, item.command.raw);
  }

  match(QueuePayload commandA, QueuePayload commandB) {
    return (commandA.command.deviceId == commandB.command.deviceId &&
        commandA.command.commandId == commandB.command.commandId &&
        commandA.command.sequenceNumber == commandB.command.sequenceNumber);
  }

  Future<void> bindServices() async {
    print('bindServices');
    final services = await peripheral.services();
    for (final s in services) {
      final characteristics = await s.characteristics();
      characteristics.forEach((c) {
        if (c.uuid == CharacteristicUUID.antiDoSCharacteristic) {
          antiDoSCharacteristic = c;
          print('bindServices antiDoSCharacteristic found $c');
        } else if (c.uuid == CharacteristicUUID.apiV2Characteristic) {
          apiV2Characteristic = c;
          print('bindServices apiV2Characteristic found $c');
        } else if (c.uuid == CharacteristicUUID.dfuControlCharacteristic) {
          dfuControlCharacteristic = c;
          print('bindServices dfuControlCharacteristic found $c');
        } else if (c.uuid == CharacteristicUUID.subsCharacteristic) {
          subsCharacteristic = c;
        }
      });
    }
  }

  Future<void> bindListeners() async {
    print('bindListeners');
    // TODO: Figure this out
    assert(apiV2Characteristic != null);
    assert(dfuControlCharacteristic != null);
    apiV2Characteristic
        .monitor(transactionId: 'read')
        .listen((Uint8List data) => onApiRead(data));
    apiV2Characteristic
        .monitor(transactionId: 'notify')
        .listen((Uint8List data) => onApiNotify(data));
    dfuControlCharacteristic
        .monitor(transactionId: 'notify')
        .listen((Uint8List data) => onDFUControlNotify(data));
  }

  void onPacketRead(String error, Command command) {
    if (error != null) {
      print('There was a parse error $error');
    } else if (command.sequenceNumber == 255) {
      print('onEvent $error $command');
      eventHandler(command);
    } else {
      print('onPacketRead $error $command');
      queue.onCommandProcessed(QueuePayload(command: command));
    }
  }

  void eventHandler(Command command) {
    if (command.deviceId == DeviceId.sensor &&
        command.commandId == SensorCommandIds.collisionDetectedAsync) {
      handleCollision(command);
    } else if (command.deviceId == DeviceId.sensor &&
        command.commandId == SensorCommandIds.sensorResponse) {
      handleSensorUpdate(command);
    } else {
      print('UNKOWN EVENT ${command.raw}');
    }
  }

  void handleCollision(Command command) {
    // TODO parse collision
    final handler = eventsListeners[Event.onCollision];
    if (handler != null) {
      handler(command);
    } else {
      print('No handler for collision but collision was detected');
    }
  }

  void handleSensorUpdate(Command command) {
    final handler = eventsListeners[Event.onSensor];
    if (handler != null) {
      final parsedEvent = parseSensorEvent(command.payload, sensorMask);
      handler(parsedEvent);
    } else {
      print('No handler for collision but collision was detected');
    }
  }

  void onApiRead(Uint8List data) {
    data.forEach((byte) => decoder(byte));
  }

  void onApiNotify(dynamic data) {
    if (initCompleter.isCompleted) {
      print('onApiNotify $data');
      initCompleter.complete();
      return;
    }
  }

  Future<dynamic> onDFUControlNotify(dynamic data) {
    print('onDFUControlNotify $data');
    return write(dfuControlCharacteristic, Uint8List.fromList([0x30]));
  }

  Future<dynamic> write(Characteristic c, dynamic data) async {
    Uint8List buff;
    if (data is String) {
      buff = Uint8List.fromList(utf8.encode(data));
    } else {
      buff = Uint8List.fromList(data);
    }
    print('write $data');
    return await c.write(buff, true);
  }
}
