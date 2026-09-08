import 'package:jd_flutter/utils/extension_util.dart';
// DepName : "裁断1组"
// Manager : "尹杰文"
// ToDayMustQty : 600.0
// ToDayQty : 0.0
// ToDayFinishRate : "0%"
// NoToDayQty : 600.0
// MonthMustQty : 4840.0
// MonthQty : 0.0
// MonthFinishRate : "0%"
// NoMonthQty : 4840.0
// MustPeopleCount : 13.0
// PeopleCount : 13.0
// NoDoingReason : ""
// DeptID : "554696"
// Number : "002144"

class ProductionDayReportInfo {
  ProductionDayReportInfo({
      this.depName, 
      this.manager, 
      this.toDayMustQty, 
      this.toDayQty, 
      this.toDayFinishRate, 
      this.noToDayQty, 
      this.monthMustQty, 
      this.monthQty, 
      this.monthFinishRate, 
      this.noMonthQty, 
      this.mustPeopleCount, 
      this.peopleCount, 
      this.noDoingReason, 
      this.deptID, 
      this.number,});

  ProductionDayReportInfo.fromJson(dynamic json) {
    depName = JsonParse.str(json['DepName']);
    manager = JsonParse.str(json['Manager']);
    toDayMustQty = JsonParse.toDouble(json['ToDayMustQty']);
    toDayQty = JsonParse.toDouble(json['ToDayQty']);
    toDayFinishRate = JsonParse.str(json['ToDayFinishRate']);
    noToDayQty = JsonParse.toDouble(json['NoToDayQty']);
    monthMustQty = JsonParse.toDouble(json['MonthMustQty']);
    monthQty = JsonParse.toDouble(json['MonthQty']);
    monthFinishRate = JsonParse.str(json['MonthFinishRate']);
    noMonthQty = JsonParse.toDouble(json['NoMonthQty']);
    mustPeopleCount = JsonParse.toDouble(json['MustPeopleCount']);
    peopleCount = JsonParse.toDouble(json['PeopleCount']);
    noDoingReason = JsonParse.str(json['NoDoingReason']);
    deptID = JsonParse.str(json['DeptID']);
    number = JsonParse.str(json['Number']);
  }
  String? depName;
  String? manager;
  double? toDayMustQty;
  double? toDayQty;
  String? toDayFinishRate;
  double? noToDayQty;
  double? monthMustQty;
  double? monthQty;
  String? monthFinishRate;
  double? noMonthQty;
  double? mustPeopleCount;
  double? peopleCount;
  String? noDoingReason;
  String? deptID;
  String? number;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DepName'] = depName;
    map['Manager'] = manager;
    map['ToDayMustQty'] = toDayMustQty;
    map['ToDayQty'] = toDayQty;
    map['ToDayFinishRate'] = toDayFinishRate;
    map['NoToDayQty'] = noToDayQty;
    map['MonthMustQty'] = monthMustQty;
    map['MonthQty'] = monthQty;
    map['MonthFinishRate'] = monthFinishRate;
    map['NoMonthQty'] = noMonthQty;
    map['MustPeopleCount'] = mustPeopleCount;
    map['PeopleCount'] = peopleCount;
    map['NoDoingReason'] = noDoingReason;
    map['DeptID'] = deptID;
    map['Number'] = number;
    return map;
  }

}