import 'dart:typed_data';
import '../utils.dart';
import 'command.dart';
import 'core.dart';

extension SpheroDevice on SpheroBase {
  Future<Map<String, dynamic>> _command(int command, Uint8List data) =>
      baseCommand(0x02, command, data);

  /// The Set Heading command tells Sphero to adjust it's orientation, by
  /// commanding a new reference [heading] (in degrees 0-359).
  ///
  /// If stabilization is enabled, Sphero will respond immediately to this.
  ///
  /// ```dart
  /// await orb.setHeading(180);
  /// ```
  Future<Map<String, dynamic>> setHeading(int heading) =>
      _command(SpheroV1.setHeading, heading.toHexArray(2));

  /// The Set Stabilization command turns Sphero's internal stabilization on or
  /// off, depending on the [enabled] flag.
  ///
  /// ```dart
  /// await orb.setStabilization(1);
  /// ```
  Future<Map<String, dynamic>> setStabiliation(bool enabled) => _command(
      SpheroV1.setStabilization, Uint8List.fromList([enabled.intFlag]));

  /// The Set Rotation Rate command allows control of the [rotation] rate Sphero
  /// uses to meet new heading commands.
  ///
  /// A lower value offers better control, but with a larger turning radius.
  ///
  /// Higher values yield quick turns, but Sphero may lose control.
  ///
  /// The provided value is in units of 0.784 degrees/sec.
  ///
  /// ```dart
  /// await orb.setRotationRate(180);
  /// ```
  Future<Map<String, dynamic>> setRotationRate(int rotation) =>
      _command(SpheroV1.setRotationRate, Uint8List.fromList([rotation]));

  /// The Get Chassis ID command returns the 16-bit chassis ID Sphero was
  /// assigned at the factory.
  ///
  /// ```dart
  /// final data = orb.getChassisId();
  /// print("data:");
  /// print("  chassisId:", data.chassisId);
  /// ```
  Future<Map<String, dynamic>> getChassisId() =>
      _command(SpheroV1.getChassisId, null);

  /// The Set Chassis ID command assigns Sphero's chassis [id], a 16-bit value.
  ///
  /// This command only works if you're at the factory.
  ///
  /// ```dart
  /// await orb.setChassisId(0xFE75);
  /// ```
  Future<Map<String, dynamic>> setChassisId(int id) =>
      _command(SpheroV1.setChassisId, id.toHexArray(2));

  /// The Self Level command controls Sphero's self-level routine.
  ///
  /// This routine attempts to achieve a horizontal orientation where pitch/roll
  /// angles are less than the provided Angle Limit.
  ///
  /// After both limits are satisfied, option bits control sleep, final
  /// angle(heading), and control system on/off.
  ///
  /// An asynchronous message is returned when the self level routine completes.
  ///
  /// For more detail on opts param, see the Sphero API documentation.
  ///
  /// opts:
  ///  - [angleLimit]: 0 for defaul, 1 - 90 to set.
  ///  - [timeout]: 0 for default, 1 - 255 to set.
  ///  - [trueTime]: 0 for default, 1 - 255 to set.
  ///  - [options]: bitmask 4bit e.g. 0xF
  ///
  /// ```dart
  /// await orb.selfLevel(angleLimit: 0,
  ///   timeout: 0, ,
  ///   trueTime: 0,
  ///   options: 0x7);
  /// ```
  Future<Map<String, dynamic>> selfLevel(
          {int angleLimit = 0,
          int timeout = 0,
          int trueTime = 0,
          int options = 0}) =>
      _command(SpheroV1.selfLevel,
          Uint8List.fromList([options, angleLimit, timeout, trueTime]));

  /// The Set Data Streaming command configures Sphero's built-in support for
  /// asynchronously streaming certain system and sensor data.
  ///
  /// This command selects the internal sampling frequency, packet size,
  /// parameter mask, and (optionally) the total number of packets.
  ///
  /// These options are provided as an object, with the following properties:
  ///
  /// - [n] - divisor of the maximum sensor sampling rate
  /// - [m] - number of sample frames emitted per packet
  /// - [mask1] - bitwise selector of data sources to stream
  /// - [pcnt] - packet count 1-255 (or 0, for unlimited streaming)
  /// - [mask2] - bitwise selector of more data sources to stream (optional)
  ///
  /// For more explanation of these options, please see the Sphero API
  /// documentation.
  ///
  /// ```dart
  /// await orb.setDataStreaming(n: 400,
  ///   m: 1,
  ///   mask1: 0x00000000,
  ///   mask2: 0x01800000,
  ///   pcnt: 0);
  /// ```
  Future<Map<String, dynamic>> setDataStreaming(
      int n, int m, int mask1, int mask2, int pcnt) {
    ds['mask1'] = mask1;
    ds['mask2'] = mask2;

    return _command(
        SpheroV1.setDataStreaming,
        Uint8List.fromList([
          ...n.toHexArray(2),
          ...m.toHexArray(2),
          ...mask1.toHexArray(4),
          pcnt,
          ...mask2.toHexArray(4)
        ]));
  }

