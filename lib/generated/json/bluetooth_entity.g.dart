import 'package:jd_flutter/generated/json/base/json_convert_content.dart';
import 'package:jd_flutter/bean/bluetooth_entity.dart';

BluetoothEntity $BluetoothEntityFromJson(Map<String, dynamic> json) {
	final BluetoothEntity bluetoothEntity = BluetoothEntity();
	final String? deviceName = jsonConvert.convert<String>(json['DeviceName']);
	if (deviceName != null) {
		bluetoothEntity.deviceName = deviceName;
	}
	final String? deviceMAC = jsonConvert.convert<String>(json['DeviceMAC']);
	if (deviceMAC != null) {
		bluetoothEntity.deviceMAC = deviceMAC;
	}
	final bool? deviceIsBonded = jsonConvert.convert<bool>(json['DeviceIsBonded']);
	if (deviceIsBonded != null) {
		bluetoothEntity.deviceIsBonded = deviceIsBonded;
	}
	final bool? deviceIsConnected = jsonConvert.convert<bool>(json['DeviceIsConnected']);
	if (deviceIsConnected != null) {
		bluetoothEntity.deviceIsConnected = deviceIsConnected;
	}
	return bluetoothEntity;
}

Map<String, dynamic> $BluetoothEntityToJson(BluetoothEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['DeviceName'] = entity.deviceName;
	data['DeviceMAC'] = entity.deviceMAC;
	data['DeviceIsBonded'] = entity.deviceIsBonded;
	data['DeviceIsConnected'] = entity.deviceIsConnected;
	return data;
}