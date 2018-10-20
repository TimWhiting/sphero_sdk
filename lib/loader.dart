import 'adaptors/serialport.dart';
import 'adaptors/ble.dart';

isSerialPort(str){
  // use regexp to determine whether or not 'str' is a serial port
  RegExp regExp = new RegExp('(\/dev\/com\d+).*',caseSensitive: false);
  return regExp.hasMatch(str);
}

/// Loads an adaptor based on provided [conn]ection string and system state [opts]

load(conn, opts) {
  var Adaptor;
  var isSerial = isSerialPort(conn);
  var isChrome = !isSerial && !isBLE;
  if (isSerial) {
  Adaptor = SerialPort(conn,opts);
  } else if (isChrome) {
  // load chrome BLE adaptor
  } else {
  Adaptor = BLE(conn,opts);
  }

  return Adaptor;
  }