  /// The Configure Collisions command configures Sphero's collision detection
  /// with the provided parameters.
  ///
  /// These include:
  ///
  /// - [meth] - which detection method to use. Supported methods are 0x01,
  ///   0x02, and 0x03 (see the collision detection document for details). 0x00
  ///   disables this service.
  /// - [xt], [yt] - 8-bit settable threshold for the X (left, right) and
  ///   y (front, back) axes of Sphero. 0x00 disables the contribution of that
  ///   axis.
  /// - [xs], [ys] - 8-bit settable speed value for X/Y axes. This setting is
  ///   ranged by the speed, than added to `xt` and `yt` to generate the final
  ///   threshold value.
  /// - [dead] - an 8-bit post-collision dead time to prevent re-triggering.
  ///   Specified in 10ms increments.
  ///
  /// ```dart
  /// await orb.configureCollisions(meth: 0x01,
  ///   xt: 0x0F,
  ///   xs: 0x0F,
  ///   yt: 0x0A,
  ///   ys: 0x0A,
  ///   dead: 0x05);
  /// ```
  Future<Map<String, dynamic>> configureCollisions(
      {int meth, int xt, int xs, int yt, int ys, int dead}) {
    final data = [meth, xt, xs, yt, ys, dead];
    return _command(SpheroV1.setCollisionDetection, Uint8List.fromList(data));
  }

  /// The Configure Locator command configures Sphero's streaming location data
  /// service.
  ///
  /// The following options must be provided:
  ///
  /// - [flags] - bit 0 determines whether calibrate commands auto-correct the
  ///   yaw tare value. When false, positive Y axis coincides with heading 0.
  ///   Other bits are reserved.
  /// - [x], [y] - the current (x/y) coordinates of Sphero on the ground plane in
  ///   centimeters
  /// - [yawTare] - controls how the x,y-plane is aligned
  ///  with Sphero's heading
  ///   coordinate system. When zero, yaw = 0 corresponds to facing down the
  ///   y-axis in the positive direction. Possible values are 0-359 inclusive.
  ///
  /// @param {Object} opts object containing locator service configuration
  /// ```dart
  /// await orb.configureLocator(flags: 0x01,
  ///   x: 0x0000,
  ///   y: 0x0000,
  ///   yawTare: 0x0);
  /// ```
  Future<Map<String, dynamic>> configureLocator(
          int flags, int x, int y, int yawTare) =>
      _command(
        SpheroV1.locator,
        Uint8List.fromList([
          flags,
          ...x.toHexArray(2),
          ...y.toHexArray(2),
          ...yawTare.toHexArray(2)
        ]),
      );

  /// The Set Accelerometer Range command tells Sphero what accelerometer range
  /// to use.
  ///
  /// By default, Sphero's solid-state accelerometer is set for a range of ±8Gs.
  /// You may wish to change this, perhaps to resolve finer accelerations.
  ///
  /// This command takes an [index] for the supported range, as explained below:
  ///
  /// - `0`: ±2Gs
  /// - `1`: ±4Gs
  /// - `2`: ±8Gs (default)
  /// - `3`: ±16Gs
  ///
  /// ```dart
  /// await orb.setAccelRange(0x02);
  /// ```
  Future<Map<String, dynamic>> setAccelRange(int index) =>
      _command(SpheroV1.setAccelerometer, Uint8List.fromList([index & index]));

  /// The Read Locator command gets Sphero's current position (X,Y), component
  /// velocities, and speed-over-ground (SOG).
  ///
  /// The position is a signed value in centimeters, the component
  /// velocities are
  /// signed cm/sec, and the SOG is unsigned cm/sec.
  ///
  /// ```dart
  /// await orb.readLocator();
  /// print("data:");
  /// print("  xpos:", data.xpos);
  /// print("  ypos:", data.ypos);
  /// print("  xvel:", data.xvel);
  /// print("  yvel:", data.yvel);
  /// print("  sog:", data.sog);
  /// ```
  Future<Map<String, dynamic>> readLocator() =>
      _command(SpheroV1.readLocator, null);

