import 'package:example/common/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:sphero_sdk/sphero_sdk.dart';

final versionProvider = FutureProvider<String>((ref) async {
  final sphero = ref.watch(spheroProvider).maybeMap(
        data: (d) => d.value,
        orElse: () => null,
      );
  if (sphero == null) {
    return '';
  }
  return (await sphero.version()).toString();
});

class VersionPage extends HookWidget {
  const VersionPage();
  @override
  Widget build(BuildContext context) {
    final version = useProvider(versionProvider);

    return RefreshIndicator(
      onRefresh: () => context.refresh(spheroProvider),
      child: ListView(
        children: [
          Center(child: Text('Version: ${version.data?.value ?? ''}')),
        ],
      ),
    );
  }
}
