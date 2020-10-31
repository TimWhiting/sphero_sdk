import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dartx/dartx.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomePage(),
      );
}

final bleManagerProvider = FutureProvider<BleManager>((ref) async {
  await Permission.location.request();
  final manager = BleManager();
  await manager.createClient(); //ready to go!
  try {
    manager.startPeripheralScan().listen((sr) {
      ref.read(allDevicesProvider).state = ref.read(allDevicesProvider).state
        ..[sr.peripheral.name] = sr;
    });
  } on Exception catch (e) {
    print(e);
  }
  return manager;
});
final allDevicesProvider = StateProvider<Map<String, ScanResult>>((ref) => {});
final selectedDeviceNameProvider = StateProvider<String>((ref) => null);
final selectedDeviceProvider = StateProvider<ScanResult>((ref) => ref
    .watch(allDevicesProvider)
    .state[ref.watch(selectedDeviceNameProvider).state]);

class HomePage extends HookWidget {
  const HomePage();
  @override
  Widget build(BuildContext context) {
    useProvider(bleManagerProvider);
    final devices = useProvider(allDevicesProvider).state;
    final deviceName = useProvider(selectedDeviceNameProvider).state;
    final pageIndex = useState(0);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (devices != null)
                  DropdownButton<String>(
                    value: deviceName,
                    onChanged: (v) =>
                        context.read(selectedDeviceNameProvider).state = v,
                    items: devices.entries
                        .map(
                          (d) => DropdownMenuItem(
                            value: d.key,
                            child: Text(
                              d.value?.advertisementData?.localName ?? '',
                            ),
                          ),
                        )
                        .toList(),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Pages.values[pageIndex.value].widget,
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final tab in 0.rangeTo(Pages.values.length - 1))
                TextButton(
                  child: Text(
                    EnumToString.convertToString(Pages.values[tab],
                        camelCase: true),
                  ),
                  onPressed: () => pageIndex.value = tab,
                )
            ],
          ),
        ),
      ),
    );
  }
}

class BluetoothPage extends HookWidget {
  const BluetoothPage();
  @override
  Widget build(BuildContext context) {
    final device = useProvider(selectedDeviceProvider).state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bluetooth Info:'),
        Text('Name: ${device?.advertisementData?.localName}'),
        Text('BTAddress: ${device?.peripheral?.identifier}'),
        const Text('Colors: ${'red'}'),
      ],
    );
  }
}

enum Pages {
  BluetoothInfo,
  Calibration,
  CollisionDetection,
  Color,
  Conway,
  DataStreaming,
  Freefall,
  GetColor,
  Keyboard,
  Location,
  Luminance,
  Roll,
  Shakeometer,
  StreamAccelOne,
  StreamAccel,
  StreamGyro,
  StreamIMUAngles,
  StreamMotorsBackEMF,
  StreamOdometer,
  StreamVelocity,
  Version,
}

extension NavX on Pages {
  Widget get widget {
    switch (this) {
      case Pages.BluetoothInfo:
        return BluetoothPage();
      case Pages.Calibration:
        // TODO: Handle this case.
        break;
      case Pages.CollisionDetection:
        // TODO: Handle this case.
        break;
      case Pages.Color:
        // TODO: Handle this case.
        break;
      case Pages.Conway:
        // TODO: Handle this case.
        break;
      case Pages.DataStreaming:
        // TODO: Handle this case.
        break;
      case Pages.Freefall:
        // TODO: Handle this case.
        break;
      case Pages.GetColor:
        // TODO: Handle this case.
        break;
      case Pages.Keyboard:
        // TODO: Handle this case.
        break;
      case Pages.Location:
        // TODO: Handle this case.
        break;
      case Pages.Luminance:
        // TODO: Handle this case.
        break;
      case Pages.Roll:
        // TODO: Handle this case.
        break;
      case Pages.Shakeometer:
        // TODO: Handle this case.
        break;
      case Pages.StreamAccelOne:
        // TODO: Handle this case.
        break;
      case Pages.StreamAccel:
        // TODO: Handle this case.
        break;
      case Pages.StreamGyro:
        // TODO: Handle this case.
        break;
      case Pages.StreamIMUAngles:
        // TODO: Handle this case.
        break;
      case Pages.StreamMotorsBackEMF:
        // TODO: Handle this case.
        break;
      case Pages.StreamOdometer:
        // TODO: Handle this case.
        break;
      case Pages.StreamVelocity:
        // TODO: Handle this case.
        break;
      case Pages.Version:
        // TODO: Handle this case.
        break;
    }
    return BluetoothPage();
  }
}
