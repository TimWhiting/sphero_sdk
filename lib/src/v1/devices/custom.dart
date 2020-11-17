import 'dart:math';

import '../utils.dart';
import 'core.dart';
import 'sphero.dart';

/// regular expression to match hex strings
final hexRegex = RegExp(r'^[A-Fa-f0-9]{6}$');

///
/// Converts a hex color number to RGB values
///
/// @private
/// @param {Number} num color value to convert
/// @return {Object} RGB color values
RGB hexToRgb(int n) =>
    RGB(red: (n >> 16) & 0xff, green: (n >> 8) & 0xff, blue: n & 0xff);

///
/// Converts a hex color number to luminance adjusted value
///
/// @private
/// @param {Object} hex hex color value to convert
/// @param {Number} lum percentage of luminance
/// @return {Object} converted color value
int calculateLuminance(int hex, int lum) =>
    min(max(0, hex + (hex * lum)), 255).round();

///
/// Adjusts an RGB color by the relative luminance
///
/// @private
/// @param {Object} rgb rgb color value to convert
/// @param {Number} lum percentage of luminance
/// @return {Object} RGB color values
RGB adjustLuminance(RGB rgb, int lum) {
  final newR = calculateLuminance(rgb.red, lum);
  final newG = calculateLuminance(rgb.green, lum);
  final newB = calculateLuminance(rgb.blue, lum);

  return RGB(red: newR, green: newG, blue: newB);
}

