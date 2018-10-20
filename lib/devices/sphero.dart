import "device.dart";
class sphero extends device{
  var _command = (cmdName, data,callback) => device.command(0x02,cmdName,data,callback);

}