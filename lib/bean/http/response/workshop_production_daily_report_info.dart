// WorkShopName : "裁断车间"
// OrganizeName : "金帝"
// ParentDeptID : "金帝裁断课"
// DeptID : "金帝裁断5组"
// ToDayMustQty : 0.0
// TimeMustQty : 0.0
// TimeQty : 0.0
// NoTimeQty : 0.0
// TimeFinishRate : "0.00%"
// NoDoingReason : ""

class WorkshopProductionDailyReportDetailInfo{
  WorkshopProductionDailyReportDetailInfo({
      this.workShopName, 
      this.organizeName, 
      this.parentDeptID, 
      this.deptID, 
      this.toDayMustQty, 
      this.timeMustQty, 
      this.timeQty, 
      this.noTimeQty, 
      this.timeFinishRate, 
      this.noDoingReason,});

  WorkshopProductionDailyReportDetailInfo.fromJson(dynamic json) {
    workShopName = json['WorkShopName'];
    organizeName = json['OrganizeName'];
    parentDeptID = json['ParentDeptID'];
    deptID = json['DeptID'];
    toDayMustQty = json['ToDayMustQty'];
    timeMustQty = json['TimeMustQty'];
    timeQty = json['TimeQty'];
    noTimeQty = json['NoTimeQty'];
    timeFinishRate = json['TimeFinishRate'];
    noDoingReason = json['NoDoingReason'];
  }
  String? workShopName;
  String? organizeName;
  String? parentDeptID;
  String? deptID;
  double? toDayMustQty;
  double? timeMustQty;
  double? timeQty;
  double? noTimeQty;
  String? timeFinishRate;
  String? noDoingReason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkShopName'] = workShopName;
    map['OrganizeName'] = organizeName;
    map['ParentDeptID'] = parentDeptID;
    map['DeptID'] = deptID;
    map['ToDayMustQty'] = toDayMustQty;
    map['TimeMustQty'] = timeMustQty;
    map['TimeQty'] = timeQty;
    map['NoTimeQty'] = noTimeQty;
    map['TimeFinishRate'] = timeFinishRate;
    map['NoDoingReason'] = noDoingReason;
    return map;
  }

}
// WorkShopName : "贴合车间"
// OrganizeName : "Gold Emperor(Myanmar)Company Limited"
// ToDayMustQty : 0.0
// ToDayQty : 0.0
// NoToDayQty : 0.0
// ToDayFinishRate : "0.00%"
// LJQty : 0.0
// NoDoingReason : ""

class WorkshopProductionDailyReportSummaryInfo  {
  WorkshopProductionDailyReportSummaryInfo({
    this.workShopName,
    this.organizeName,
    this.toDayMustQty,
    this.toDayQty,
    this.noToDayQty,
    this.toDayFinishRate,
    this.lJQty,
    this.noDoingReason,});

  WorkshopProductionDailyReportSummaryInfo.fromJson(dynamic json) {
    workShopName = json['WorkShopName'];
    organizeName = json['OrganizeName'];
    toDayMustQty = json['ToDayMustQty'];
    toDayQty = json['ToDayQty'];
    noToDayQty = json['NoToDayQty'];
    toDayFinishRate = json['ToDayFinishRate'];
    lJQty = json['LJQty'];
    noDoingReason = json['NoDoingReason'];
  }
  String? workShopName;
  String? organizeName;
  double? toDayMustQty;
  double? toDayQty;
  double? noToDayQty;
  String? toDayFinishRate;
  double? lJQty;
  String? noDoingReason;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkShopName'] = workShopName;
    map['OrganizeName'] = organizeName;
    map['ToDayMustQty'] = toDayMustQty;
    map['ToDayQty'] = toDayQty;
    map['NoToDayQty'] = noToDayQty;
    map['ToDayFinishRate'] = toDayFinishRate;
    map['LJQty'] = lJQty;
    map['NoDoingReason'] = noDoingReason;
    return map;
  }

}