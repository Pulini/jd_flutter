import 'package:jd_flutter/utils/extension_util.dart';
// exNumber : 'SCPZYCD200000094'
// billDate : '2020/7/7 16:38:00'
// empID : 139697
// qty : '22'
// exceptionID : 16
// exceptionName : '鞋面组合歪斜、移位'
// exceptionLevel : '轻微'
// reCheck : '复检合格'

class Entry {
  Entry({
      this.exNumber, 
      this.billDate, 
      this.empID, 
      this.qty, 
      this.exceptionID, 
      this.exceptionName, 
      this.exceptionLevel, 
      this.reCheck,});

  Entry.fromJson(dynamic json) {
    exNumber = JsonParse.str(json['exNumber']);
    billDate = JsonParse.str(json['billDate']);
    empID = JsonParse.toInt(json['empID']);
    qty = JsonParse.str(json['qty']);
    exceptionID = JsonParse.toInt(json['exceptionID']);
    exceptionName = JsonParse.str(json['exceptionName']);
    exceptionLevel = JsonParse.str(json['exceptionLevel']);
    reCheck = JsonParse.str(json['reCheck']);
  }
  String? exNumber;
  String? billDate;
  int? empID;
  String? qty;
  int? exceptionID;
  String? exceptionName;
  String? exceptionLevel;
  String? reCheck;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exNumber'] = exNumber;
    map['billDate'] = billDate;
    map['empID'] = empID;
    map['qty'] = qty;
    map['exceptionID'] = exceptionID;
    map['exceptionName'] = exceptionName;
    map['exceptionLevel'] = exceptionLevel;
    map['reCheck'] = reCheck;
    return map;
  }

}