// ignore_for_file: avoid_print

import 'dart:async';

import 'package:dartx/dartx.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_blue/flutter_blue.dart' as blue;

import 'adaptor.dart';
import 'sphero.dart';

export 'adaptor.dart';
export 'adaptor_blue.dart';
export 'sphero.dart';

class ToyAdvertisement<T extends Sphero> {
  const ToyAdvertisement({
    required this.name,
    required this.prefix,
    required this.typeof,
  });
  final String name;
  final String prefix;
  final T Function(SpheroPeripheral) typeof;
}

class ToyDiscovered<T extends Sphero> extends ToyAdvertisement<T> {
  ToyDiscovered.fromAdvertisement(
    ToyAdvertisement<T> toy, {
    required this.peripheral,
  }) : super(name: toy.name, typeof: toy.typeof, prefix: toy.prefix);
  final SpheroPeripheral peripheral;
}

Future<T> startToy<T extends Sphero>(T toy) async {
  print('Starting...');
  await toy.connect();
  try {
    print('Started');
    final version = await toy.version();

    print('Version $version');
    final battery = await toy.getPowerState();

    print('Battery $battery');
    Timer.periodic(100.milliseconds, (_) => toy.ping());
  } on Exception {
    print('Exception while starting toy');
  }

  return toy;
}

// ignore: non_constant_identifier_names
final SPRKPlus = ToyAdvertisement(
  name: 'Spark+',
  prefix: 'SK',
  typeof: (p) => Sphero(p.identifier, adaptor: AdaptorV1(p.identifier, p)),
);

extension BluetoothX on blue.FlutterBlue {
  /// Searches (but does not start) toys that match the passed criteria
  Future<List<ToyDiscovered>> findToys(List<ToyAdvertisement> toysType) async {
    print('findToys');
    final toys = <ToyDiscovered>[];

    print('Scanning devices...');
    await startScan(timeout: 4.seconds);
    scanResults.listen((sr) {
      for (final s in sr) {
        s.discover(toysType, toys);
      }
    });
    await Future<void>.delayed(4.seconds);

    await stopScan();

    print('Done scanning devices.');
    return toys;
  }

  /// Searches toys that match the passed criteria,
  /// starts the first found toy and returns it
  Future<T?> find<T extends Sphero>(
    ToyAdvertisement toyType, [
    String? name,
  ]) async {
    final discovered = await findToys([toyType]);
    final discoveredItem =
        discovered.firstOrNullWhere((item) => item.peripheral.name == name) ??
            (discovered.isNotEmpty ? discovered[0] : null);

    if (discoveredItem == null) {
      print('Not found');
      return null;
    }

    final toy = toyType.typeof(discoveredItem.peripheral);
    print('connecting to $toy');
    await startToy(toy);
    print('found toy');

    return toy as T;
  }

  /// Searches toys that match the passed criteria, starts and returns them
  Future<List<Sphero>> findAll(ToyAdvertisement toyType) async {
    final discovered = await findToys([toyType]);
    if (discovered.isNotEmpty) {
      // Init toys and return array
      return Future.wait(
        discovered.fold(<Future<Sphero>>[], (toyArray, item) {
          final toy =
              toyType.typeof(SpheroPeripheral(item.peripheral.peripheral));
          return [...toyArray, Future(() => startToy(toy))];
        }),
      );
    } else {
      print('Not found');
      return [];
    }
  }

  /// Searches Sprk+ toys, starts the first one that was found and returns it
  // ignore: unused_element
  Future<Sphero?> findSPRKPlus() => find(SPRKPlus);
}

extension on blue.ScanResult {
  Future<void> discover(
    List<ToyAdvertisement> validToys,
    List<ToyDiscovered> toys,
  ) async {
    final localName = advertisementData.localName;

    final peripheral = SpheroPeripheral(device);
    for (final toyAdvertisement in validToys) {
      if (localName.indexOf(toyAdvertisement.prefix) == 0) {
        toys.add(
          ToyDiscovered.fromAdvertisement(
            toyAdvertisement,
            peripheral: peripheral,
          ),
        );

        print('''
name: ${toyAdvertisement.name},
   uuid: ${peripheral.identifier},
   mac-address: ${peripheral.identifier}''');
      }
    }
  }
}
