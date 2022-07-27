// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_blue/flutter_blue.dart';

import '../commands/index.dart';
import 'queue.dart';
import 'types.dart';
import 'utils.dart';

export '../commands/index.dart';
export 'utils.dart';

class QueuePayload {
  QueuePayload({required this.command, this.characteristic});
  Command command;
  BluetoothCharacteristic? characteristic;
}

class Event {
  static const String onCollision = 'onCollision';
  static const String onSensor = 'onSensor';
}

/// The core class handling most basic functionality
class Core {
  Core(this.peripheral);

  /// Override in child class to get right percent
  double maxVoltage = 0;
  double minVoltage = 1;
  APIVersion apiVersion = APIVersion.V2;

  late final Device commands;
  BluetoothDevice peripheral;
  late final BluetoothCharacteristic apiV2Characteristic;
  late final BluetoothCharacteristic dfuControlCharacteristic;
  late final BluetoothCharacteristic subsCharacteristic;
  late final BluetoothCharacteristic antiDoSCharacteristic;
  late final Function(int) decoder;
  bool started = false;
  late final Queue<QueuePayload> queue;
  final initCompleter = Completer<void>();
  final eventsListeners = <String, Future<void> Function(Object? args)>{};
  final sensorMask = SensorMaskRaw(v2: [], v21: []);

  Future<void> init() async {
    print('init-start');
    final p = peripheral;

    queue = Queue<QueuePayload>(
      QueueListener(match: match, onExecute: onExecute),
    );
    commands = commandsFactory();
    // ignore: unnecessary_lambdas
    decoder = decodeFactory((error, [packet]) => onPacketRead(error, packet));

    print('init-connect');
    await p.connect();

    print('init-discoverAllServicesAndCharacteristics');
    await p.discoverServices();

    await bindServices();
    await bindListeners();

    print('init-done');
  }

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
  Future<void> wake() => queueCommand(commands.power.wake());

  /// Sets the to into sleep mode
  Future<void> sleep() => queueCommand(commands.power.sleep());

  /// Starts the toy
  Future<void> start() async {
    print('start-start');
    // start
    await init();

    print('start-usetheforce...band');
    await write(antiDoSCharacteristic, 'usetheforce...band');

    // TODO: This
    print('start-dfuControlCharacteristic-subscribe');
    await dfuControlCharacteristic.setNotifyValue(true);
    print('start-apiV2Characteristic-subscribe');
    await apiV2Characteristic.setNotifyValue(true);

    started = true;

    try {
      print('start-wake');
      await wake();
    } on Exception catch (e) {
      print('error $e');
    }
    print('start-end');
  }

  /// Determines and returns the system app version of the toy
  Future<Map<String, int>> appVersion() async {
    final response = await queueCommand(commands.systemInfo.appVersion());
    return <String, int>{
      'major': number(response.command.payload, 1),
      'minor': number(response.command.payload, 3)
    };
  }

  void on(String eventName, Future<void> Function(Object?) handler) {
    eventsListeners[eventName] = handler;
  }

  Future<void> destroy() async {
    // TODO handle all unbind, disconnect, etc
    eventsListeners.clear(); // remove references
    await peripheral.disconnect();
  }

  Future<void> configureSensorStream() async {
    // save it so on response we can parse it
    final sensorMask = sensorValuesToRaw(
      [
        SensorMaskValues.accelerometer,
        SensorMaskValues.orientation,
        SensorMaskValues.locator,
        SensorMaskValues.gyro
      ],
      apiVersion,
    );

    await queueCommand(
      commands.sensor.sensorMask(
        flatSensorMask(sensorMask.v2),
        SensorControlDefaults.interval,
      ),
    );
    if (sensorMask.v21.isNotEmpty) {
      await queueCommand(
        commands.sensor.sensorMaskExtended(flatSensorMask(sensorMask.v21)),
      );
    }
  }

  Future<QueuePayload> enableCollisionDetection() =>
      queueCommand(commands.sensor.enableCollisionAsync());

  Future<QueuePayload> configureCollisionDetection({
    int xThreshold = 100,
    int yThreshold = 100,
    int xSpeed = 100,
    int ySpeed = 100,
    int deadTime = 10,
    int method = 0x01,
  }) =>
      queueCommand(
        commands.sensor.configureCollision(
          xThreshold,
          yThreshold,
          xSpeed,
          ySpeed,
          deadTime,
          method: method,
        ),
      );

  Future<QueuePayload> queueCommand(Command command) => queue.queue(
        QueuePayload(characteristic: apiV2Characteristic, command: command),
      );

  Future<void> onExecute(QueuePayload item) async {
    if (!started) {
      return;
    }

    await write(item.characteristic!, item.command.raw);
  }

  bool match(QueuePayload commandA, QueuePayload commandB) =>
      commandA.command.deviceId == commandB.command.deviceId &&
      commandA.command.commandId == commandB.command.commandId &&
      commandA.command.sequenceNumber == commandB.command.sequenceNumber;

  Future<void> bindServices() async {
    print('bindServices');
    final services = await peripheral.services.first;
    for (final s in services) {
      final characteristics = s.characteristics;
      for (final c in characteristics) {
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
      }
    }
  }

  Future<void> bindListeners() async {
    print('bindListeners');
    // TODO: Figure this out
    await apiV2Characteristic.setNotifyValue(true);
    apiV2Characteristic.value.listen(onApiRead);
    await dfuControlCharacteristic.setNotifyValue(true);
    dfuControlCharacteristic.value.listen(onDFUControlNotify);
  }

  void onPacketRead(String? error, Command? command) {
    if (error != null) {
      print('There was a parse error $error');
    } else if (command!.sequenceNumber == 255) {
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
      print('UNKNOWN EVENT ${command.raw}');
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

  void onApiRead(List<int> data) {
    // ignore: avoid_function_literals_in_foreach_calls
    data.forEach(decoder);
  }

  void onApiNotify(Object? data) {
    if (initCompleter.isCompleted) {
      print('onApiNotify $data');
      initCompleter.complete();
      return;
    }
  }

  Future<Object?> onDFUControlNotify(Object? data) {
    print('onDFUControlNotify $data');
    return write(dfuControlCharacteristic, Uint8List.fromList([0x30]));
  }

  Future<Object?> write(BluetoothCharacteristic c, Object? data) async {
    Uint8List buff;
    if (data is String) {
      buff = Uint8List.fromList(utf8.encode(data));
    } else {
      buff = Uint8List.fromList(data as List<int>);
    }
    print('write $data');
    return c.write(buff, withoutResponse: true);
  }
}