mixin Custom on SpheroBase {
  RGB originalColor = const RGB(red: 0, green: 0, blue: 0);

  int mergeMasks(String id, int mask, [bool remove = false]) {
    var m = mask;
    if (remove) {
      m = xor32bit(m);
      return ds[id] & m;
    }

    return ds[id] | m;
  }

  void on(String name, Function(dynamic) data) {
    if (eventListeners[name] == null) {
      eventListeners[name] = [];
    }
    eventListeners[name].add(data);
  }

  void emit(String name, dynamic data) {
    // print('Emitting: $name, $data');'
    for (final l in eventListeners[name]) {
      l(data);
    }
  }

  ///
  /// Generic Data Streaming setup, using Sphero's setDataStraming command.
  ///
  /// Users need to listen for the `dataStreaming` event, or a custom event, to
  /// get the data.
  ///
  /// @private
  /// @param {Object} args event, masks, fields, and sps data
  Future<Map<String, dynamic>> streamData({
    String event,
    int mask1,
    int mask2 = 0,
    List<String> fields,
    int sps = 2,
    bool remove,
  }) {
    // options for streaming data
    final n = (400 / sps).round();
    const m = 1;
    const pcnt = 0;
    final m1 = mergeMasks('mask1', mask1, remove);
    final m2 = mergeMasks('mask2', mask2, remove);

    on('dataStreaming', (data) {
      final params = {};

      for (var i = 0; i < fields.length; i++) {
        params[fields[i]] = data[fields[i]];
      }

      emit(event, params);
    });

    return setDataStreaming(n, m, m1, m2, pcnt);
  }

  ///
  /// The Color command wraps Sphero's built-in setRgb command, allowing for
  /// a greater range of possible inputs.
  ///
  /// @param {Number} color what color to change Sphero to
  /// @param {string} [luminance] - percentage of luminance
  ///  to apply to RGB color
  /// @example
  /// orb.color('#00ff00', function(err, data) {
  ///   print(err || 'Color Changed!');
  /// });
  /// @example
  /// orb.color(0xff0000, function(err, data) {
  ///   print(err || 'Color Changed!');
  /// });
  /// @example
  /// orb.color({ red: 0, green: 0, blue: 255 }, function(err, data) {
  ///   print(err || 'Color Changed!');
  /// });
  Future<Map<String, dynamic>> color(int color, [int luminance]) {
    var c = hexToRgb(color);
    if (luminance != null) {
      c = adjustLuminance(c, luminance);
    }
    return setRgbLed(c.red, c.green, c.blue);
  }

  ///
  /// The Random Color command sets Sphero to a randomly-generated color.
  ///
  /// @param {Function} callback (err, data) to be triggered with response
  /// @example
  /// orb.randomColor(function(err, data) {
  ///   print(err || 'Random Color!');
  /// });
  Future<Map<String, dynamic>> randomColor() {
    final rgb = randomRGBColor();
    return setRgbLed(rgb.red, rgb.green, rgb.blue);
  }

  ///
  /// Passes the color of the sphero Rgb LED to the callback (err, data)
  ///
  /// @example
  /// orb.getColor(function(err, data) {
  ///   if (err) {
  ///     print('error: ', err);
  ///   } else {
  ///     print('data:');
  ///     print('  color:', data.color);
  ///     print('  red:', data.red);
  ///     print('  green:', data.green);
  ///     print('  blue:', data.blue);
  ///   }
  /// });
  Future<Map<String, dynamic>> getColor() => getRgbLed();

  ///
  /// The Detect Collisions command sets up Sphero's collision detection system,
  /// and automatically parses asynchronous packets to re-emit collision events
  /// to 'collision' event listeners.
  ///
  /// @param {Object} opts device
  /// @param {Function} callback (err, data) to be triggered with response
  /// @example
  /// orb.detectCollisions();
  ///
  /// orb.on('collision', function(data) {
  ///   print('data:');
  ///   print('  x:', data.x);
  ///   print('  y:', data.y);
  ///   print('  z:', data.z);
  ///   print('  axis:', data.axis);
  ///   print('  xMagnitud:', data.xMagnitud);
  ///   print('  yMagnitud:', data.yMagnitud);
  ///   print('  speed:', data.timeStamp);
  ///   print('  timeStamp:', data.timeStamp);
  /// });
  Future<Map<String, dynamic>> detectCollisions(bool isBB8) {
    final t = isBB8 ? 0x20 : 0x40;
    final s = isBB8 ? 0x20 : 0x50;
    final dead = isBB8 ? 0x01 : 0x50;
    return configureCollisions(
        meth: 0x01, xt: t, yt: t, xs: s, ys: s, dead: dead);
  }

  ///
  /// The Detect Freefall command sets up Sphero's freefall detection system,
  /// and automatically listens to data events to emit freefall/landing events
  /// to 'freefall' or 'landing' event listeners.
  ///
  /// @param {Function} callback (err, data) to be triggered with response
  /// @example
  /// orb.detectFreefall();
  ///
  /// orb.on('freefall', function(data) {
  ///   print('freefall:');
  ///   print('  value:', data.value);
  /// });
  /// orb.on('landing', function(data) {
  ///   print('landing:');
  ///   print('  value:', data.value);
  /// });
  Future<Map<String, dynamic>> detectFreefall() {
    var falling = false;
    on('accelOne', (data) {
      if (data.accelOne.value[0] as int < 70 && !falling) {
        falling = true;
        emit('freefall', {'value': data.accelOne.value[0]});
      }
      if (data.accelOne.value[0] as int > 100 && falling) {
        falling = false;
        emit('landed', {'value': data.accelOne.value[0]});
      }
    });

    return streamAccelOne();
  }

  ///
  /// The Start Calibration command sets up Sphero for manual heading
  /// calibration.
  ///
  /// It does this by turning on the tail light (so you can tell where it's
  /// facing) and disabling stabilization (so you can adjust the heading).
  ///
  /// When done, call #finishCalibration to set the new heading, and re-enable
  /// stabilization.
  ///
  /// @param {Function} callback (err, data) to be triggered with response
  /// @example
  /// orb.startCalibration();
  Future<Map<String, dynamic>> startCalibration() async {
    final color = await getColor();
    originalColor = RGB(
        red: color['red'] as int,
        green: color['green'] as int,
        blue: color['blue'] as int);
    await setRgbLed(0, 0, 0);
    await setBackLed(127);
    return setStabiliation(false);
  }

  ///
  /// The Finish Calibration command ends Sphero's calibration mode, by setting
  /// the new heading as current, and re-enabling normal defaults
  ///
  /// @example
  /// orb.finishCalibration();
  Future<Map<String, dynamic>> finishCalibration() {
    setHeading(0);
    setRgbLed(originalColor.red, originalColor.green, originalColor.blue);
    return setDefaultSettings();
  }

  ///
  /// The setDefaultSettings command sets Sphero's settings back to sensible
  /// defaults, such as turning off the back LED, and re-enabling
  /// stabilization.
  ///
  /// @example
  /// orb.setDefaultSettings();
  Future<Map<String, dynamic>> setDefaultSettings() {
    setBackLed(0);
    return setStabiliation(true);
  }

  ///
  /// Starts streaming of odometer data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `odometer` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamOdometer();
  ///
  /// orb.on('odometer', function(data) {
  ///   print('data:');
  ///   print('  xOdomoter:', data.xOdomoter);
  ///   print('  yOdomoter:', data.yOdomoter);
  /// });
  Future<Map<String, dynamic>> streamOdometer([int sps, bool remove]) =>
      streamData(
        event: 'odometer',
        mask2: 0x0C000000,
        fields: ['xOdometer', 'yOdometer'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of velocity data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `velocity` event to get the velocity values.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamVelocity();
  ///
  /// orb.on('velocity', function(data) {
  ///   print('data:');
  ///   print('  xVelocity:', data.xVelocity);
  ///   print('  yVelocity:', data.yVelocity);
  /// });
  Future<Map<String, dynamic>> streamVelocity([int sps, bool remove]) =>
      streamData(
        event: 'velocity',
        mask2: 0x01800000,
        fields: ['xVelocity', 'yVelocity'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of accelOne data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `accelOne` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamAccelOne();
  ///
  /// orb.on('accelOne', function(data) {
  ///   print('data:');
  ///   print('  accelOne:', data.accelOne);
  /// });
  Future<Map<String, dynamic>> streamAccelOne([int sps, bool remove]) =>
      streamData(
        event: 'accelOne',
        mask2: 0x02000000,
        fields: ['accelOne'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of IMU angles data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `imuAngles` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamImuAngles();
  ///
  /// orb.on('imuAngles', function(data) {
  ///   print('data:');
  ///   print('  pitchAngle:', data.pitchAngle);
  ///   print('  rollAngle:', data.rollAngle);
  ///   print('  yawAngle:', data.yawAngle);
  /// });
  Future<Map<String, dynamic>> streamImuAngles([int sps, bool remove]) =>
      streamData(
        event: 'imuAngles',
        mask1: 0x00070000,
        fields: ['pitchAngle', 'rollAngle', 'yawAngle'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of accelerometer data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `accelerometer` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamAccelerometer();
  ///
  /// orb.on('accelerometer', function(data) {
  ///   print('data:');
  ///   print('  xAccel:', data.xAccel);
  ///   print('  yAccel:', data.yAccel);
  ///   print('  zAccel:', data.zAccel);
  /// });
  Future<Map<String, dynamic>> streamAccelerometer([int sps, bool remove]) =>
      streamData(
        event: 'accelerometer',
        mask1: 0x0000E000,
        fields: ['xAccel', 'yAccel', 'zAccel'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of gyroscope data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `gyroscope` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamGyroscope();
  ///
  /// orb.on('gyroscope', function(data) {
  ///   print('data:');
  ///   print('  xGyro:', data.xGyro);
  ///   print('  yGyro:', data.yGyro);
  ///   print('  zGyro:', data.zGyro);
  /// });
  Future<Map<String, dynamic>> streamGyroscope([int sps, bool remove]) =>
      streamData(
        event: 'gyroscope',
        mask1: 0x00001C00,
        fields: ['xGyro', 'yGyro', 'zGyro'],
        sps: sps,
        remove: remove,
      );

  ///
  /// Starts streaming of motor back EMF data
  ///
  /// It uses sphero's data streaming command. User needs to listen
  /// for the `dataStreaming` or `motorsBackEmf` event to get the data.
  ///
  /// @param {Number} [sps=5] samples per second
  /// @param {Boolean} [remove=false] forces velocity streaming to stop
  /// @example
  /// orb.streamMotorsBackEmf();
  ///
  /// orb.on('motorsBackEmf', function(data) {
  ///   print('data:');
  ///   print('  rMotorBackEmf:', data.rMotorBackEmf);
  ///   print('  lMotorBackEmf:', data.lMotorBackEmf);
  /// });
  Future<Map<String, dynamic>> streamMotorsBackEmf([int sps, bool remove]) =>
      streamData(
        event: 'motorsBackEmf',
        mask1: 0x00000060,
        fields: ['rMotorBackEmf', 'lMotorBackEmf'],
        sps: sps,
        remove: remove,
      );

  ///
  /// The Stop On Disconnect command sends a flag to Sphero. This flag tells
  /// Sphero whether or not it should automatically stop when it detects
  /// that it's disconnected.
  ///
  /// @param {Boolean} [remove=false] whether or not to stop on disconnect
  /// @param {Function} callback triggered on complete
  /// @example
  /// orb.stopOnDisconnect(function(err, data) {
  ///   print(err || 'data' + data);
  /// });
  Future<Map<String, dynamic>> stopOnDisconnect([bool remove = false]) =>
      setTempOptionFlags(remove.intFlag);

  ///
  /// Stops sphero the optimal way by setting flag 'go' to 0
  /// and speed to a very low value.
  ///
  /// @param {Function} callback triggered on complete
  /// @example
  /// sphero.stop(function(err, data) {
  ///   print(err || 'data' + data);
  /// });
  Future<Map<String, dynamic>> stop() => roll(0, 0, 0);
}