  /// The Set RGB LED command sets the colors of Sphero's RGB LED.
  ///
  /// An object containaing [red], [green], and [blue] values must be provided.
  ///
  /// If [flag] is set to 1 (default), the color is persisted across power
  /// cycles.
  ///
  /// ```dart
  /// await orb.setRgbLed( 0,  0, 255);
  /// ```
  Future<Map<String, dynamic>> setRgbLed(int red, int green, int blue,
          [int flag = 0x01]) =>
      _command(
          SpheroV1.setRgbLed, Uint8List.fromList([red, green, blue, flag]));

  /// The Set Back LED command allows [brightness] adjustment of Sphero's tail
  /// light.
  ///
  /// This value does not persist across power cycles.
  ///
  /// ```dart
  /// await orb.setbackLed(255);
  /// ```
  Future<Map<String, dynamic>> setBackLed(int brightness) =>
      _command(SpheroV1.setBackLed, Uint8List.fromList([brightness]));

  /// The Get RGB LED command fetches the current "user LED color" value, stored
  /// in Sphero's configuration.
  ///
  /// This value may or may not be what's currently displayed by Sphero's LEDs.
  ///
  /// ```dart
  /// await orb.getRgbLed();
  /// print("data:");
  /// print("  color:", data.color);
  /// print("  red:", data.red);
  /// print("  green:", data.green);
  /// print("  blue:", data.blue);
  /// ```
  Future<Map<String, dynamic>> getRgbLed() =>
      _command(SpheroV1.getRgbLed, null);

  /// The Roll command tells Sphero to roll along the provided vector.
  ///
  /// Both a [speed] and [heading] are required, the latter is
  /// considered relative to
  /// the last calibrated direction.
  ///
  /// Permissible heading values are 0 to 359 inclusive.
  ///
  /// [state]: optional state parameter
  /// ```dart
  /// orb.roll(100, 0);
  /// print("rolling...");
  /// ```
  Future<Map<String, dynamic>> roll(int speed, int heading,
          [int state = 0x01]) =>
      _command(SpheroV1.roll,
          Uint8List.fromList([speed, ...heading.toHexArray(2), state & 0x03]));

  /// The Boost command executes Sphero's boost macro.
  ///
  /// It takes a boolean parameter [boost]
  ///
  /// ```dart
  /// await orb.boost(1);
  /// ```
  Future<Map<String, dynamic>> boost(bool boost) =>
      _command(SpheroV1.boost, Uint8List.fromList([boost.intFlag]));

  /// The Set Raw Motors command allows manual control over one or both of
  /// Sphero's motor output values.
  ///
  /// Each motor (left and right requires a mode and a power value from 0-255.
  ///
  /// This command will disable stabilization is both mode's aren't "ignore", so
  /// you'll need to re-enable it once you're done.
  ///
  /// Possible modes:
  ///
  /// - `0x00`: Off (motor is open circuit)
  /// - `0x01`: Forward
  /// - `0x02`: Reverse
  /// - `0x03`: Brake (motor is shorted)
  /// - `0x04`: Ignore (motor mode and power is left unchanged
  ///
  /// ```dart
  /// await orb.setRawMotors(lmode: 0x01,
  ///   lpower: 180,
  ///   rmode: 0x02,
  ///   rpower: 180);
  /// ```
  Future<Map<String, dynamic>> setRawMotors(
          int lmode, int lpower, int rmode, int rpower) =>
      _command(SpheroV1.setRawMotors,
          Uint8List.fromList([lmode & 0x07, lpower, rmode & 0x07, rpower]));

  /// The Set Motion Timeout command gives Sphero an ultimate timeout for the
  /// last motion command to keep Sphero from rolling away in the case of
  /// a crashed (or paused) application.
  ///
  /// [timeout] is specified in milliseconds
  ///
  /// This defaults to 2000ms (2 seconds) upon wakeup.
  ///
  /// ```dart
  /// await orb.setMotionTimeout(0x0FFF);
  /// ```
  Future<Map<String, dynamic>> setMotionTimeout(int timeout) =>
      _command(SpheroV1.setMotionTimeout, timeout.toHexArray(2));

