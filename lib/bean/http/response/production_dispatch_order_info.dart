import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// InterID : 213015
// State : "已派工,已审核,未关闭,未汇报,未记工,未结案"
// BillType : "正单"
// PlanBill : "ZJ2300000031"
// OrderBill : "P2048550"
// SAPOrderBill : "000000000838"
// OrderDate : "2023-03-02"
// Group : "金臻_沿条课"
// PlanStartTime : "2023-03-02"
// PlanEndTime : "2023-03-02"
// PlantBody : ""
// MaterialCode : "061600005"
// MaterialName : "沿条拌料半成品-D13677-22B M"
// Unit : "米"
// BillerID : 5259
// Biller : "张幸民"
// Checker : "张幸民"
// BillDate : "2023-03-02 11:44:40"
// CheckDate : "2023-03-02 11:44:40"
// EntryID : 2
// ProcessFlowID : 63
// CanReportByNoStockIn : 0
// WorkNumberTotal : 3384
// RouteBillNumber : "GYLX2000017014"
// ReportedNumber : 0
// ReportedUnscheduled : 0
// ReportedUnentered : 0
// StockInQty : 0
// RoutingID : "162132"
// Size : []
// IsClosed : false
// PrintStatus : "3"
// StubBar1 : "460500011"
// StubBar2 : ""
// StubBar3 : ""
// StubBarName1 : "沿条料头测试1"
// StubBarName2 : ""
// StubBarName3 : ""
// Factory : "1500"
// Machine : ""
// PastDay : false

class ProductionDispatchOrderInfo {
  ProductionDispatchOrderInfo({
    this.interID,
    this.state,
    this.billType,
    this.planBill,
    this.orderBill,
    this.sapOrderBill,
    this.orderDate,
    this.group,
    this.planStartTime,
    this.planEndTime,
    this.plantBody,
    this.materialCode,
    this.materialName,
    this.unit,
    this.billerID,
    this.biller,
    this.checker,
    this.billDate,
    this.checkDate,
    this.entryID,
    this.processFlowID,
    this.sapProcessName,
    this.canReportByNoStockIn,
    this.workNumberTotal,
    this.routeBillNumber,
    this.reportedNumber,
    this.reportedUnscheduled,
    this.reportedUnentered,
    this.stockInQty,
    this.routingID,
    this.size,
    this.isClosed,
    this.printStatus,
    this.stubBar1,
    this.stubBar2,
    this.stubBar3,
    this.stubBarName1,
    this.stubBarName2,
    this.stubBarName3,
    this.factory,
    this.machine,
    this.shift,
    this.pastDay,
    this.exitLabelType,
  });

  ProductionDispatchOrderInfo.fromJson(dynamic json) {
    interID = JsonParse.toInt(json['InterID']);
    state = JsonParse.str(json['State']);
    billType = JsonParse.str(json['BillType']);
    planBill = JsonParse.str(json['PlanBill']);
    orderBill = JsonParse.str(json['OrderBill']);
    sapOrderBill = JsonParse.str(json['SAPOrderBill']);
    orderDate = JsonParse.str(json['OrderDate']);
    group = JsonParse.str(json['Group']);
    planStartTime = JsonParse.str(json['PlanStartTime']);
    planEndTime = JsonParse.str(json['PlanEndTime']);
    plantBody = JsonParse.str(json['PlantBody']);
    materialCode = JsonParse.str(json['MaterialCode']);
    materialName = JsonParse.str(json['MaterialName']);
    unit = JsonParse.str(json['Unit']);
    billerID = JsonParse.toInt(json['BillerID']);
    biller = JsonParse.str(json['Biller']);
    checker = JsonParse.str(json['Checker']);
    billDate = JsonParse.str(json['BillDate']);
    checkDate = JsonParse.str(json['CheckDate']);
    entryID = JsonParse.toInt(json['EntryID']);
    processFlowID = JsonParse.toInt(json['ProcessFlowID']);
    sapProcessName = JsonParse.str(json['SAPProcessName']);
    canReportByNoStockIn = JsonParse.toInt(json['CanReportByNoStockIn']);
    workNumberTotal = JsonParse.toDouble(json['WorkNumberTotal']);
    routeBillNumber = JsonParse.str(json['RouteBillNumber']);
    reportedNumber = JsonParse.toDouble(json['ReportedNumber']);
    reportedUnscheduled = JsonParse.toDouble(json['ReportedUnscheduled']);
    reportedUnentered = JsonParse.toDouble(json['ReportedUnentered']);
    stockInQty = JsonParse.toDouble(json['StockInQty']);
    routingID = JsonParse.str(json['RoutingID']);
    size = JsonParse.list(json['Size'], SizeBean.fromJson);
    isClosed = JsonParse.toBool(json['IsClosed']);
    printStatus = JsonParse.str(json['PrintStatus']);
    stubBar1 = JsonParse.str(json['StubBar1']);
    stubBar2 = JsonParse.str(json['StubBar2']);
    stubBar3 = JsonParse.str(json['StubBar3']);
    stubBarName1 = JsonParse.str(json['StubBarName1']);
    stubBarName2 = JsonParse.str(json['StubBarName2']);
    stubBarName3 = JsonParse.str(json['StubBarName3']);
    factory = JsonParse.str(json['Factory']);
    machine = JsonParse.str(json['Machine']);
    shift = JsonParse.str(json['Shift']);
    pastDay = JsonParse.toBool(json['PastDay']);
    exitLabelType = JsonParse.toInt(json['ExitLabelType']);
  }

