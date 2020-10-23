import 'packets.dart';

abstract class IBluetooth {
  IBluetooth();

  Iterable<int> read() {}

  int write(List<int> buf) {}

  void close() {}
}
