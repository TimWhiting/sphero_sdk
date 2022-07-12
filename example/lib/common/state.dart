import 'package:dartx/dartx.dart';
import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sphero_sdk/sphero_sdk.dart';

final bleManagerProvider = FutureProvider<FlutterBlue>((ref) async {
  var res = await Permission.location.request();
  assert(res.isGranted, 'Location permission');
  res = await Permission.bluetoothScan.request();
  assert(res.isGranted, 'Scan permission');
  res = await Permission.bluetoothConnect.request();
  assert(res.isGranted, 'Connect permission');
  res = await Permission.bluetooth.request();
  assert(res.isGranted, 'Bluetooth permission');
  final manager = FlutterBlue.instance;
  try {
    await manager.setLogLevel(LogLevel.error);

    print('Searching');
    manager.startScan(timeout: 5.seconds);
    manager.scanResults.listen((sr) {
      print('Found $sr');
      ref
          .read(allDevicesProvider.notifier)
          .update((m) => {for (final s in sr) s.device.name: s});
    });
  } on Exception catch (e) {
    print(e);
  }
  return manager;
});
final allDevicesProvider = StateProvider<Map<String, ScanResult>>((ref) => {});
final selectedDeviceNameProvider = StateProvider<String?>((ref) => null);
final selectedDeviceProvider = StateProvider<ScanResult?>((ref) {
  final selectedDeviceName = ref.watch(selectedDeviceNameProvider);
  final allDevices = ref.watch(allDevicesProvider);
  if (selectedDeviceName != null) {
    return allDevices[selectedDeviceName];
  }
  return null;
});

final spheroProvider = FutureProvider<Sphero?>((ref) async {
  final manager = ref
      .watch(bleManagerProvider)
      .maybeMap(data: (b) => b, orElse: () => null);
  if (manager == null) {
    return null;
  }
  final sphero = await manager.value.findSPRKPlus();
  return sphero;
});
