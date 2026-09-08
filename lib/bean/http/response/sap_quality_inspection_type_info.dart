import 'package:jd_flutter/utils/extension_util.dart';
class SapQualityInspectionTypeInfo {
  String? number; //编号
  String? name; //名称


  SapQualityInspectionTypeInfo({
    this.number,
    this.name,

  });

  SapQualityInspectionTypeInfo.fromJson(dynamic json) {
    number = JsonParse.str(json['DOMVALUE_L']);
    name = JsonParse.str(json['DDTEXT']);

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['DOMVALUE_L'] = number;
    map['DDTEXT'] = name;

    return map;
  }
}

