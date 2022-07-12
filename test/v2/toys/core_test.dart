// ignore_for_file: null_argument_to_non_null_type

import 'package:flutter_blue_plugin/flutter_blue_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sphero_sdk/src/v2/toys/index.dart';

// ignore: avoid_implementing_value_types
class PeripheralMock extends Mock implements BluetoothDevice {
  PeripheralMock() {
    when(discoverServices()).thenReturn(Future.value());
    when(services).thenAnswer((_) => Stream.value(_services));
    when(connect()).thenReturn(Future.value());
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
class CharacteristicMock extends Mock implements BluetoothCharacteristic {
  CharacteristicMock(this.uuidMock) {
    when(setNotifyValue(true)).thenAnswer((_) async => true);
    when(uuid).thenReturn(uuidMock);

    when(write([], withoutResponse: true))
        .thenAnswer((realInvocation) => Future.value(null));
  }

  final Guid uuidMock;
}

// ignore: avoid_implementing_value_types
class ServiceMock extends Mock implements BluetoothService {
  ServiceMock(this.characteristicsMock, {required this.uuid}) {
    when(characteristics).thenAnswer((_) => characteristicsMock);
  }
  final List<BluetoothCharacteristic> characteristicsMock;
  @override
  final Guid uuid;
}

void main() {
  test('Toy', () async {
    final peripheral = PeripheralMock();

    final toy = Core(peripheral);

    expect(toy.start, throwsA('Command Timed Out'));
  });
}
