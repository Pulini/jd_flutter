import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

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
    this.pastDay,
  });

  ProductionDispatchOrderInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    state = json['State'];
    billType = json['BillType'];
    planBill = json['PlanBill'];
    orderBill = json['OrderBill'];
    sapOrderBill = json['SAPOrderBill'];
    orderDate = json['OrderDate'];
    group = json['Group'];
    planStartTime = json['PlanStartTime'];
    planEndTime = json['PlanEndTime'];
    plantBody = json['PlantBody'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
    unit = json['Unit'];
    billerID = json['BillerID'];
    biller = json['Biller'];
    checker = json['Checker'];
    billDate = json['BillDate'];
    checkDate = json['CheckDate'];
    entryID = json['EntryID'];
    processFlowID = json['ProcessFlowID'];
    canReportByNoStockIn = json['CanReportByNoStockIn'];
    workNumberTotal = json['WorkNumberTotal'];
    routeBillNumber = json['RouteBillNumber'];
    reportedNumber = json['ReportedNumber'];
    reportedUnscheduled = json['ReportedUnscheduled'];
    reportedUnentered = json['ReportedUnentered'];
    stockInQty = json['StockInQty'];
    routingID = json['RoutingID'];
    if (json['Size'] != null) {
      size = [];
      json['Size'].forEach((v) {
        size?.add(SizeBean.fromJson(v));
      });
    }
    isClosed = json['IsClosed'];
    printStatus = json['PrintStatus'];
    stubBar1 = json['StubBar1'];
    stubBar2 = json['StubBar2'];
    stubBar3 = json['StubBar3'];
    stubBarName1 = json['StubBarName1'];
    stubBarName2 = json['StubBarName2'];
    stubBarName3 = json['StubBarName3'];
    factory = json['Factory'];
    machine = json['Machine'];
    pastDay = json['PastDay'];
  }

  bool select = false;

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
  bool? pastDay;

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
    map['PastDay'] = pastDay;
    return map;
  }

  String getSizeText() {
    var text = '';
    for (var value in size!) {
      text = '$text  <${value.size}/${value.num}>';
    }
    return 'production_dispatch_size'.trArgs([text]);
  }

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
    num = json['Num'];
    size = json['Size'];
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
