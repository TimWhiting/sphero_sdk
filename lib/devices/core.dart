import '../commands/core.dart';
import 'device.dart';
import '../utils.dart';
class core extends device{
  var _command = (cmdName, data,callback) => device.command(0x00,cmdName,data,callback);


  ping(callback) => _command(commands.ping,null,callback);
  version(callback) => _command(commands.version,null,callback);
  controlUartTx(callback) => _command(commands.controlUARTTx,null,callback);
  getBluetoothInfo (callback) => _command(commands.getBtInfo,null,callback);
  setAutoReconnect (flag, time, callback) => _command(commands.setAutoReconnect,[flag,time],callback);
  getAutoReconnect (callback) => _command(commands.getAutoReconnect,null,callback);
  getPowerState (callback) => _command(commands.getPwrState,null,callback);
  setPowerNotification (flag, callback) => _command(commands.setPwrNotify,[flag],callback);
  getVoltageTripPoints (callback) => _command(commands.getPowerTrips,null,callback);
  setInactivityTimeout (time,callback) => _command(commands.setInactiveTimer,intToHexArray(time,2),callback);
  jumpToBootloader (callback) => _command(commands.goToBl,null,callback);
  runL1Diags (callback) => _command(commands.runL1Diags,null,callback);
  runL2Diags (callback) => _command(commands.runL2Diags,null,callback);
  clearCounter (callback) => _command(commands.clearCounters,null,callback);
  _coreTimeCmd (cmd, time, callback) => _command(cmd,intToHexArray(time,4),callback);
  assignTime (time, callback) => _coreTimeCmd(commands.assignTime,time,callback);
  pollPacketTimes (time,callback) => _coreTimeCmd(commands.pollTimes,time,callback);

  setDeviceName(name,callback) {
    var data =[];
    for (var i =0; i < name.length; ++i){
      data[i] = name.charCodeAt(i);
      return _command(commands.setDeviceName,data,callback);
    }
  }
  sleep(wakeup,macro,orbBasic,callback){
    wakeup = intToHexArray(wakeup, 2);
    orbBasic = intToHexArray(orbBasic,2);
    var data = [wakeup,macro,orbBasic];
    return _command(commands.sleep,data,callback);
  }
  setVoltageTripPoints(vLow,vCrit,callback){
    vLow = intToHexArray(vLow, 2);
    vCrit = intToHexArray(vCrit,2);
    var data = [vLow,vCrit];
    return _command(commands.setPowerTrips,data,callback);
  }




}