  RxBool select = false.obs;

  int? interID;
  String? state;
  String? billType;
  String? planBill;
  String? orderBill;
  String? sapOrderBill;
  String? orderDate;
  String? group;
  String? planStartTime;
  String? planEndTime;
  String? plantBody;
  String? materialCode;
  String? materialName;
  String? unit;
  int? billerID;
  String? biller;
  String? checker;
  String? billDate;
  String? checkDate;
  int? entryID;
  int? processFlowID;
  String? sapProcessName;
  int? canReportByNoStockIn;
  double? workNumberTotal;
  String? routeBillNumber;
  double? reportedNumber;
  double? reportedUnscheduled;
  double? reportedUnentered;
  double? stockInQty;
  String? routingID;
  List<SizeBean>? size;
  bool? isClosed;
  String? printStatus;
  String? stubBar1;
  String? stubBar2;
  String? stubBar3;
  String? stubBarName1;
  String? stubBarName2;
  String? stubBarName3;
  String? factory;
  String? machine;
  String? shift;
  bool? pastDay;
  int? exitLabelType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['State'] = state;
    map['BillType'] = billType;
    map['PlanBill'] = planBill;
    map['OrderBill'] = orderBill;
    map['SAPOrderBill'] = sapOrderBill;
    map['OrderDate'] = orderDate;
    map['Group'] = group;
    map['PlanStartTime'] = planStartTime;
    map['PlanEndTime'] = planEndTime;
    map['PlantBody'] = plantBody;
    map['MaterialCode'] = materialCode;
    map['MaterialName'] = materialName;
    map['Unit'] = unit;
    map['BillerID'] = billerID;
    map['Biller'] = biller;
    map['Checker'] = checker;
    map['BillDate'] = billDate;
    map['CheckDate'] = checkDate;
    map['EntryID'] = entryID;
    map['ProcessFlowID'] = processFlowID;
    map['SAPProcessName'] = sapProcessName;
    map['CanReportByNoStockIn'] = canReportByNoStockIn;
    map['WorkNumberTotal'] = workNumberTotal;
    map['RouteBillNumber'] = routeBillNumber;
    map['ReportedNumber'] = reportedNumber;
    map['ReportedUnscheduled'] = reportedUnscheduled;
    map['ReportedUnentered'] = reportedUnentered;
    map['StockInQty'] = stockInQty;
    map['RoutingID'] = routingID;
    if (size != null) {
      map['Size'] = size?.map((v) => v.toJson()).toList();
    }
    map['IsClosed'] = isClosed;
    map['PrintStatus'] = printStatus;
    map['StubBar1'] = stubBar1;
    map['StubBar2'] = stubBar2;
    map['StubBar3'] = stubBar3;
    map['StubBarName1'] = stubBarName1;
    map['StubBarName2'] = stubBarName2;
    map['StubBarName3'] = stubBarName3;
    map['Factory'] = factory;
    map['Machine'] = machine;
    map['Shift'] = shift;
    map['PastDay'] = pastDay;
    map['ExitLabelType'] = exitLabelType;
    return map;
  }

  String getSizeText() => 'production_dispatch_size'.trArgs([
        size?.map((v) => ' <${v.size}/${v.num.toShowString()}>').reduce((a, b) => a + b) ?? ''
  ]);

  String getProgress() {
    return '${stockInQty.toShowString()}/${workNumberTotal.toShowString()}';
  }
}

