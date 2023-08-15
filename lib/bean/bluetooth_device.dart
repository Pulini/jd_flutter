class BluetoothDevice {
  BluetoothDevice({
    this.deviceName,
    this.deviceMAC,
    this.deviceIsBonded,
    this.deviceIsConnected,
  });

  BluetoothDevice.fromJson(dynamic json) {
    deviceName = json['DeviceName'];
    deviceMAC = json['DeviceMAC'];
    deviceIsBonded = json['DeviceIsBonded'];
    deviceIsConnected = json['DeviceIsConnected'];
  }

  String? deviceName;
  String? deviceMAC;
  bool? deviceIsBonded;
  bool? deviceIsConnected;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeviceName'] = deviceName;
    map['DeviceMAC'] = deviceMAC;
    map['DeviceIsBonded'] = deviceIsBonded;
    map['DeviceIsConnected'] = deviceIsConnected;
    return map;
  }
}
