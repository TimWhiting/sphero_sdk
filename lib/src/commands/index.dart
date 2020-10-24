import 'api.dart';
import 'driving.dart';
import 'power.dart';
import 'sensor.dart';
import 'something_api.dart';
import 'system_info.dart';
import 'types.dart';
import 'user_io.dart';

final sequencer = () {
  var s = 0;
  return () {
    var temp = s;
    s += 1;
    if (s >= 255) {
      s = 0;
    }
    return temp;
  };
};

final factory = ({int Function() seq}) {
  final getSequence = seq ?? sequencer();

  final gen = (int deviceId) => (Command part) => Command.fromPart(
      commandFlags: [Flags.requestsResponse, Flags.resetsInactivityTimeout],
      deviceId: deviceId,
      sequenceNumber: getSequence(),
      part: part);

  return Device(
      api: API(gen),
      driving: Driving(gen),
      power: Power(gen),
      somethingApi: SomethingAPI(gen),
      systemInfo: SystemInfo(gen),
      userIO: UserIO(gen),
      sensor: Sensor(gen));
};

class Device {
  final API api;
  final Driving driving;
  final Power power;
  final SomethingAPI somethingApi;
  final SystemInfo systemInfo;
  final UserIO userIO;
  final Sensor sensor;

  Device(
      {this.api,
      this.driving,
      this.power,
      this.somethingApi,
      this.systemInfo,
      this.userIO,
      this.sensor});
}