  /// The Set Permanent Option Flags command assigns Sphero's permanent option
  /// [flags] to the provided values, and writes them immediately to the config
  /// block.
  ///
  /// See below for the bit definitions.
  ///
  /// ```dart
  /// // Force tail LED always on
  /// await orb.setPermOptionFlags(0x00000008);
  /// ```
  Future<Map<String, dynamic>> setPermOptionFlags(int flags) =>
      _command(SpheroV1.setOptionsFlag, flags.toHexArray(4));

  /// The Get Permanent Option Flags command returns Sphero's permanent option
  /// flags, as a bit field.
  ///
  /// Here's possible bit fields, and their descriptions:
  ///
  /// - `0`: Set to prevent Sphero from immediately going to
  /// sleep when placed in
  ///   the charger and connected over Bluetooth.
  /// - `1`: Set to enable Vector Drive, that is, when Sphero is stopped and
  ///   a new roll command is issued it achieves the heading before moving along
  ///   it.
  /// - `2`: Set to disable self-leveling when Sphero is inserted into the
  ///   charger.
  /// - `3`: Set to force the tail LED always on.
  /// - `4`: Set to enable motion timeouts (see DID 02h, CID 34h)
  /// - `5`: Set to enable retail Demo Mode (when placed in the charger, ball
  ///   runs a slow rainbow macro for 60 minutes and then goes to sleep).
  /// - `6`: Set double tap awake sensitivity to Light
  /// - `7`: Set double tap awake sensitivity to Heavy
  /// - `8`: Enable gyro max async message (NOT SUPPORTED IN VERSION 1.47)
  /// - `6-31`: Unassigned
  ///
  /// ```dart
  /// await orb.getPermOptionFlags();
  /// print("data:");
  /// print("  sleepOnCharger:", data.sleepOnCharger);
  /// print("  vectorDrive:", data.vectorDrive);
  /// print("  selfLevelOnCharger:", data.selfLevelOnCharger);
  /// print("  tailLedAlwaysOn:", data.tailLedAlwaysOn);
  /// print("  motionTimeouts:", data.motionTimeouts);
  /// print("  retailDemoOn:", data.retailDemoOn);
  /// print("  awakeSensitivityLight:", data.awakeSensitivityLight);
  /// print("  awakeSensitivityHeavy:", data.awakeSensitivityHeavy);
  /// print("  gyroMaxAsyncMsg:", data.gyroMaxAsyncMsg);
  /// ```
  Future<Map<String, dynamic>> getPermOptionFlags() =>
      _command(SpheroV1.getOptionsFlag, null);

  /// The Set Temporary Option Flags command assigns Sphero's temporary option
  /// [flags] to the provided values. These do not persist across power cycles.
  ///
  /// - `0`: Enable Stop On Disconnect behavior
  /// - `1-31`: Unassigned
  ///
  /// ```dart
  /// // enable stop on disconnect behaviour
  /// await orb.setTempOptionFlags(0x01);
  /// ```
  Future<Map<String, dynamic>> setTempOptionFlags(int flags) =>
      _command(SpheroV1.setTempOptionFlags, flags.toHexArray(4));

  /// The Get Temporary Option Flags command returns Sphero's temporary option
  /// flags, as a bit field:
  ///
  /// - `0`: Enable Stop On Disconnect behavior
  /// - `1-31`: Unassigned
  ///
  /// ```dart
  /// orb.getTempOptionFlags();
  /// print("data:");
  /// print("  stopOnDisconnect:", data.stopOnDisconnect);
  /// ```
  Future<Map<String, dynamic>> getTempOptionFlags() =>
      _command(SpheroV1.getTempOptionFlags, null);

  /// The Get Configuration Block command retrieves one of
  /// Sphero's configuration blocks by [id].
  ///
  /// The response is a simple one; an error code of 0x08 is returned when the
  /// resources are currently unavailable to send the requested block back. The
  /// actual configuration block data returns in an asynchronous message of type
  /// 0x04 due to its length (if there is no error).
  ///
  /// ID = `0x00` requests the factory configuration block
  /// ID = `0x01` requests the user configuration block, which is updated with
  /// current values first
  ///
  /// ```dart
  /// await orb.getConfigBloc);
  /// ```
  Future<Map<String, dynamic>> getConfigBlock(int id) =>
      _command(SpheroV1.getConfigBlock, Uint8List.fromList([id]));

