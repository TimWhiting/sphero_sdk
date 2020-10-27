import 'dart:typed_data';

import '../packet.dart';
import '../sphero.dart';
import 'command.dart';
import '../utils.dart';

abstract class SpheroBase {
  final Map<String, int> ds = {};
  Future<Map<String, dynamic>> baseCommand(
      int deviceId, int command, Uint8List data);
}

mixin Core on SpheroBase {
  Future<Map<String, dynamic>> _coreCommand(int command, Uint8List data) =>
      baseCommand(0x00, command, data);

  ///
  /// The Ping command verifies the Sphero is awake and receiving commands.
  ///
  /// @param {Function} callback triggered when Sphero has been pinged
  /// @example
  /// orb.ping(function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> ping() => _coreCommand(CoreV1.ping, null);

  ///
  /// The Version command returns a batch of software and hardware information
  /// about Sphero.
  ///
  /// @param {Function} callback triggered with version information
  /// @example
  /// orb.version(function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  recv:", data.recv);
  ///     print("  mdl:", data.mdl);
  ///     print("  hw:", data.hw);
  ///     print("  msaVer:", data.msaVer);
  ///     print("  msaRev:", data.msaRev);
  ///     print("  bl:", data.bl);
  ///     print("  bas:", data.bas);
  ///     print("  macro:", data.macro);
  ///     print("  apiMaj:", data.apiMaj);
  ///     print("  apiMin:", data.apiMin);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> version() => _coreCommand(CoreV1.version, null);

  /// The Control UART Tx command enables or disables the CPU's UART transmit
  /// line so another client can configure the Bluetooth module.
  Future<Map<String, dynamic>> controlUartTX() =>
      _coreCommand(CoreV1.controlUARTTx, null);

  ///
  /// The Set Device Name command assigns Sphero an internal name. This value is
  /// then produced as part of the Get Bluetooth Info command.
  ///
  /// Names are clipped at 48 characters to support UTF-8 sequences. Any extra
  /// characters will be discarded.
  ///
  /// This field defaults to the Bluetooth advertising name of Sphero.
  ///
  /// @param {String} name what name to give to the Sphero
  /// @param {Function} callback function to be triggered when the name is set
  /// @example
  /// orb.setDeviceName("rollingOrb", function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> setDeviceName(String name) =>
      _coreCommand(CoreV1.setDeviceName, name.asUint8List);

  ///
  /// Triggers the callback with a structure containing
  ///
  /// - Sphero's ASCII name
  /// - Sphero's Bluetooth address (ASCII)
  /// - Sphero's ID colors
  ///
  /// @param {Function} callback function to be triggered with Bluetooth info
  /// @example
  /// orb.getBluetoothInfo(function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  name:", data.name);
  ///     print("  btAddress:", data.btAddress);
  ///     print("  separator:", data.separator);
  ///     print("  colors:", data.colors);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> getBluetoothInfo() =>
      _coreCommand(CoreV1.getBtInfo, null);

  /// Sets auto reconnect feature to [enabled] for reconnecting to device after [seconds]
  Future<Map<String, dynamic>> setAutoReconnect(bool enabled, int seconds) =>
      _coreCommand(CoreV1.setAutoReconnect,
          Uint8List.fromList([enabled.intFlag, seconds]));

  ///
  /// The Get Auto Reconnect command returns the Bluetooth auto reconnect values
  /// as defined above in the Set Auto Reconnect command.
  ///
  /// @param {Function} callback function to be triggered with reconnect data
  /// @example
  /// orb.getAutoReconnect(function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  flag:", data.flag);
  ///     print("  time:", data.time);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> getAutoReconnect() =>
      _coreCommand(CoreV1.getAutoReconnect, null);

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
  Future<Map<String, dynamic>> getPowerState() =>
      _coreCommand(CoreV1.getPwrState, null);

  ///
  /// The Set Power Notification command enables sphero to asynchronously notify
  /// the user of power state periodically (or immediately, when a change occurs)
  ///
  /// Timed notifications are sent every 10 seconds, until they're disabled or
  /// Sphero is unpaired.
  ///
  /// @param {Number} flag whether or not to send notifications (0 - no, 1 - yes)
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.setPowerNotification(1, function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> setPowerNotification(bool enabled) =>
      _coreCommand(CoreV1.setPwrNotify, Uint8List.fromList([enabled.intFlag]));

  ///
  /// The Sleep command puts Sphero to sleep immediately.
  ///
  /// @param {Number} wakeup the number of seconds for Sphero to re-awaken after.
  /// 0x00 tells Sphero to sleep forever, 0xFFFF attemps to put Sphero into deep
  /// sleep.
  /// @param {Number} macro if non-zero, Sphero will attempt to run this macro ID
  /// when it wakes up
  /// @param {Number} orbBasic if non-zero, Sphero will attempt to run an
  /// orbBasic program from this line number
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.sleep(10, 0, 0, function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> sleep(
          int wakeup, int startMacro, int orbBasicLine) =>
      _coreCommand(
        CoreV1.sleep,
        Uint8List.fromList(
          [...wakeup.toHexArray(2), startMacro, ...orbBasicLine.toHexArray(2)],
        ),
      );

  ///
  /// The Get Voltage Trip Points command returns the trip points Sphero uses to
  /// determine Low battery and Critical battery.
  ///
  /// The values are expressed in 100ths of a volt, so defaults of 7V and 6.5V
  /// respectively are returned as 700 and 650.
  ///
  /// @param {Function} callback function to be triggered with trip point data
  /// @example
  /// orb.getVoltageTripPoints(function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  vLow:", data.vLow);
  ///     print("  vCrit:", data.vCrit);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> getVoltageTripPoints() =>
      _coreCommand(CoreV1.getPowerTrips, null);

  ///
  /// The Set Voltage Trip Points command assigns the voltage trip points for Low
  /// and Critical battery voltages.
  ///
  /// Values are specified in 100ths of a volt, and there are limitations on
  /// adjusting these from their defaults:
  ///
  /// - vLow must be in the range 675-725
  /// - vCrit must be in the range 625-675
  ///
  /// There must be 0.25v of separation between the values.
  ///
  /// Shifting these values too low can result in very little warning before
  /// Sphero forces itself to sleep, depending on the battery pack. Be careful.
  ///
  /// @param {Number} vLow new voltage trigger for Low battery
  /// @param {Number} vCrit new voltage trigger for Crit battery
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.setVoltageTripPoints(675, 650, function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> setVoltageTripPoints(int vLow, int vCrit) =>
      _coreCommand(CoreV1.setPowerTrips,
          Uint8List.fromList([...vLow.toHexArray(2), ...vCrit.toHexArray(2)]));

  ///
  /// The Set Inactivity Timeout command sets the timeout delay before Sphero
  /// goes to sleep automatically.
  ///
  /// By default, the value is 600 seconds (10 minutes), but this command can
  /// alter it to any value of 60 seconds or greater.
  ///
  /// @param {Number} time new delay before sleeping
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.setInactivityTimeout(120, function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> setInactivityTimeout(int seconds) =>
      _coreCommand(CoreV1.setInactiveTimer, seconds.toHexArray(2));

  ///
  /// The Jump To Bootloader command requests a jump into the Bootloader to
  /// prepare for a firmware download.
  ///
  /// All commands after this one must comply with the Bootloader Protocol
  /// Specification.
  ///
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.jumpToBootLoader(function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> jumpToBootloader() =>
      _coreCommand(CoreV1.goToBl, null);

  ///
  /// The Perform Level 1 Diagnostics command is a developer-level command to
  /// help diagnose aberrant behaviour in Sphero.
  ///
  /// Most process flags, system counters, and system states are decoded to
  /// human-readable ASCII.
  ///
  /// For more details, see the Sphero API documentation.
  ///
  /// @param {Function} callback function to be triggered with diagnostic data
  /// @example
  /// orb.runL1Diags(function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> runL1Diag() =>
      _coreCommand(CoreV1.runL1Diags, null);

  ///
  /// The Perform Level 2 Diagnostics command is a developer-level command to
  /// help diagnose aberrant behaviour in Sphero.
  ///
  /// It's much less informative than the Level 1 command, but is in binary
  /// format and easier to parse.
  ///
  /// For more details, see the Sphero API documentation.
  ///
  /// @param {Function} callback function to be triggered with diagnostic data
  /// @example
  /// orb.runL2Diags(function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  recVer:", data.recVer);
  ///     print("  rxGood:", data.rxGood);
  ///     print("  rxBadId:", data.rxBadId);
  ///     print("  rxBadDlen:", data.rxBadDlen);
  ///     print("  rxBadCID:", data.rxBadCID);
  ///     print("  rxBadCheck:", data.rxBadCheck);
  ///     print("  rxBufferOvr:", data.rxBufferOvr);
  ///     print("  txMsg:", data.txMsg);
  ///     print("  txBufferOvr:", data.txBufferOvr);
  ///     print("  lastBootReason:", data.lastBootReason);
  ///     print("  bootCounters:", data.bootCounters);
  ///     print("  chargeCount:", data.chargeCount);
  ///     print("  secondsSinceCharge:", data.secondsSinceCharge);
  ///     print("  secondsOn:", data.secondsOn);
  ///     print("  distancedRolled:", data.distancedRolled);
  ///     print("  sensorFailures:", data.sensorFailures);
  ///     print("  gyroAdjustCount:", data.gyroAdjustCount);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> runL2Diag() =>
      _coreCommand(CoreV1.runL2Diags, null);

  ///
  /// The Clear Counters command is a developer-only command to clear the various
  /// system counters created by the L2 diagnostics.
  ///
  /// It is denied when the Sphero is in Normal mode.
  ///
  /// @private
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.clearCounters(function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> clearCounters() =>
      _coreCommand(CoreV1.clearCounters, null);

  Future<Map<String, dynamic>> _coreTimeCmd(int cmd, int time) =>
      _coreCommand(cmd, time.toHexArray(4));

  ///
  /// The Assign Time command sets a specific value to Sphero's internal 32-bit
  /// relative time counter.
  ///
  /// @param {Number} time the new value to set
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.assignTime(0x00ffff00, function(err, data) {
  ///   print(err || "data: " + data);
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> assignTime(int time) =>
      _coreTimeCmd(CoreV1.assignTime, time);

  ///
  /// The Poll Packet Times command helps users profile the transmission and
  /// processing latencies in Sphero.
  ///
  /// For more details, see the Sphero API documentation.
  ///
  /// @param {Number} time a timestamp to use for profiling
  /// @param {Function} callback function to be triggered when done writing
  /// @example
  /// orb.assignTime(0x00ffff, function(err, data) {
  ///   if (err) {
  ///     print("error: ", err);
  ///   } else {
  ///     print("data:");
  ///     print("  t1:", data.t1);
  ///     print("  t2:", data.t2);
  ///     print("  t3:", data.t3);
  ///   }
  /// }
  /// @return {object} promise for command
  Future<Map<String, dynamic>> pollPacketTimes(int time) =>
      _coreTimeCmd(CoreV1.pollTimes, time);
}
