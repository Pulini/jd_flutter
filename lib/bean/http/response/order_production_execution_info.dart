/// WorkCardInterID : 1231836
/// WorkCardNo : "P26124283"
/// WorkCardDate : "2026-06-24"
/// FetchDate : "2026-06-23"
/// DepartmentName : "IDN_LastingLine_01"
/// ProductName : "PNW25402632-02"
/// SeOrderNo : "L2605324"
class OrderProductionExecutionInfo {
  OrderProductionExecutionInfo({
      this.workCardInterID,
      this.workCardNo,
      this.workCardDate,
      this.fetchDate,
      this.departmentName,
      this.seOrderQty,
      this.productName,
      this.scanQty,
      this.seOrderNo,
      this.status,
      this.color,
      this.sizeRange,
      this.band,
      this.unFinishQty,
      this.planEndDate,
      this.daysDifference,
      this.lastDate,
      this.isTailConfirm,
      this.moID,
      this.isNeedInnerBoxLabel,  //true不需要扫码，false扫码

  });

  OrderProductionExecutionInfo.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    isTailConfirm = json['IsTailConfirm'];
    unFinishQty = json['UnFinishQty'];
    workCardNo = json['WorkCardNo'];
    workCardDate = json['WorkCardDate'];
    fetchDate = json['FetchDate'];
    departmentName = json['DepartmentName'];
    productName = json['ProductName'];
    seOrderNo = json['SeOrderNo'];
    seOrderQty = json['SeOrderQty'];
    scanQty = json['ScanQty'];
    color = json['Color'];
    status = json['Status'];
    sizeRange = json['SizeRange'];
    band = json['Band'];
    planEndDate = json['PlanEndDate'];
    daysDifference = json['DaysDifference'];
    lastDate = json['LastDate'];
    moID = json['MoID'];
    isNeedInnerBoxLabel = json['IsNeedInnerBoxLabel'];
  }
  int? workCardInterID;
  double? seOrderQty; //订单数量
  double? unFinishQty;
  int? scanQty;  //完工数量
  int? daysDifference;
  String? workCardNo;
  String? workCardDate;
  String? fetchDate;
  String? departmentName;
  String? productName;
  String? seOrderNo;
  int? isTailConfirm;
  int? status; // 工单状态：1=正单未生产 2=正在生产 3=待清尾 4=已完成
  String? color;      // 颜色名称（如"红/白"）
  String? sizeRange;      // 尺码范围（如"35-44"）
  String? band;   // 工厂/组织简称（如"DHM"）
  String? planEndDate;
  String? lastDate;
  int? moID;
  bool? isNeedInnerBoxLabel;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ScanQty'] = scanQty;
    map['UnFinishQty'] = unFinishQty;
    map['PlanEndDate'] = planEndDate;
    map['DaysDifference'] = daysDifference;
    map['SeOrderQty'] = seOrderQty;
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['WorkCardDate'] = workCardDate;
    map['FetchDate'] = fetchDate;
    map['DepartmentName'] = departmentName;
    map['ProductName'] = productName;
    map['SeOrderNo'] = seOrderNo;
    map['Status'] = status;
    map['Color'] = color;
    map['SizeRange'] = sizeRange;
    map['Band'] = band;
    map['LastDate'] = lastDate;
    map['IsTailConfirm'] = isTailConfirm;
    map['MoID'] = moID;
    map['IsNeedInnerBoxLabel'] = isNeedInnerBoxLabel;
    return map;
  }

}