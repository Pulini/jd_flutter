import 'package:jd_flutter/generated/json/base/json_convert_content.dart';
import 'package:jd_flutter/http/response/version_info_entity.dart';

VersionInfoEntity $VersionInfoEntityFromJson(Map<String, dynamic> json) {
	final VersionInfoEntity versionInfoEntity = VersionInfoEntity();
	final String? description = jsonConvert.convert<String>(json['Description']);
	if (description != null) {
		versionInfoEntity.description = description;
	}
	final bool? force = jsonConvert.convert<bool>(json['Force']);
	if (force != null) {
		versionInfoEntity.force = force;
	}
	final String? url = jsonConvert.convert<String>(json['Url']);
	if (url != null) {
		versionInfoEntity.url = url;
	}
	final int? versionCode = jsonConvert.convert<int>(json['VersionCode']);
	if (versionCode != null) {
		versionInfoEntity.versionCode = versionCode;
	}
	final String? versionName = jsonConvert.convert<String>(json['VersionName']);
	if (versionName != null) {
		versionInfoEntity.versionName = versionName;
	}
	return versionInfoEntity;
}

Map<String, dynamic> $VersionInfoEntityToJson(VersionInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Description'] = entity.description;
	data['Force'] = entity.force;
	data['Url'] = entity.url;
	data['VersionCode'] = entity.versionCode;
	data['VersionName'] = entity.versionName;
	return data;
}