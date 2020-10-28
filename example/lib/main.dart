import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

final deviceProvider = StateProvider<Map<String, ScanResult>>((ref) => {});

class HomePage extends HookWidget {
  const HomePage();
  @override
  Widget build(BuildContext context) {
    useMemoized(() async {
      // ignore: unused_local_variable
      final permissionStatus = await Permission.location.request();
      BleManager manager = BleManager();
      await manager.createClient(); //ready to go!

      manager.startPeripheralScan().listen((sr) {
        context.read(deviceProvider).state = context.read(deviceProvider).state
          ..[sr.peripheral.name] = sr;
      });
    });
    final pageIndex = useState(0);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                OutlineButton(
                  child: Text('Connect'),
                  onPressed: () {},
                ),

                // DropdownButton(), TODO Search for devices and list them
              ],
            ),
            Pages.values[pageIndex.value].widget,
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (i) => pageIndex.value = i,
          items: [
            for (final tab in Pages.values)
              BottomNavigationBarItem(
                label: EnumToString.convertToString(tab, camelCase: true),
                icon: Icon(Icons.add),
              )
          ],
        ),
      ),
    );
  }
}

class BluetoothPage extends HookWidget {
  const BluetoothPage();
  @override
  Widget build(BuildContext context) {
    final devices = useProvider(deviceProvider).state.values.toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Bluetooth Info'),
        Text('Name: '),
        Text('BTAddress: '),
        Text('Separator: '),
        Text('Colors: '),
        ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: devices.length,
          shrinkWrap: true,
          itemBuilder: (c, i) => Text(
              devices[i]?.advertisementData?.localName ?? '',
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(color: Colors.green)),
        ),
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
