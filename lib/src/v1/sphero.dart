import 'dart:async';
import 'dart:typed_data';

import 'adaptor.dart';
import 'devices/core.dart';
import 'devices/custom.dart';
import 'packet.dart';

export 'devices/core.dart';
export 'devices/custom.dart';
export 'devices/sphero.dart';

class SOP2 {
  static const answer = 0xFD;
  static const resetTimeout = 0xFE;
  static const both = 0xFF;
  static const none = 0xFC;
  static const sync = 0xFF;
  static const async = 0xFE;
}

class CommandQueueItemV1 {
  CommandQueueItemV1({required this.packet, required this.completer});

  final PacketV1 packet;
  final Completer<Map<String, Object?>> completer;
}

class Sphero extends SpheroBase with Custom {
  /// Creates a new sphero instance, from the specified [address] or [adaptor].
  ///
  /// Additional options are the [sop2] field, the [timeout] or deadtime between
  /// commands, and whether to [emitPacketErrors]. If a bluetooth [peripheral]
  /// is already obtained and [adaptor] is `null` then an [adaptor] will
  /// be created from that.
  Sphero(
    this.address, {
    AdaptorV1? adaptor,
    int? sop2 = SOP2.answer,
    this.timeout = 500,
    this.emitPacketErrors = false,
    SpheroPeripheral? peripheral,
  }) {
    connection = adaptor ?? AdaptorV1(address, peripheral!);
    sop2Bitfield = sop2 ?? SOP2.both;
  }
  final String address;
  bool busy = false;
  bool ready = false;
  final packet = PacketParser();
  late AdaptorV1 connection;
  final responseQueue = <int, CommandQueueResponseItem>{};
  final commandQueue = <CommandQueueItemV1>[];
  late int sop2Bitfield;
  int seqCounter = 0;
  int timeout;
  final bool emitPacketErrors;

  ///
  /// Establishes a connection to Sphero.
  ///
  /// Once connected, commands can be sent to Sphero.
  ///
  /// ```dart
  /// await orb.connect();
  /// // Sphero is connected, tell it to do stuff!
  /// orb.color('magenta');
  /// ```

  Future<void> connect() async {
    connection.onRead = (payload) {
      print('Got payload $payload');
      emit('data', payload);
      final parsedPayload = packet.parse(payload);
      print('Parsed $parsedPayload');
      Map<String, Object?>? parsedData;

      if (parsedPayload!.sop2 == SOP2.sync) {
        // synchronous packet
        emit('response', parsedPayload);
        final cmd = _responseCmd(parsedPayload.seq);
        print('response for command $cmd');
        parsedPayload.printPacket();
        parsedData = packet.parseResponseData(cmd!, parsedPayload);

        _execCallback(parsedPayload.seq, parsedData);
      } else if (parsedPayload.sop2 == SOP2.async) {
        // async packet
        parsedData = packet.parseAsyncData(parsedPayload, ds);
        emit('async', parsedData);
      }

      if (parsedData?['event'] != null) {
        emit(parsedData!['event'] as String, parsedData);
      }
    };
    await connection.open();
    ready = true;
  }

  /// Ends the connection to Sphero.
  ///
  /// After this is complete, no further commands can be sent to Sphero.
  ///
  /// @param {Function} callback function to be triggered once disconnected
  /// @example
  /// orb.disconnect(function() {
  ///   console.log('Now disconnected from Sphero');
  /// });
  /// @return {void}
  Future<void> disconnect() => connection.close();

  /// Adds a command to the queue and calls for the next command in the queue
  /// to try to execute.
  @override
  Future<Map<String, Object?>> baseCommand(
    int vDevice,
    int cmdName,
    Uint8List? data,
  ) {
    final seq = _incSeq();
    final completer = Completer<Map<String, Object?>>();
    final cmdPacket = packet.create(
      sop2: sop2Bitfield,
      did: vDevice,
      cid: cmdName,
      seq: seq,
      data: data,
    );
    _queueCommand(cmdPacket, completer);
    _execCommand();
    return completer.future;
  }

  /// Adds a sphero [command] to the queue, with a [completer] that completes
  /// when the response comes back
  void _queueCommand(
    PacketV1 command,
    Completer<Map<String, Object?>> completer,
  ) {
    if (commandQueue.length == 256) {
      commandQueue.removeAt(0);
    }
    commandQueue.add(CommandQueueItemV1(packet: command, completer: completer));
  }

  /// Tries to execute the next command in the queue if sphero not busy
  /// and there's something in the queue.
  void _execCommand() {
    CommandQueueItemV1 cmd;
    if (!busy && commandQueue.isNotEmpty) {
      // Get the seq number from the cmd packet/buffer
      // to store the callback response in that position
      busy = true;
      cmd = commandQueue.removeAt(0);
      _queueFuture(cmd.packet, cmd.completer);
      print('Writing command');
      cmd.packet.printPacket();
      connection.write(cmd.packet.packet);
    }
  }

  /// Adds a Future to the queue, to be executed when a response
  /// gets back from the sphero.
  void _queueFuture(
    PacketV1 cmdPacket,
    Completer<Map<String, Object?>> completer,
  ) {
    final seq = cmdPacket.seq;

    // ignore: prefer_function_declarations_over_variables, avoid_types_on_closure_parameters
    final handler = (Map<String, Object?>? packet) {
      final item = responseQueue.remove(seq);
      item?.timer?.cancel();
      busy = false;
      if (!completer.isCompleted) {
        if (packet != null) {
          completer.complete(packet);
        } else {
          final error = Exception('Command sync response was lost.');
          completer.completeError(error);
        }
      }
      _execCommand();
    };

    final response = CommandQueueResponseItem(
      handler: handler,
      commandID: CommandID(did: cmdPacket.did, cid: cmdPacket.cid),
    );
    response.timer = Timer(Duration(milliseconds: timeout), () {
      responseQueue.remove(seq);
      if (!completer.isCompleted) {
        completer.completeError('Sphero command timeout $cmdPacket');
      }
    });
    responseQueue[seq] = response;
  }

  /// Executes a handler from the queue, usually when we get a response
  /// back from the sphero or the deadtime for the commands sent expires.
  ///
  /// Based on the [seq] number of the response, and the parsed [packet]
  void _execCallback(int seq, Map<String, Object?> packet) {
    final response = responseQueue[seq];

    if (response != null) {
      response.handler(packet);
    }
  }

  /// Returns the response [CommandID] (did, cid) passed to the sphero
  /// based on the [seq] from the response (used for parsing responses).
  CommandID? _responseCmd(int seq) {
    final response = responseQueue[seq];
    if (response != null) {
      return response.commandID;
    }
    return null;
  }

  /// Auto-increments seq counter for command and callback queues.
  int _incSeq() {
    final seq = seqCounter;
    seqCounter++;
    if (seqCounter > 255) {
      seqCounter = 0;
    }
    return seq;
  }
}

class CommandQueueResponseItem {
  CommandQueueResponseItem({required this.handler, required this.commandID});

  final Function(Map<String, Object?>) handler;
  final CommandID commandID;
  Timer? timer;
}
