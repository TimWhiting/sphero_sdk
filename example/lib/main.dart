import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void main() {
  runApp(MyApp());
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

class HomePage extends HookWidget {
  const HomePage();
  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: Pages.values.length);
    return Scaffold(
      body: TabBarView(controller: tabController, children: [for (final tab in Pages.values) tab.widget])
      bottomNavigationBar: TabBar(tabs: [for (final tab in Pages.values) TabBarView()]),
    );
  }
}

class BluetoothPage extends HookWidget {
  const BluetoothPage();
  @override
  Widget build(BuildContext context) {
    return ();
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
