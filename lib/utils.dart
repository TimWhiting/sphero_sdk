import 'dart:math';

///Converts [red], [green], and [blue] vlaues to an equivalent hex number
///
///[red], [green], and [blue] should be ints from 0-255
rgbToHex(red,green,blue){
  return blue | (green << 8) | (red << 16);
}
///Generates a random rgb color
randomColor(){
  Random rand = new Random();
  int randInt() => rand.nextInt(255);
  return {'red':randInt(),'green':randInt(),'blue':randInt()};
}

///Calculates an Array-like object's checksum through mod-256ing it's contents
///then ones-complimenting the result.
checksum(data){
  var value = 0x00;
  for (var dataInt in data){
    value += dataInt;
  }
  return (value % 256) ^ 0xFF;
}

///Converts a [value] of [numBytes] to an array of hex values
intToHexArray(value,numBytes){
  var hexArray = [];
  for (var i = numBytes-1; i >= 0; i--){
    hexArray[i] = value & 0xFF;
    value >>= 8;
  }
  return hexArray;
}

///Converts [arguments] to an array.
argsToHexArray(arguments) {
  var args = [];

  for (var i = 0; i < arguments.length; i++) {
    args.insert(0, arguments[i] & 0xFF);
  }

  return args;
}

///Converts [buffer] to an integer.
bufferToInt(buffer) {
  var value = buffer[0];

  for (var i = 1; i < buffer.length; i++) {
    value <<= 8;
    value |= buffer[i];
  }

  return value;
}

///Converts Signed Two's Complement [value] of [numBytes] to an integer.
twosToInt(value, numBytes) {
  var mask = 0x00;
  numBytes = numBytes ?? 2;

  for (var i = 0; i < numBytes; i++) {
    mask = (mask << 8) | 0xFF;
  }

  return ~(value ^ mask);
}

///Applies bit xor of [mask] and the 32 bit [value].
xor32bit(value, mask) {
  var bytes = intToHexArray(value, 4);
  mask = mask ?? 0xFF;

  for (var i = 0; i < bytes.length; i++) {
    bytes[i] ^= mask;
  }

  return bufferToInt(bytes);
}