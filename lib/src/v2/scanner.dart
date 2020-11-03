import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:dartx/dartx.dart';
import 'toys/index.dart';

class ToyDiscovered<T extends Core> extends ToyAdvertisement<T> {
  ToyDiscovered.fromAdvertisement(ToyAdvertisement<T> toy, {this.peripheral})
      : super(name: toy.name, typeof: toy.typeof, prefix: toy.prefix);
  final ScanResult peripheral;
}

Future<Core> startToy(Core toy) async {
  print('Starting...');
  await toy.start();

  print('Started');
  final version = await toy.appVersion();

  print('Version $version');
  final battery = await toy.batteryLevel();

  print('Battery $battery');
  return toy;
}

extension BleManagerXV2 on BleManager {
  /// Searches (but does not start) toys that match the passed criteria
  Future<List<ToyDiscovered>> findToys(List<ToyAdvertisement> toysType) async {
    print('findToys');
    final toys = <ToyDiscovered>[];

    print('Scanning devices...');
    startPeripheralScan().listen((sr) {
      sr.discover(toysType, toys);
    });
    print('findToys-wait5seconds');
    await Future.delayed(5000.milliseconds);
    await stopPeripheralScan();
    print('Done scanning devices.');
    return toys;
  }

  /// Searches toys that match the passed criteria,
  /// starts the first found toy and returns it
  Future<T> find<T extends Core>(ToyAdvertisement toyType,
      [String name]) async {
    final discovered = await findToys([toyType]);
    final discoveredItem = discovered.firstOrNullWhere(
            (item) => item.peripheral.advertisementData.localName == name) ??
        discovered[0];

    if (discoveredItem == null) {
      print('Not found');
      return null;
    }

    final toy = toyType.typeof(discoveredItem.peripheral.peripheral);

    await startToy(toy);

    return toy as T;
  }

  /// Searches toys that match the passed criteria, starts and returns them
  Future<List<Core>> findAll(ToyAdvertisement toyType) async {
    final discovered = await findToys([toyType]);
    if (discovered.isNotEmpty) {
      // Init toys and return array
      return Future.wait(discovered.fold(<Future<Core>>[], (toyArray, item) {
        final toy = toyType.typeof(item.peripheral.peripheral);
        return [...toyArray, Future(() => startToy(toy))];
      }));
    } else {
      print('Not found');
    }
  }

  /// Searches BB9E toys, starts the first one that was found and returns it
  // ignore: unused_element
  Future<BB9E> findBB9E() async => await find(BB9E.advertisement) as BB9E;

  /// Searches R2D2 toys, starts the first one that was found and returns it
  // ignore: unused_element
  Future<R2D2> findR2D2() async => await find(R2D2.advertisement) as R2D2;

  /// Searches R2Q5 toys, starts the first one that was found and returns it
  // ignore: unused_element
  Future<R2Q5> findR2Q5() async => await find(R2Q5.advertisement) as R2Q5;

  /// Searches Sphero Mini toys, starts the first one that was
  /// found and returns it
  // ignore: unused_element
  Future<SpheroMini> findSpheroMini() async =>
      await find(SpheroMini.advertisement) as SpheroMini;

  /// Searches a Sphero Mini toy with the passed name, starts and returns it
  // ignore: unused_element
  Future<SpheroMini> findSpheroMiniByName(String name) async =>
      await find(SpheroMini.advertisement, name) as SpheroMini;

  /// Searches for all available Sphero Mini toys, starts and returns them
  // ignore: unused_element
  Future<List<SpheroMini>> findAllSpheroMini() async =>
      (await findAll(SpheroMini.advertisement)).cast<SpheroMini>();

  /// Searches Lightning McQueen toys, starts the first one
  ///  that was found and returns it
  // ignore: unused_element
  Future<LightningMcQueen> findLightningMcQueen() async =>
      await find(LightningMcQueen.advertisement) as LightningMcQueen;
}

extension on ScanResult {
  Future<void> discover(
    List<ToyAdvertisement> validToys,
    List<ToyDiscovered> toys,
  ) async {
    // print('Discovered ${advertisementData.localName}');

    final localName = advertisementData.localName ?? '';
    for (final toyAdvertisement in validToys) {
      if (localName.indexOf(toyAdvertisement.prefix) == 0) {
        toys.add(ToyDiscovered.fromAdvertisement(toyAdvertisement,
            peripheral: this));

        print('''name: ${toyAdvertisement.name},
   uuid: ${peripheral.identifier},
   mac-address: ${peripheral.identifier}''');
      }
    }
  }
}
