import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'types.dart';
import 'utils.dart';

extension Encoding on Command {
  Uint8List encode() {
    final out = CommandOutput(bytes: [], checksum: 0x00);

    out.bytes.add(APIConstants.startOfPacket);
    encodeBytes(
        out,
        combineFlags(
            [...commandFlags, targetId != null ? Flags.commandHasTargetId : 0]),
        true);

    if (targetId != null) {
      encodeBytes(out, targetId, true);
    }

    encodeBytes(out, deviceId, true);
    encodeBytes(out, commandId, true);
    encodeBytes(out, sequenceNumber, true);

    if (payload != null) {
      payload.forEach((byte) {
        encodeBytes(out, byte, true);
      });
    }
    out.checksum = ~out.checksum;
    encodeBytes(out, out.checksum);
    out.bytes.add(APIConstants.endOfPacket);
    return Uint8List.fromList(out.bytes);
  }

  void encodeBytes(CommandOutput out, int byte, [bool appendChecksum = false]) {
    final unsignedInt = byte;
    switch (unsignedInt) {
      case APIConstants.startOfPacket:
        out.bytes
            .addAll([APIConstants.escape, APIConstants.escapedStartOfPacket]);
        break;

      case APIConstants.endOfPacket:
        out.bytes
            .addAll([APIConstants.escape, APIConstants.escapedEndOfPacket]);
        break;

      case APIConstants.escape:
        out.bytes.addAll([APIConstants.escape, APIConstants.escapedEscape]);
        break;

      default:
        out.bytes.add(byte);
    }

    // tslint:disable-next-line:no-bitwise
    out.checksum = (out.checksum + byte) & 0xff;
  }
}
