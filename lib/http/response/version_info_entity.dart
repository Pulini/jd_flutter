import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/version_info_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class VersionInfoEntity {
	@JSONField(name: "Description")
	String? description = '';
	@JSONField(name: "Force")
	bool? force = false;
	@JSONField(name: "Url")
	String? url = '';
	@JSONField(name: "VersionCode")
	int? versionCode = 0;
	@JSONField(name: "VersionName")
	String? versionName = '';

	VersionInfoEntity();

	factory VersionInfoEntity.fromJson(Map<String, dynamic> json) => $VersionInfoEntityFromJson(json);

	Map<String, dynamic> toJson() => $VersionInfoEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}