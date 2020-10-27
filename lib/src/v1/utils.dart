import 'dart:typed_data';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
part 'utils.freezed.dart';

/// Converts [red], [green], and [blue] values (0-255) to an equivalent hex number
int rgbToHex(int red, int green, int blue) {
  return blue | (green << 8) | (red << 16);
}

final _rand = Random();

@freezed
abstract class RGB with _$RGB {
  const factory RGB({int red, int green, int blue}) = _RGB;
}

/// Generates a random rgb color
RGB randomColor() {
  rand() {
    return _rand.nextInt(255);
  }

  return RGB(red: rand(), green: rand(), blue: rand());
}

/// Calculates an Uint8List-like [data] object's checksum through mod-256ing it's contents
/// then ones-complimenting the result.
int checksum(List<int> data) {
  int value = 0x00;

  for (var i = 0; i < data.length; i++) {
    value += data[i];
  }

  return (value % 256) ^ 0xFF;
}

/// Converts a number to an array of hex values within the provided byte frame.
Uint8List intToHexArray(int value, int numBytes) {
  var hexArray = Uint8List(numBytes);

  for (var i = numBytes - 1; i >= 0; i--) {
    hexArray[i] = value & 0xFF;
    value >>= 8;
  }

  return hexArray;
}

/// Converts [buffer] to integer.
int bufferToInt(Uint8List buffer) {
  var value = buffer[0];

  for (var i = 1; i < buffer.length; i++) {
    value <<= 8;
    value |= buffer[i];
  }

  return value;
}

/// Converts Signed Two's Complement [value] from bytes to integer.
int twosToInt(int value, [int numBytes = 2]) {
  var mask = 0x00;

  for (var i = 0; i < numBytes; i++) {
    mask = (mask << 8) | 0xFF;
  }

  return ~(value ^ mask);
}

/// Applies bit Xor to 32 bit [value] with a [mask] to each 8 bits
int xor32bit(int value, [int mask = 0xff]) {
  var bytes = intToHexArray(value, 4);

  for (var i = 0; i < bytes.length; i++) {
    bytes[i] ^= mask;
  }

  return bufferToInt(bytes);
}
