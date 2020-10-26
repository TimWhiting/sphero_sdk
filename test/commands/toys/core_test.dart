import 'dart:typed_data';

import 'package:flutter_ble_lib/flutter_ble_lib.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sphero_sdk/src/toys/core.dart';
import 'package:sphero_sdk/src/toys/types.dart';

class PeripheralMock extends Mock implements Peripheral {
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
  PeripheralMock() {
    when(discoverAllServicesAndCharacteristics()).thenReturn(null);
    when(services()).thenAnswer((_) => Future.value(_services));
    when(connect()).thenReturn(null);
  }
}

class CharacteristicMock extends Mock implements Characteristic {
  final String uuidMock;

  CharacteristicMock(this.uuidMock) {
    when(monitor(transactionId: anyNamed('transactionId'))).thenAnswer((_) {
      print('Returning stream');
      return Stream.value(Uint8List(1));
    });
    when(uuid).thenReturn(uuidMock);
    when(write(any, true)).thenAnswer((realInvocation) => null);
  }
}

class ServiceMock extends Mock implements Service {
  final List<Characteristic> characteristicsMock;
  final String uuid;

  ServiceMock(this.characteristicsMock, {this.uuid}) {
    when(characteristics())
        .thenAnswer((_) => Future.value(characteristicsMock));
  }
}

void main() {
  test('Toy', () async {
    final peripheral = PeripheralMock();

    final toy = Core(peripheral);

    expect(toy.start(), completes);
  });
}