  Future<Map<String, dynamic>> _setSsbBlock(
          int cmd, int password, Uint8List block) =>
      _command(cmd, Uint8List.fromList([...password.toHexArray(4), ...block]));

  /// The Set SSB Modifier Block command allows the SSB to be patched with a new
  /// modifier [block] - including the Boost macro.
  ///
  /// The changes take effect immediately.
  ///
  /// ```dart
  /// await orb.setSsbModBlock(0x0000000F, data);
  /// ```
  Future<Map<String, dynamic>> setSsbModBlock(int password, Uint8List block) =>
      _setSsbBlock(SpheroV1.setSsbParams, password, block);

  /// The Set Device Mode command assigns the operation [mode] of Sphero based
  /// on the supplied mode value.
  ///
  /// - **0x00**: Normal mode
  /// - **0x01**: User Hack mode. Enables ASCII shell commands, refer to the
  ///   associated document for details.
  ///
  /// ```dart
  /// await orb.setDeviceMode(0x00);
  /// ```
  Future<Map<String, dynamic>> setDeviceMode(bool mode) =>
      _command(SpheroV1.setDeviceMode, Uint8List.fromList([mode.intFlag]));

  /// The Set Config Block command accepts an exact copy of the configuration
  /// [block], and loads it into the RAM copy of the configuration block.
  ///
  /// The RAM copy is then saved to flash.
  ///
  /// The configuration block can be obtained by using the Get Configuration
  /// Block command.
  ///
  /// ```dart
  /// await orb.setConfigBlock(dataBlock);
  /// ```
  Future<Map<String, dynamic>> setConfigBlock(Uint8List block) =>
      _command(SpheroV1.setConfigBlock, block);

  /// The Get Device Mode command gets the current device mode of Sphero.
  ///
  /// Possible values:
  ///
  /// - **0x00**: Normal mode
  /// - **0x01**: User Hack mode.
  ///
  /// ```dart
  /// final data = await orb.getDeviceMode();
  /// print("data:");
  /// print("  mode:", data.mode);
  /// ```
  Future<Map<String, dynamic>> getDeviceMode() =>
      _command(SpheroV1.getDeviceMode, null);

  /// The Get SSB command retrieves Sphero's Soul Block.
  ///
  /// The response is simple, and then the actual block of soulular data returns
  /// in an asynchronous message of type 0x0D, due to it's 0x440 byte length
  ///
  /// ```dart
  /// await orb.getSsb();
  /// ```
  Future<Map<String, dynamic>> getSsb() => _command(SpheroV1.getSsb, null);

  /// The Set SSB command sets Sphero's Soul [block].
  ///
  /// The actual payload length is 0x404 bytes, but if you use the special DLEN
  /// encoding of 0xff, Sphero will know what to expect.
  ///
  /// You need to supply the [password] in order for it to work.
  ///
  /// ```dart
  /// await orb.setSsb(pwd, block);
  /// ```
  Future<Map<String, dynamic>> setSsb(int password, Uint8List block) =>
      _setSsbBlock(SpheroV1.setSsb, password, block);

  /// The Refill Bank command attempts to refill either the Boost bank (0x00) or
  /// the Shield bank (0x01) by attempting to deduct the respective refill cost
  /// from the current number of cores.
  ///
  /// If it succeeds, the bank is set to the maximum obtainable for that level,
  /// the cores are spent, and a success response is returned
  /// with the lower core
  /// balance.
  ///
  /// If there aren't enough cores available to spend, Sphero responds with an
  /// EEXEC error (0x08)
  ///
  /// ```dart
  /// await orb.refillBank(0x00);
  /// ```
  Future<Map<String, dynamic>> refillBank(int type) =>
      _command(SpheroV1.ssbRefill, Uint8List.fromList([type]));

  /// The Buy Consumable command attempts to spend cores on consumables.
  ///
  /// The consumable [id] is given (0 - 7), as well as the [quantity] requested
  /// to purchase.
  ///
  /// If the purchase succeeds, the consumable count is increased, the cores are
  /// spent, and a success response is returned with the increased quantity and
  /// lower balance.
  ///
  /// If there aren't enough cores available to spend, or the purchase would
  /// exceed the max consumable quantity of 255, Sphero responds with an EEXEC
  /// error (0x08)
  ///
  /// ```dart
  /// await orb.buyConsumable(0x00, 5);
  /// ```
  Future<Map<String, dynamic>> buyConsumable(int id, int quantity) =>
      _command(SpheroV1.ssbBuy, Uint8List.fromList([id, quantity]));

