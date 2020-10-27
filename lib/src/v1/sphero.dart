import 'dart:async';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:sphero_sdk/src/v1/devices/custom.dart';
import 'package:sphero_sdk/src/v1/packet.dart';

import 'adaptor.dart';
import 'devices/core.dart';
import 'devices/sphero.dart';

class SOP2 {
  static const answer = 0xFD;
  static const resetTimeout = 0xFE;
  static const both = 0xFF;
  static const none = 0xFC;
  static const sync = 0xFF;
  static const async = 0xFE;
}

class CommandQueueItemV1 {
  final PacketV1 packet;
  final Completer<Map<String, dynamic>> completer;
  CommandQueueItemV1({this.packet, this.completer});
}

load(String address) {}

///
/// Creates a new sphero instance
///
/// @constructor
/// @private
/// @param {String} address of the connected sphero
/// @param {Object} opts for sphero setup
/// @param {Object} [opts.adaptor=serial] sets the adaptor for the connection
/// @param {Number} [opts.sop2=0xFD] sop2 to be passed to commands
/// @param {Number} [opts.timeout=500] deadtime between commands, in ms
/// @param {Boolean} [opts.emitPacketErrors=false] emit events on packet errors
/// @param {Object} [opts.peripheral=object] use an existing Noble peripheral
/// @example
/// var orb = new Sphero("/dev/rfcomm0", { timeout: 300 });
/// @returns {Sphero} a new instance of Sphero
class Sphero extends SpheroBase with Core, SpheroDevice, Custom {
  final String address;
  bool busy = false;
  bool ready = false;
  final packet = PacketParser();
  AdaptorV1 connection;
  final responseQueue = <int, CommandQueueResponseItem>{};
  final commandQueue = <CommandQueueItemV1>[];
  int sop2Bitfield;
  int seqCounter = 0;
  int timeout;
  final bool emitPacketErrors;
  Sphero(
    this.address, {
    AdaptorV1 adaptor,
    int sop2 = 0xFD,
    this.timeout = 500,
    this.emitPacketErrors = false,
    Peripheral peripheral,
  }) {
    // check that we were called with 'new'
    connection = adaptor ?? load(address);
    sop2Bitfield = sop2 ?? SOP2.both;
  }
  void emit(String name, [dynamic data]) {}

  ///
  /// Establishes a connection to Sphero.
  ///
  /// Once connected, commands can be sent to Sphero.
  ///
  /// @param {Function} callback function to be triggered once connected
  /// @example
  /// orb.connect(function() {
  ///   // Sphero is connected, tell it to do stuff!
  ///   orb.color("magenta");
  /// });
  /// @return {void}

