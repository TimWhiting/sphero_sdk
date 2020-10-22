class Adaptor {
  Adaptor(this.name, this.port, this._serialPort, this.connected,
      this.serialConnect);
  final String name;
  final Function(String) serialConnect;
  String port;
  dynamic _serialPort;
  bool connected;
  void connect() {
    try {
      _serialPort = serialConnect(port);
      connected = true;
    } on Exception {}
  }

  void disconnect() {
    if (connected) {
      try {
        _serialPort.close();
        connected = false;
      } on Exception {}
    }
  }

  void reconnect() {
    if (connected) {
      disconnect();
    }
    connect();
  }

  void dispose() {
    disconnect();
  }
}
