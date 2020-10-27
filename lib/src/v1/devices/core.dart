import 'dart:typed_data';

import '../command.dart';
import '../utils.dart';

class Core {
  Core(Future<ResponseV1> Function(int, Uint8List) Function(int) commandGen)
      : command = commandGen(0x00);
  Future<ResponseV1> Function(int command, Uint8List data) command;

  Future<ResponseV1> ping() => command(CoreV1.ping, null);
  Future<ResponseV1> version() => command(CoreV1.version, null);

  /// The Control UART Tx command enables or disables the CPU's UART transmit
  /// line so another client can configure the Bluetooth module.
  Future<ResponseV1> controlUartTX() => command(CoreV1.controlUARTTx, null);
  Future<ResponseV1> setDeviceName(String name) =>
      command(CoreV1.setDeviceName, name.asUint8List);
  Future<ResponseV1> getBluetoothInfo() => command(CoreV1.getBtInfo, null);

  /// Sets auto reconnect feature to [enabled] for reconnecting to device after [seconds]
  Future<ResponseV1> setAutoReconnect(bool enabled, int seconds) => command(
      CoreV1.setAutoReconnect, Uint8List.fromList([enabled.intFlag, seconds]));
  Future<ResponseV1> getAutoReconnect() =>
      command(CoreV1.getAutoReconnect, null);

  /// The Get Power State command returns Sphero's current power state, and some additional parameters:
  ///
  /// - **RecVer**: record version code (following is for 0x01)
  /// - **Power State**: high-level state of the power system
  /// - **BattVoltage**: current battery voltage, scaled in 100ths of a volt
  ///   (e.g. 0x02EF would be 7.51 volts)
  /// - **NumCharges**: Number of battery recharges in the life of this Sphero
  /// - **TimeSinceChg**: Seconds awake since last recharge
  ///
  /// Possible power states:
  ///
  /// - 0x01 - Battery Charging
  /// - 0x02 - Battery OK
  /// - 0x03 - Battery Low
  /// - 0x04 - Battery Critical
  Future<ResponseV1> getPowerState() => command(CoreV1.getPwrState, null);
  Future<ResponseV1> setPowerNotification(bool enabled) =>
      command(CoreV1.setPwrNotify, Uint8List.fromList([enabled.intFlag]));
  Future<ResponseV1> sleep(int wakeup, int startMacro, int orbBasicLine) =>
      command(
        CoreV1.sleep,
        Uint8List.fromList(
          [...wakeup.toHexArray(2), startMacro, ...orbBasicLine.toHexArray(2)],
        ),
      );

  Future<ResponseV1> getVoltageTripPoints() =>
      command(CoreV1.getPowerTrips, null);
  Future<ResponseV1> setVoltageTripPoints(int vLow, int vCrit) => command(
      CoreV1.setPowerTrips,
      Uint8List.fromList([...vLow.toHexArray(2), ...vCrit.toHexArray(2)]));
  Future<ResponseV1> setInactivityTimeout(int seconds) =>
      command(CoreV1.setInactiveTimer, seconds.toHexArray(2));
  Future<ResponseV1> jumpToBootloader() => command(CoreV1.goToBl, null);
  Future<ResponseV1> runL1Diag() => command(CoreV1.runL1Diags, null);
  Future<ResponseV1> runL2Diag() => command(CoreV1.runL2Diags, null);
  Future<ResponseV1> clearCounters() => command(CoreV1.clearCounters, null);
  Future<ResponseV1> _coreTimeCmd(int cmd, int time) =>
      command(cmd, time.toHexArray(4));
  Future<ResponseV1> assignTime(int time) =>
      _coreTimeCmd(CoreV1.assignTime, time);
  Future<ResponseV1> pollPacketTimes(int time) =>
      _coreTimeCmd(CoreV1.pollTimes, time);
}

class ResponseV1 {
  final Uint8List list;

  ResponseV1(this.list);
}
