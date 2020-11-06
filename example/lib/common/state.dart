import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sphero_sdk/sphero_sdk.dart';

final bleManagerProvider = FutureProvider<BleManager>((ref) async {
  await Permission.location.request();
  final manager = BleManager();
  await manager.createClient(); //ready to go!
  try {
    await manager.setLogLevel(LogLevel.error);
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
final selectedDeviceProvider = StateProvider<ScanResult>((ref) {
  final selectedDeviceName = ref.watch(selectedDeviceNameProvider).state;
  final allDevices = ref.watch(allDevicesProvider).state;
  if (selectedDeviceName != null) {
    return allDevices[selectedDeviceName];
  }
  return null;
});

final spheroProvider = FutureProvider<Sphero>((ref) async {
  final manager = ref
      .watch(bleManagerProvider)
      .maybeMap(data: (b) => b, orElse: () => null);
  if (manager == null) {
    return null;
  }
  final sphero = await manager.value.findSPRKPlus();
  return sphero;
});
