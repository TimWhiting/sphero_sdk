import 'utils.dart';
import 'packet.dart';
import 'devices/core.dart';
import 'devices/sphero.dart';
import 'devices/custom.dart';
import 'devices/device.dart';
import 'loader.dart';



class Sphero extends device with sphero,core,custom{
  Sphero(address,{opts}){
    this.address = address;
    this.opts = this.opts ?? {};
    this.sop2Bitfield = SOP2[opts['sop2']] ?? SOP2['both'];
    this.connection = opts.adaptor ?? loader.load(address, opts);
    this.timeout = opts.timeout ?? 500;
    this.emitPacketErrors = opts.emitPacketErrors ?? false;
  }


}