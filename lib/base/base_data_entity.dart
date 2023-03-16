
import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/base_data_entity.g.dart';

@JsonSerializable()
class BaseDataEntity {

	@JSONField(name: "ResultCode")
	late int resultCode;
	@JSONField(name: "Data")
	dynamic data;
	@JSONField(name: "Message")
	late String message;
  
  BaseDataEntity();

  factory BaseDataEntity.fromJson(Map<String, dynamic> json) => $BaseDataEntityFromJson(json);

  Map<String, dynamic> toJson() => $BaseDataEntityToJson(this);

  BaseDataEntity copyWith({int? resultCode, dynamic data, String? message}) {
      return BaseDataEntity()..resultCode= resultCode ?? this.resultCode
			..data= data ?? this.data
			..message= message ?? this.message;
  }
    
  @override
  String toString() {
    return jsonEncode(this);
  }
}