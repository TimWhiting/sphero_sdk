import 'package:dartx/dartx.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'common/state.dart';
import 'pages/bluetooth_info.dart';
import 'pages/version_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(bleManagerProvider);
    final devices = ref.watch(allDevicesProvider);
    final deviceName = ref.watch(selectedDeviceNameProvider);
    final pageIndex = useState(0);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                result.when(
                  data: (_) => const Text('Connected'),
                  error: (e, st) => Text(e.toString()),
                  loading: () => const Text('Connecting'),
                ),
                DropdownButton<String>(
                  value: deviceName,
                  onChanged: (v) =>
                      ref.read(selectedDeviceNameProvider.notifier).state = v,
                  items: devices.entries
                      .map(
                        (d) => DropdownMenuItem(
                          value: d.key,
                          child: Text(
                            d.value.advertisementData.localName,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(child: Pages.values[pageIndex.value].widget),
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
                    EnumToString.convertToString(
                      Pages.values[tab],
                      camelCase: true,
                    ),
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
        return const VersionPage();
      case Pages.Calibration:
        break;
      case Pages.CollisionDetection:
        break;
      case Pages.Color:
        break;
      case Pages.Conway:
        break;
      case Pages.DataStreaming:
        break;
      case Pages.Freefall:
        break;
      case Pages.GetColor:
        break;
      case Pages.Keyboard:
        break;
      case Pages.Location:
        break;
      case Pages.Luminance:
        break;
      case Pages.Roll:
        break;
      case Pages.Shakeometer:
        break;
      case Pages.StreamAccelOne:
        break;
      case Pages.StreamAccel:
        break;
      case Pages.StreamGyro:
        break;
      case Pages.StreamIMUAngles:
        break;
      case Pages.StreamMotorsBackEMF:
        break;
      case Pages.StreamOdometer:
        break;
      case Pages.StreamVelocity:
        break;
      case Pages.Version:
        return const VersionPage();
    }
    return const BluetoothPage();
  }
}