  /// The Use Consumable command attempts to use a consumable specified by [id]
  /// if the quantity remaining is non-zero.
  ///
  /// On success, the return message echoes the [id] of this consumable and how
  /// many of them remain.
  ///
  /// If the associated macro is already running, or the quantity remaining is
  /// zero, this returns an EEXEC error (0x08).
  ///
  /// ```dart
  /// await orb.useConsumable(0x00);
  /// ```
  Future<Map<String, dynamic>> useConsumable(int id) =>
      _command(SpheroV1.ssbUseConsumeable, Uint8List.fromList([id]));

  /// The Grant Cores command adds the supplied [number] of cores.
  ///
  /// If the first bit in the flags byte is set, the command immediately commits
  /// the SSB to flash. Otherwise, it does not.
  ///
  /// All other bits are reserved.
  ///
  /// If the [password] is not accepted, this command fails without consequence.
  ///
  /// ```dart
  /// await orb.grantCores(pwd, 5, 0x01);
  /// ```
  Future<Map<String, dynamic>> grantCores(
          int password, int number, int flags) =>
      _command(
          SpheroV1.ssbGrantCores,
          Uint8List.fromList(
              [...password.toHexArray(4), ...number.toHexArray(4), flags]));

  Future<Map<String, dynamic>> _xpOrLevelUp(int cmd, int password, int gen) =>
      _command(cmd, Uint8List.fromList([...password.toHexArray(4), gen]));

  /// The add XP command increases XP by adding the supplied number of [minutes]
  /// of drive time, and immediately commits the SSB to flash.
  ///
  /// If the [password] is not accepted, this command fails without consequence.
  ///
  /// ```dart
  /// await orb.addXp(pwd, 5);
  /// ```
  Future<Map<String, dynamic>> addXp(int password, int minutes) =>
      _xpOrLevelUp(SpheroV1.ssbAddXp, password, minutes);

  /// The Level Up Attribute command attempts to increase the level of the
  /// attribute specified by [id] by spending attribute points.
  ///
  /// The IDs are:
  ///
  /// - **0x00**: speed
  /// - **0x01**: boost
  /// - **0x02**: brightness
  /// - **0x03**: shield
  ///
  /// If successful, the SSB is committed to flash, and a response packet
  /// containing the attribute ID, new level, and remaining attribute points is
  /// returned.
  ///
  /// If there are not enough attribute points, this command returns an EEXEC
  /// error (0x08).
  ///
  /// If the [password] is not accepted, this command fails without consequence.
  ///
  /// ```dart
  /// await orb.levelUpAttr(pwd, 0x00);
  /// ```
  Future<Map<String, dynamic>> levelUpAttr(int password, int id) =>
      _xpOrLevelUp(SpheroV1.ssbLevelUpAttr, password, id);

  /// The Get Password Seed command returns Sphero's password seed.
  ///
  /// Protected Sphero commands require a password.
  ///
  /// Refer to the Sphero API documentation, Appendix D for more information.
  ///
  /// ```dart
  /// await orb.getPasswordSee);
  /// ```
  Future<Map<String, dynamic>> getPasswordSeed() =>
      _command(SpheroV1.getPwSeed, null);

  /// The Enable SSB Async Messages command [enable]s soul block related
  /// asynchronous messages.
  ///
  /// These include shield collision/regrowth messages, boost use/regrowth
  /// messages, XP growth, and level-up messages.
  ///
  /// This feature defaults to off.
  ///
  /// ```dart
  /// await orb.enableSsbAsyncMsg(0x01);
  /// ```
  Future<Map<String, dynamic>> enableSsbAsyncMsg(bool enable) =>
      _command(SpheroV1.ssbEnableAsync, Uint8List.fromList([enable.intFlag]));

  /// The Run Macro command attempts to execute the macro specified by [id].
  ///
  /// Macro IDs are split into groups:
  ///
  /// 0-31 are System Macros. They are compiled into the Main Application, and
  /// cannot be deleted. They are always available to run.
  ///
  /// 32-253 are User Macros. They are downloaded and persistently stored, and
  /// can be deleted in total.
  ///
  /// 255 is the Temporary Macro, a special user macro as it is held in RAM for
  /// execution.
  ///
  /// 254 is also a special user macro, called the Stream Macro that doesn't
  /// require this call to begin execution.
  ///
  /// This command will fail if there is a currently executing macro, or the
  /// specified ID code can't be found.
  ///
  /// ```dart
  /// await orb.runMacro(0x01);
  /// ```
  Future<Map<String, dynamic>> runMacro(int id) =>
      _command(SpheroV1.runMacro, Uint8List.fromList([id]));

