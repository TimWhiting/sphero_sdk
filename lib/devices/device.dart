import '../packet.dart';

class SOP2 {
  static final answer = 0xFD,
  resetTimeout = 0xFE,
  both = 0xFF,
  none = 0xFC,
  sync = 0xFF,
  async = 0xFE;
}
class device {
  var address;
  var opts;
  var busy = false;
  var ready = false;
  var packet = new Packet();
  var connection;
  var responseQueue = [];
  var commandQueue = [];
  var sop2Bitfield;
  var seqCounter = 0x00;
  var timeout;
  var emitPacketErrors;
  var ds = {};
  static command(vDevice, cmdName,data, callback){

  }
}