  Future<void> connect() async {
    // connection.on("open", () {
    //   emit("open");
    // });
    // connection.on("close", emit("close"));

    // connection.on("error", () {
    //   emit("error");
    // });
    // packet.on("error", emit("error"));

    connection.onRead = (payload) {
      emit("data", payload);

      PacketV1 parsedPayload = packet.parse(payload);
      Map<String, dynamic> parsedData;
      Map<String, int> cmd;

      if (parsedPayload != null && parsedPayload.sop1 != null) {
        if (parsedPayload.sop2 == SOP2.sync) {
          // synchronous packet
          emit("response", parsedPayload);
          cmd = _responseCmd(parsedPayload.seq);
          parsedData = packet.parseResponseData(cmd, parsedPayload);
          _execCallback(parsedPayload.seq, parsedData);
        } else if (parsedPayload.sop2 == SOP2.async) {
          // async packet
          parsedData = packet.parseAsyncData(parsedPayload, ds);
          emit("async", parsedData);
        }

        if (parsedData != null && parsedData['event']) {
          emit(parsedData['event'], parsedData);
        }
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
  ///   console.log("Now disconnected from Sphero");
  /// });
  /// @return {void}
  Future<void> disconnect() async => await connection.close();

  /// Adds a command to the queue and calls for the next command in the queue
  /// to try to execute.
  ///
  /// @private
  /// @param {Number} vDevice the virtual device address
  /// @param {Number} cmdName the command to execute
  /// @param {Array} data to be passed to the command
  /// @param {Function} callback function to be triggered once disconnected
  /// @example
  /// sphero.command(0x00, 0x02, [0x0f, 0x01, 0xff], callback);
  /// @return {void}
  Future<Map<String, dynamic>> baseCommand(
      int vDevice, int cmdName, Uint8List data) {
    final completer = Completer<Map<String, dynamic>>();
    final cmdPacket = packet.create(
        sop2: sop2Bitfield,
        did: vDevice,
        cid: cmdName,
        seq: seqCounter,
        data: data);
    _queueCommand(cmdPacket, completer);
    _execCommand();
    return completer.future;
  }

  /// Adds a sphero command to the queue
  ///
  /// @private
  /// @param {Array} cmdPacket the bytes array to be send through the wire
  /// @param {Function} resolve function to be triggered on success
  /// @param {Function} reject function to be triggered on failure
  /// @example
  /// _queueCommand(cmdPacket, resolve, reject);
  /// @return {void}
  void _queueCommand(
      PacketV1 cmdPacket, Completer<Map<String, dynamic>> completer) {
    if (commandQueue.length == 256) {
      commandQueue.removeAt(0);
    }
    commandQueue
        .add(CommandQueueItemV1(packet: cmdPacket, completer: completer));
  }

  ///
  /// Tries to execute the next command in the queue if sphero not busy
  /// and there's something in the queue.
  ///
  /// @private
  /// @example
  /// sphero._execCommand();
  /// @return {void}
  void _execCommand() {
    CommandQueueItemV1 cmd;
    if (!busy && (commandQueue.length > 0)) {
      // Get the seq number from the cmd packet/buffer
      // to store the callback response in that position
      cmd = commandQueue.removeAt(0);
      busy = true;
      _queuePromise(cmd.packet, cmd.completer);
      connection.write(cmd.packet.packet);
    }
  }

  ///
  /// Adds a promise to the queue, to be executed when a response
  /// gets back from the sphero.
  ///
  /// @private
  /// @param {Array} cmdPacket the bytes array to be send through the wire
  /// @example
  /// sphero._execCommand(packet, resolve, reject);
  /// @return {void}
  _queuePromise(PacketV1 cmdPacket, Completer<Map<String, dynamic>> completer) {
    var seq = cmdPacket.seq;

    final handler = (err, Map<String, dynamic> packet) {
      responseQueue.remove(seq);
      busy = false;

      if (err == null && packet != null) {
        completer.complete(packet);
      } else {
        var error = Exception("Command sync response was lost.");
        completer.completeError(error);
      }

      _execCommand();
    };

    final response = CommandQueueResponseItem(
        handler: handler, did: cmdPacket.did, cid: cmdPacket.cid);
    response.timer = Timer(
        Duration(milliseconds: timeout), () => responseQueue.remove(response));
    responseQueue[seq] = response;
  }

  /// Executes a handler from the queue, usually when we get a response
  /// back from the sphero or the deadtime for the commands sent expires.
  ///
  /// @private
  /// @param {Number} seq from the sphero response packet
  /// @param {Packet} packet parsed from the sphero response packet
  /// @example
  /// sphero._execCallback(0x14, packet);
  /// @return {void}
  void _execCallback(int seq, Map<String, dynamic> packet) {
    var queue = responseQueue[seq];

    if (queue != null) {
      queue.handler(null, packet);
    }
  }

  /// Returns the response cmd (did, cid) passed to the sphero
  /// based on the seq from the response (used for parsing responses).
  ///
  /// @private
  /// @param {Number} seq from the sphero response packet
  /// @example
  /// sphero._responseCmd(0x14);
  /// @return {Object|void} containing cmd ids { did: number, cid: number }
  Map<String, int> _responseCmd(int seq) {
    final queue = responseQueue[seq];

    if (queue != null) {
      return {'did': queue.did, 'cid': queue.cid};
    }

    return null;
  }

  /// Auto-increments seq counter for command and callback queues.
  ///
  /// @private
  /// @example
  /// sphero._responseCmd(0x14);
  /// @return {Number} the increased value of seqCounter
  int _incSeq() {
    if (seqCounter > 255) {
      seqCounter = 0x00;
    }

    return seqCounter++;
  }
}

class CommandQueueResponseItem {
  final Function(String, Map<String, dynamic>) handler;
  final int cid;
  final int did;
  Timer timer;

  CommandQueueResponseItem({this.handler, this.cid, this.did});
}