  /// The Save Temporary Macro stores the attached [macro] definition into the
  /// temporary RAM buffer for later execution.
  ///
  /// If this command is sent while a Temporary or Stream Macro is executing it
  /// will be terminated so that its storage space can be overwritten. As with
  /// all macros, the longest definition that can be sent is 254 bytes.
  ///
  /// ```dart
  /// await orb.saveTempMacro(0x01);
  /// ```
  Future<Map<String, dynamic>> saveTempMacro(Uint8List macro) =>
      _command(SpheroV1.saveTempMacro, macro);

  /// Save [macro]
  ///
  /// The Save Macro command stores the attached macro definition into the
  /// persistent store for later execution. This command can be sent even if
  /// other macros are executing.
  ///
  /// You will receive a failure response if you attempt to send an ID number in
  /// the System Macro range, 255 for the Temp Macro and ID of an existing user
  /// macro in the storage block.
  ///
  /// As with all macros, the longest definition that can be sent is 254 bytes.
  ///
  /// ```dart
  /// await orb.saveMacro(0x01);
  /// ```
  Future<Map<String, dynamic>> saveMacro(Uint8List macro) =>
      _command(SpheroV1.saveMacro, macro);

  /// The Reinit Macro Executive command terminates any running macro, and
  /// reinitializes the macro system.
  ///
  /// The table of any persistent user macros is cleared.
  ///
  /// ```dart
  /// await orb.reInitMacroExec();
  /// ```
  Future<Map<String, dynamic>> reInitMacroExec() =>
      _command(SpheroV1.initMacroExecutive, null);

  /// The Abort Macro command aborts any executing macro, and returns both it's
  /// ID code and the command number currently in progress.
  ///
  /// An exception is a System Macro executing with the UNKILLABLE flag set.
  ///
  /// A returned ID code of 0x00 indicates that no macro was running, an ID code
  /// of 0xFFFF as the CmdNum indicates the macro was unkillable.
  ///
  /// ```dart
  /// final data = await orb.abortMacro();
  /// print("data:");
  /// print("  id:", data.id);
  /// print("  cmdNum:", data.cmdNum);
  /// ```
  Future<Map<String, dynamic>> abortMacro() =>
      _command(SpheroV1.abortMacro, null);

  /// The Get Macro Status command returns the ID code and command number of the
  /// currently executing macro.
  ///
  /// If no macro is running, the 0x00 is returned for the ID code, and the
  /// command number is left over from the previous macro.
  ///
  /// ```dart
  /// final data = orb.getMacroStatus();
  /// print("data:");
  /// print("  idCode:", data.idCode);
  /// print("  cmdNum:", data.cmdNum);
  /// ```
  Future<Map<String, dynamic>> getMacroStatus() =>
      _command(SpheroV1.macroStatus, null);

  /// The Set Macro Parameter command allows system globals that influence
  /// certain macro commands to be selectively altered from outside of the macro
  /// system itself.
  ///
  /// The values of Val1 and Val2 depend on the parameter index.
  ///
  /// Possible indices:
  ///
  /// - **00h** Assign System Delay 1: Val1 = MSB, Val2 = LSB
  /// - **01h** Assign System Delay 2: Val1 = MSB, Val2 = LSB
  /// - **02h** Assign System Speed 1: Val1 = speed, Val2 = 0 (ignored)
  /// - **03h** Assign System Speed 2: Val1 = speed, Val2 = 0 (ignored)
  /// - **04h** Assign System Loops: Val1 = loop count, Val2 = 0 (ignored)
  ///
  /// For more details, please refer to the Sphero Macro document.
  ///
  /// ```dart
  /// await orb.setMacroParam(0x02, 0xF0, 0x00);
  /// ```
  Future<Map<String, dynamic>> setMacroParam(int index, int val1, int val2) =>
      _command(SpheroV1.setMacroParam, Uint8List.fromList([index, val1, val2]));

