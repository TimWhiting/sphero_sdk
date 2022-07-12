import 'api.dart';
import 'driving.dart';
import 'power.dart';
import 'sensor.dart';
import 'something_api.dart';
import 'system_info.dart';
import 'types.dart';
import 'user_io.dart';

export 'api.dart';
export 'decoder.dart';
export 'driving.dart';
export 'encoder.dart';
export 'power.dart';
export 'sensor.dart';
export 'something_api.dart';
export 'system_info.dart';
export 'types.dart';
export 'user_io.dart';

int Function() sequencer() {
  var s = 0;
  return () {
    final temp = s;
    s += 1;
    if (s >= 255) {
      s = 0;
    }
    return temp;
  };
}

Device commandsFactory([int Function()? seq]) {
  final getSequence = seq ?? sequencer();

  Command Function(CommandPartial part) gen(DeviceId deviceId) => (part) =>
      Command.fromPart(
        commandFlags: [Flags.requestsResponse, Flags.resetsInactivityTimeout],
        deviceId: deviceId,
        sequenceNumber: getSequence(),
        part: part,
      );

  return Device(
    api: API(gen),
    driving: Driving(gen),
    power: Power(gen),
    somethingApi: SomethingAPI(gen),
    systemInfo: SystemInfo(gen),
    userIO: UserIO(gen),
    sensor: Sensor(gen),
  );
}

class Device {
  const Device({
    required this.api,
    required this.driving,
    required this.power,
    required this.somethingApi,
    required this.systemInfo,
    required this.userIO,
    required this.sensor,
  });
  final API api;
  final Driving driving;
  final Power power;
  final SomethingAPI somethingApi;
  final SystemInfo systemInfo;
  final UserIO userIO;
  final Sensor sensor;
}