class SizeBean {
  SizeBean({
    this.num,
    this.size,
  });

  SizeBean.fromJson(dynamic json) {
    num = JsonParse.toDouble(json['Num']);
    size = JsonParse.str(json['Size']);
  }

  double? num;
  String? size;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Num'] = num;
    map['Size'] = size;
    return map;
  }
}

class OrderProgressInfo {
  String? materialCode; //物料编码
  String? materialName; //物料名称
  String? factoryType; //型体
  String? factory; //工厂
  int? preCompensation; //预补类型
  List<OrderProgressItemInfo>? mtoNoItems;

  OrderProgressInfo({
    this.materialCode,
    this.materialName,
    this.factoryType,
    this.factory,
    this.preCompensation,
    this.mtoNoItems,
  });

  OrderProgressInfo.fromJson(dynamic json) {
    materialCode = JsonParse.str(json['MaterialCode']);
    materialName = JsonParse.str(json['MaterialName']);
    factoryType = JsonParse.str(json['FactoryType']);
    factory = JsonParse.str(json['Factory']);
    preCompensation = JsonParse.toInt(json['PreCompensation']);
    mtoNoItems = JsonParse.list(json['MtoNoItems'], OrderProgressItemInfo.fromJson);
  }

  List<String> getMaxSizeList() {
    var list = <String>[];
    mtoNoItems?.forEach((item) {
      item.sizeItems?.forEach((sizeData) {
        if (!list.contains(sizeData.size)) list.add(sizeData.size ?? '');
      });
    });
    list.sorted();
    return list;
  }
}

class OrderProgressItemInfo {
  String? mtoNo; //指令
  String? unit; //单位
  double? qty; //数量
  double? inStockQty; //入库数量
  double? reportedQty; //已汇报数量
  int? priority; //优先级
  List<OrderProgressItemSizeInfo>? sizeItems;

  OrderProgressItemInfo({
    this.mtoNo,
    this.unit,
    this.qty,
    this.inStockQty,
    this.reportedQty,
    this.priority,
    this.sizeItems,
  });

  OrderProgressItemInfo.fromJson(dynamic json) {
    mtoNo = JsonParse.str(json['MtoNo']);
    unit = JsonParse.str(json['Unit']);
    qty = JsonParse.toDouble(json['Qty']);
    inStockQty = JsonParse.toDouble(json['InStockQty']);
    reportedQty = JsonParse.toDouble(json['ReportedQty']);
    priority = JsonParse.toInt(json['Priority']);
    sizeItems = JsonParse.list(json['SizeItems'], OrderProgressItemSizeInfo.fromJson);
  }
}

class OrderProgressItemSizeInfo {
  String? size; //尺码
  double? qty; //派工数量

  OrderProgressItemSizeInfo({
    this.size,
    this.qty,
  });

  OrderProgressItemSizeInfo.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
  }
}

class OrderProgressShowInfo {
  int itemType = 0; //1、物料 2、体 3、合计 4、预补
  int sizeMax = 0; //尺码最大列数
  bool preCompensation = false; //是否显示预补

  String material = ''; //物料
  String factoryType = ''; //型体
  String factory = ''; //工厂

  String mtoNo = ''; //指令
  String unit = ''; //单位
  String qty = ''; //数量
  String inStockQty = ''; //入库数量
  String reportedQty = ''; //已汇报数量
  String priority = ''; //优先级

  List<String> sizeData = []; //尺码数据
}
