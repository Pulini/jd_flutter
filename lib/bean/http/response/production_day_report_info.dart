/// DepName : "裁断1组"
/// Manager : "尹杰文"
/// ToDayMustQty : 600.0
/// ToDayQty : 0.0
/// ToDayFinishRate : "0%"
/// NoToDayQty : 600.0
/// MonthMustQty : 4840.0
/// MonthQty : 0.0
/// MonthFinishRate : "0%"
/// NoMonthQty : 4840.0
/// MustPeopleCount : 13.0
/// PeopleCount : 13.0
/// NoDoingReason : ""
/// DeptID : "554696"
/// Number : "002144"

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
    depName = json['DepName'];
    manager = json['Manager'];
    toDayMustQty = json['ToDayMustQty'];
    toDayQty = json['ToDayQty'];
    toDayFinishRate = json['ToDayFinishRate'];
    noToDayQty = json['NoToDayQty'];
    monthMustQty = json['MonthMustQty'];
    monthQty = json['MonthQty'];
    monthFinishRate = json['MonthFinishRate'];
    noMonthQty = json['NoMonthQty'];
    mustPeopleCount = json['MustPeopleCount'];
    peopleCount = json['PeopleCount'];
    noDoingReason = json['NoDoingReason'];
    deptID = json['DeptID'];
    number = json['Number'];
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