  /// The Append Macro Chunk stores the attached macro definition [chunk] into
  /// the temporary RAM buffer for later execution.
  ///
  /// It's similar to the Save Temporary Macro command, but allows building up
  /// longer temporary macros.
  ///
  /// Any existing Macro ID can be sent through this command, and executed
  /// through the Run Macro call using ID 0xFF.
  ///
  /// If this command is sent while a Temporary or Stream Macro is executing it
  /// will be terminated so that its storage space can be overwritten. As with
  /// all macros, the longest chunk that can be sent is 254 bytes.
  ///
  /// You must follow this with a Run Macro command (ID 0xFF) to actually get it
  /// to go and it is best to prefix this command with an Abort call to make
  /// certain the larger buffer is completely initialized.
  ///
  /// ```dart
  /// await orb.appendMacroChunk();
  /// ```
  Future<Map<String, dynamic>> appendMacroChunk(Uint8List chunk) =>
      _command(SpheroV1.appendTempMacroChunk, chunk);

  /// The Erase orbBasic Storage command erases any existing program in the
  /// specified storage [area].
  ///
  /// Specify 0x00 for the temporary RAM buffer, or 0x01 for the persistent
  /// storage area.
  ///
  /// ```dart
  /// await orb.eraseOrbBasicStorage(0x00);
  /// ```
  Future<Map<String, dynamic>> eraseOrbBasicStorage(int area) =>
      _command(SpheroV1.eraseOBStorage, Uint8List.fromList([area]));

  /// The Append orbBasic Fragment command appends a patch of orbBasic [code] to
  /// existing ones in the specified storage [area] (0x00 for RAM, 0x01 for
  /// persistent).
  ///
  /// Complete lines are not required. A line begins with a decimal line number
  /// followed by a space and is terminated with a <LF>.
  ///
  /// See the orbBasic Interpreter document for complete information.
  ///
  /// Possible error responses would be ORBOTIX_RSP_CODE_EPARAM if an illegal
  /// storage area is specified or ORBOTIX_RSP_CODE_EEXEC if the specified
  /// storage area is full.
  ///
  /// ```dart
  /// await orb.appendOrbBasicFragment(0x00, OrbBasicCode);
  /// ```
  Future<Map<String, dynamic>> appendOrbBasicFragment(
      int area, Uint8List code) {
    final data = Uint8List.fromList([area, ...code]);
    return _command(SpheroV1.appendOBFragment, data);
  }

  /// The Execute orbBasic Program command attempts to run a program in the
  /// specified storage [area], beginning at the specified line number.
  ///
  /// [slMSB] and [slLSB] are the most significant and least significant bytes
  /// for the specified line number.
  ///
  /// This command will fail if there is already an orbBasic program running.
  ///
  /// ```dart
  /// await orb.executeOrbBasicProgram(0x00, 0x00, 0x00);
  /// ```
  Future<Map<String, dynamic>> executeOrbBasicProgram(
          int area, int slMSB, int slLSB) =>
      _command(
          SpheroV1.execOBProgram, Uint8List.fromList([area, slMSB, slLSB]));

  /// The Abort orbBasic Program command aborts execution of any currently
  /// running orbBasic program.
  ///
  /// ```dart
  /// await orb.abortOrbBasicProgram();
  /// ```
  Future<Map<String, dynamic>> abortOrbBasicProgram() =>
      _command(SpheroV1.abortOBProgram, null);

  /// The Submit value To Input command takes the place of the typical user
  /// console in orbBasic and allows a user to answer an input request via [val]
  ///
  /// If there is no pending input request when this API command is sent, the
  /// supplied value is ignored without error.
  ///
  /// Refer to the orbBasic language document for further information.
  ///
  /// ```dart
  /// await orb.submitValuetoInput(0x0000FFFF);
  /// ```
  Future<Map<String, dynamic>> submitValueToInput(int val) =>
      _command(SpheroV1.answerInput, val.toHexArray(4));

  /// The Commit To Flash command copies the current orbBasic RAM program to
  /// persistent flash storage.
  ///
  /// It will fail if a program is currently executing out of flash.
  ///
  /// ```dart
  /// await orb.commitToFlas);
  /// ```
  Future<Map<String, dynamic>> commitToFlash() =>
      _command(SpheroV1.commitToFlash, null);

  // ignore: unused_element
  Future<Map<String, dynamic>> _commitToFlashAlias() =>
      _command(SpheroV1.commitToFlashAlias, null);
}
