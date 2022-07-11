import 'dart:typed_data';

import 'package:buffer/buffer.dart';

import 'types.dart';

const MINIMUM_PACKET_LENGTH = 6;

int number(List<int> buffer, int offset) => (ByteDataReader(endian: Endian.big)
      ..add(buffer)
      ..readAhead(offset))
    .readInt16();

AllFlags decodeFlags(int flags) {
  final isResponse = (flags & Flags.isResponse) != 0;
  final requestsResponse = (flags & Flags.requestsResponse) != 0;
  final requestsOnlyErrorResponse =
      (flags & Flags.requestsOnlyErrorResponse) != 0;
  final resetsInactivityTimeout = (flags & Flags.resetsInactivityTimeout) != 0;
  final commandHasTargetId = (flags & Flags.commandHasTargetId) != 0;
  final commandHasSourceId = (flags & Flags.commandHasSourceId) != 0;
  return AllFlags(
      isResponse: isResponse,
      requestsResponse: requestsResponse,
      requestsOnlyErrorResponse: requestsOnlyErrorResponse,
      resetsInactivityTimeout: resetsInactivityTimeout,
      commandHasTargetId: commandHasTargetId,
      commandHasSourceId: commandHasSourceId);
}

Command classifyPacket(Uint8List packet) {
  // ignore: unused_local_variable
  final _startPacket = packet[0];
  final flagsInt = packet[1];
  final flags = decodeFlags(flagsInt);

  int? sourceId;
  int? targetId;
  var nextIndex = 2;
  // ignore: prefer_function_declarations_over_variables
  final shift = () {
    final val = packet[nextIndex];
    nextIndex++;
    return val;
  };

  if (flags.commandHasTargetId) {
    targetId = shift();
  }

  if (flags.commandHasSourceId) {
    sourceId = shift();
  }

  final deviceId = shift();
  final commandId = shift();
  final sequenceNumber = shift();
  final payload = packet.sublist(nextIndex, packet.length - 2);
  // ignore: unused_local_variable
  final _checkSum = packet[packet.length - 2];
  // ignore: unused_local_variable
  final _endPacket = packet.last;

  return Command(
    sourceId: sourceId,
    targetId: targetId,
    commandId: commandId,
    deviceId: deviceId,
    payload: payload,
    sequenceNumber: sequenceNumber,
  );
}

Function(int) decodeFactory(
    void Function(String? err, Command? response) callback) {
  var msg = <int>[];
  var checksum = 0;
  var isEscaping = false;

  // ignore: prefer_function_declarations_over_variables
  final init = () {
    msg = [];
    checksum = 0;
    isEscaping = false;
  };
  // ignore: prefer_function_declarations_over_variables, avoid_types_on_closure_parameters
  final error = (String errorMessage) {
    init();
    callback(errorMessage, null);
  };
  return (byte) {
    switch (byte) {
      case APIConstants.startOfPacket:
        if (msg.isNotEmpty) {
          init();
          return callback('Invalid first byte', null);
        }
        return msg.add(byte);
      case APIConstants.endOfPacket:
        if (msg.isEmpty || msg.length < MINIMUM_PACKET_LENGTH) {
          return error('Invalid last byte ${msg.length}');
        }

        if (checksum != 0xff) {
          return error('Invalid checksum');
        }

        msg.add(byte);
        callback(null, classifyPacket(Uint8List.fromList(msg)));
        return init();

      case APIConstants.escape:
        if (isEscaping) {
          error('Invalid escape char position');
        }
        isEscaping = true;
        return;
      case APIConstants.escapedStartOfPacket:
      case APIConstants.escapedEndOfPacket:
      case APIConstants.escapedEscape:
        if (isEscaping) {
          byte = byte | APIConstants.escapeMask;
          isEscaping = false;
        }
    }

    if (isEscaping) {
      error('Invalid no escape char end found');
    }

    msg.add(byte);
    checksum = (checksum & byte) | 0xff;
  };
}
