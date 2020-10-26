import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:dartx/dartx.dart';
import 'toys/index.dart';
import 'toys/types.dart';

class ToyDiscovered extends ToyAdvertisement {
  final ScanResult peripheral;

  ToyDiscovered.fromAdvertisement(ToyAdvertisement toy, {this.peripheral})
      : super(name: toy.name, typeof: toy.typeof, prefix: toy.prefix);
}

Future<void> startToy(Core toy) async {
  print('Starting...');
  await toy.start();

  print('Started');
  final version = await toy.appVersion();

  print('Version $version');
  final battery = await toy.batteryLevel();

  print('Battery $battery');
}

extension on BleManager {
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

  /// Searches toys that match the passed criteria, starts the first found toy and returns it
  Future<T> find<T extends Core>(ToyAdvertisement toyType,
      [String name]) async {
    final discovered = await findToys([toyType]);
    final discoveredItem = discovered.firstWhere(
            (item) => item.peripheral.advertisementData.localName == name) ??
        discovered[0];

    if (discoveredItem == null) {
      print('Not found');
      return null;
    }

    final Core toy = toyType.typeof(discoveredItem.peripheral.peripheral);

    await startToy(toy);

    return toy as T;
  }

  /// Searches toys that match the passed criteria, starts and returns them
  findAll(ToyAdvertisement toyType) async {
    final discovered = await findToys([toyType]);
    if (discovered.length > 0) {
      // Init toys and return array
      return await Future.wait(
          discovered.fold(<Future<Core>>[], (toyArray, item) {
        final Core toy = toyType.typeof(item.peripheral.peripheral);
        return [...toyArray, Future(() => startToy(toy))];
      }));
    } else {
      print('Not found');
    }
  }

  /// Searches BB9E toys, starts the first one that was found and returns it
  Future<BB9E> findBB9E() async {
    return (await find(BB9E.advertisement)) as BB9E;
  }

  /// Searches R2D2 toys, starts the first one that was found and returns it
  Future<R2D2> findR2D2() async {
    return (await find(R2D2.advertisement)) as R2D2;
  }

  /// Searches R2Q5 toys, starts the first one that was found and returns it
  Future<R2Q5> findR2Q5() async {
    return (await find(R2Q5.advertisement)) as R2Q5;
  }

  /// Searches Sphero Mini toys, starts the first one that was found and returns it
  Future<SpheroMini> findSpheroMini() async {
    return (await find(SpheroMini.advertisement)) as SpheroMini;
  }

  /// Searches a Sphero Mini toy with the passed name, starts and returns it
  Future<SpheroMini> findSpheroMiniByName(String name) async {
    return (await find(SpheroMini.advertisement, name)) as SpheroMini;
  }

  /// Searches for all available Sphero Mini toys, starts and returns them
  Future<List<SpheroMini>> findAllSpheroMini() async {
    return (await findAll(SpheroMini.advertisement)).cast<SpheroMini>();
  }

  /// Searches Lightning McQueen toys, starts the first one that was found and returns it
  Future<LightningMcQueen> findLightningMcQueen() async {
    return (await find(LightningMcQueen.advertisement)) as LightningMcQueen;
  }
}

extension on ScanResult {
  Future<void> discover(
    List<ToyAdvertisement> validToys,
    List<ToyDiscovered> toys,
  ) async {
    print('Discovered ${peripheral.identifier}');

    final localName = advertisementData.localName ?? '';
    validToys.forEach((toyAdvertisement) {
      if (localName.indexOf(toyAdvertisement.prefix) == 0) {
        toys.add(ToyDiscovered.fromAdvertisement(toyAdvertisement,
            peripheral: this));

        print(
            'name: ${toyAdvertisement.name}, uuid: ${peripheral.identifier}, mac-address: ${peripheral.identifier}');
      }
    });
  }
}
