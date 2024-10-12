
class BluetoothDevice {
  BluetoothDevice({
    required this.deviceName,
    required this.deviceMAC,
    required this.deviceIsBonded,
    required this.deviceIsConnected,
  });

  BluetoothDevice.fromJson(dynamic json) {
    deviceName = json['DeviceName'];
    deviceMAC = json['DeviceMAC'];
    deviceIsBonded = json['DeviceBondState'];
    deviceIsConnected = json['DeviceIsConnected'];
  }

  var deviceName = '';
  var deviceMAC = '';
  var deviceIsBonded = false;
  var deviceIsConnected = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeviceName'] = deviceName;
    map['DeviceMAC'] = deviceMAC;
    map['DeviceBondState'] = deviceIsBonded;
    map['DeviceIsConnected'] = deviceIsConnected;
    return map;
  }
}
