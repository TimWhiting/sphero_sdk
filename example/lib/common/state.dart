import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sphero_sdk/sphero_sdk.dart';

final bleManagerProvider = FutureProvider<FlutterBlue>((ref) async {
  await Permission.location.request();
  final manager = FlutterBlue.instance;
  try {
    await manager.setLogLevel(LogLevel.error);
    manager.startScan().listen((sr) {
      ref.read(allDevicesProvider.notifier).state =
          ref.read(allDevicesProvider.notifier).state..[sr.device.name] = sr;
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
