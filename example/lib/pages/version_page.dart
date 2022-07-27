import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sphero_sdk/sphero_sdk.dart';

import '../common/state.dart';

final versionProvider = FutureProvider.autoDispose<String>((ref) async {
  final sphero = ref.watch(spheroProvider).maybeMap(
        data: (d) => d.value,
        orElse: () => null,
      );
  if (sphero == null) {
    return '';
  }
  // return (await sphero.version()).toString();
  return '';
});

class VersionPage extends ConsumerWidget {
  const VersionPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final version = ref.watch(versionProvider);
    final sphero = ref.watch(spheroProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(spheroProvider.future),
      child: ListView(
        children: [
          Center(child: Text('Version: ${version.asData?.value ?? ''}')),
          ElevatedButton(
            child: const Text('Change color'),
            onPressed: () async {
              await sphero.maybeWhen(
                data: (sphero) async {
                  await sphero?.randomColor();
                  sphero?.roll(255, Random().nextInt(255)).ignore();
                  await Future<void>.delayed(const Duration(seconds: 1));
                  await sphero?.stop();
                },
                orElse: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
