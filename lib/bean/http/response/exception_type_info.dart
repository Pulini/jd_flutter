import 'package:jd_flutter/utils/extension_util.dart';
// FItemID : 11
// FParentID : 3
// FName : "材料不良"
// FDetail : true
// FExPercentage : 0

class ExceptionTypeInfo {
  ExceptionTypeInfo({
      this.fItemID, 
      this.fParentID, 
      this.fName, 
      this.fDetail, 
      this.fExPercentage,});

  ExceptionTypeInfo.fromJson(dynamic json) {
    fItemID = JsonParse.toInt(json['FItemID']);
    fParentID = JsonParse.toInt(json['FParentID']);
    fName = JsonParse.str(json['FName']);
    fDetail = JsonParse.toBool(json['FDetail']);
    fExPercentage = JsonParse.toDouble(json['FExPercentage']);
  }
  int? fItemID;
  int? fParentID;
  String? fName;
  bool? fDetail;
  double? fExPercentage;
  bool select = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FItemID'] = fItemID;
    map['FParentID'] = fParentID;
    map['FName'] = fName;
    map['FDetail'] = fDetail;
    map['FExPercentage'] = fExPercentage;
    return map;
  }

}