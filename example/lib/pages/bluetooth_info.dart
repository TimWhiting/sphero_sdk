import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/state.dart';

class BluetoothPage extends ConsumerWidget {
  const BluetoothPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(selectedDeviceProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Bluetooth Info:'),
        Text('Name: ${device?.advertisementData.localName}'),
        Text('BTAddress: ${device?.advertisementData.localName}'),
        const Text('Colors: ${'red'}'),
      ],
    );
  }
}
