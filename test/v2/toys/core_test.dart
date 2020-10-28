import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sphero_sdk/src/v2/toys/index.dart';

class PeripheralMock extends Mock implements Peripheral {
  PeripheralMock() {
    when(discoverAllServicesAndCharacteristics()).thenReturn(null);
    when(services()).thenAnswer((_) => Future.value(_services));
    when(connect()).thenReturn(null);
  }
  final _services = [
    ServiceMock(
      [
        CharacteristicMock(CharacteristicUUID.apiV2Characteristic),
        CharacteristicMock(CharacteristicUUID.antiDoSCharacteristic)
      ],
      uuid: ServicesUUID.apiV2ControlService,
    ),
    ServiceMock(
      [
        CharacteristicMock(CharacteristicUUID.dfuControlCharacteristic),
        CharacteristicMock(CharacteristicUUID.dfuInfoCharacteristic),
      ],
      uuid: ServicesUUID.nordicDfuService,
    )
  ];
}

// ignore: avoid_implementing_value_types
class CharacteristicMock extends Mock implements Characteristic {
  CharacteristicMock(this.uuidMock) {
    when(monitor(transactionId: anyNamed('transactionId'))).thenAnswer((_) {
      print('Returning stream');
      return Stream.value(Uint8List(1));
    });
    when(uuid).thenReturn(uuidMock);

    when(write(any, true)).thenAnswer((realInvocation) => null);
  }

  final String uuidMock;
}

// ignore: avoid_implementing_value_types
class ServiceMock extends Mock implements Service {
  ServiceMock(this.characteristicsMock, {this.uuid}) {
    when(characteristics())
        .thenAnswer((_) => Future.value(characteristicsMock));
  }
  final List<Characteristic> characteristicsMock;
  @override
  final String uuid;
}

void main() {
  test('Toy', () async {
    final peripheral = PeripheralMock();

    final toy = Core(peripheral);

    expect(toy.start, throwsA('Command Timedout'));
  });
}
