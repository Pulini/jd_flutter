import 'package:jd_flutter/utils/extension_util.dart';
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
      this.unit,

  });

  OrderProductionExecutionInfo.fromJson(dynamic json) {
    workCardInterID = JsonParse.toInt(json['WorkCardInterID']);
    isTailConfirm = JsonParse.toInt(json['IsTailConfirm']);
    unFinishQty = JsonParse.toDouble(json['UnFinishQty']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    workCardDate = JsonParse.str(json['WorkCardDate']);
    fetchDate = JsonParse.str(json['FetchDate']);
    departmentName = JsonParse.str(json['DepartmentName']);
    productName = JsonParse.str(json['ProductName']);
    seOrderNo = JsonParse.str(json['SeOrderNo']);
    seOrderQty = JsonParse.toDouble(json['SeOrderQty']);
    scanQty = JsonParse.toInt(json['ScanQty']);
    color = JsonParse.str(json['Color']);
    status = JsonParse.toInt(json['Status']);
    sizeRange = JsonParse.str(json['SizeRange']);
    band = JsonParse.str(json['Band']);
    planEndDate = JsonParse.str(json['PlanEndDate']);
    daysDifference = JsonParse.toInt(json['DaysDifference']);
    lastDate = JsonParse.str(json['LastDate']);
    moID = JsonParse.toInt(json['MoID']);
    isNeedInnerBoxLabel = JsonParse.toBool(json['IsNeedInnerBoxLabel']);
    unit = JsonParse.str(json['Unit']);
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
  String? unit;   // 单位（如"双"）
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
    map['Unit'] = unit;
    map['LastDate'] = lastDate;
    map['IsTailConfirm'] = isTailConfirm;
    map['MoID'] = moID;
    map['IsNeedInnerBoxLabel'] = isNeedInnerBoxLabel;
    return map;
  }

}