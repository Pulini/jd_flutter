import 'package:get/get_rx/src/rx_types/rx_types.dart';

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
      this.searchType,
      this.scanQty,
      this.seOrderNo,
      this.status,
      this.colorName,
      this.sizeRange,
      this.organizeName,
      this.currentProcess,
      this.completeDate,});

  OrderProductionExecutionInfo.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    workCardNo = json['WorkCardNo'];
    workCardDate = json['WorkCardDate'];
    fetchDate = json['FetchDate'];
    departmentName = json['DepartmentName'];
    productName = json['ProductName'];
    seOrderNo = json['SeOrderNo'];
    seOrderQty = json['SeOrderQty'];
    scanQty = json['ScanQty'];
    searchType = json['SearchType'];
    status = json['Status'] ?? json['State'];
    colorName = json['ColorName'] ?? json['Color'];
    sizeRange = json['SizeRange'] ?? json['Size'];
    organizeName = json['OrganizeName'] ?? json['FactoryCode'];
    currentProcess = json['CurrentProcess'] ?? json['ProcessName'];
    completeDate = json['CompleteDate'] ?? json['FinishDate'] ?? json['CloseDate'];
  }
  int? workCardInterID;
  double? seOrderQty;
  int? scanQty;
  String? workCardNo;
  String? workCardDate;
  String? fetchDate;
  String? departmentName;
  String? productName;
  String? seOrderNo;
  int? searchType;
  int? status; // 工单状态：0=正单未生产 1=正在生产 2=待清尾 3=已完成
  String? colorName;      // 颜色名称（如"红/白"）
  String? sizeRange;      // 尺码范围（如"35-44"）
  String? organizeName;   // 工厂/组织简称（如"DHM"）
  String? currentProcess; // 当前工序（如"计车"）
  String? completeDate;   // 结案日期

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ScanQty'] = scanQty;
    map['SeOrderQty'] = seOrderQty;
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['WorkCardDate'] = workCardDate;
    map['FetchDate'] = fetchDate;
    map['DepartmentName'] = departmentName;
    map['ProductName'] = productName;
    map['SeOrderNo'] = seOrderNo;
    map['SearchType'] = searchType;
    map['Status'] = status;
    map['ColorName'] = colorName;
    map['SizeRange'] = sizeRange;
    map['OrganizeName'] = organizeName;
    map['CurrentProcess'] = currentProcess;
    map['CompleteDate'] = completeDate;
    return map;
  }

}