import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../common/state.dart';

final versionProvider = FutureProvider<String>((ref) async {
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

    return RefreshIndicator(
      onRefresh: () async => ref.refresh(spheroProvider.future),
      child: ListView(
        children: [
          Center(child: Text('Version: ${version.asData?.value ?? ''}')),
        ],
      ),
    );
  }
}
