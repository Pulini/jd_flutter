

import 'package:jd_flutter/base/base_data_entity.dart';

import 'base/json_convert_content.dart';

BaseDataEntity $BaseDataEntityFromJson(Map<String, dynamic> json) {
	final BaseDataEntity baseDataEntity = BaseDataEntity();
	final int? resultCode = jsonConvert.convert<int>(json['ResultCode']);
	if (resultCode != null) {
		baseDataEntity.resultCode = resultCode;
	}
	final dynamic data = jsonConvert.convert<dynamic>(json['Data']);
	if (data != null) {
		baseDataEntity.data = data;
	}
	final String? message = jsonConvert.convert<String>(json['Message']);
	if (message != null) {
		baseDataEntity.message = message;
	}
	return baseDataEntity;
}

Map<String, dynamic> $BaseDataEntityToJson(BaseDataEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['ResultCode'] = entity.resultCode;
	data['Data'] = entity.data;
	data['Message'] = entity.message;
	return data;
}