import 'package:example/common/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';

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
