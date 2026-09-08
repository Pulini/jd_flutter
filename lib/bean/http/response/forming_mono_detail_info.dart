import 'package:jd_flutter/utils/extension_util.dart';
// FactoryType : "PDS23394160-1"
// Size : "3.5"
// MonoNum : 145
// ReportNum : 72
// TotalNum : 72
// UnderNum : 73

class FormingMonoDetailInfo {
  FormingMonoDetailInfo({
      this.factoryType, 
      this.size, 
      this.monoNum, 
      this.reportNum, 
      this.totalNum, 
      this.underNum,});

  FormingMonoDetailInfo.fromJson(dynamic json) {
    factoryType = JsonParse.str(json['FactoryType']);
    size = JsonParse.str(json['Size']);
    monoNum = JsonParse.toInt(json['MonoNum']);
    reportNum = JsonParse.toInt(json['ReportNum']);
    totalNum = JsonParse.toInt(json['TotalNum']);
    underNum = JsonParse.toInt(json['UnderNum']);
  }
  String? factoryType;
  String? size;
  int? monoNum;
  int? reportNum;
  int? totalNum;
  int? underNum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['MonoNum'] = monoNum;
    map['ReportNum'] = reportNum;
    map['TotalNum'] = totalNum;
    map['UnderNum'] = underNum;
    return map;
  }

}