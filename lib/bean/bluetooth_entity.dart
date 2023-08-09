import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/bluetooth_entity.g.dart';

@JsonSerializable()
class BluetoothEntity {
	@JSONField(name: "DeviceName")
	late String deviceName;
	@JSONField(name: "DeviceMAC")
	late String deviceMAC;
	@JSONField(name: "DeviceIsBonded")
	late bool deviceIsBonded;
	@JSONField(name: "DeviceIsConnected")
	late bool deviceIsConnected;

	BluetoothEntity();


	factory BluetoothEntity.fromJson(Map<String, dynamic> json) => $BluetoothEntityFromJson(json);

	Map<String, dynamic> toJson() => $BluetoothEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}