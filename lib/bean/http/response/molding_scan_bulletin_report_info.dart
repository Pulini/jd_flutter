import 'package:decimal/decimal.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// DeptID : "554744"
// WorkCardInterID : "213249"
// WorkCardNo : "P2048786"
// MapNumber : "1202300007"
// ClientOrderNumber : "20230304001"
// MoID : "155919"
// MtoNo : "JZ2300007"
// ProductName : "D13677-22B M"
// Color : ""
// PriorityLevel : "3"
// EntryFID : "555868"
// ScWorkCardSizeInfos : [{"Size":"38","Qty":100.0000000000,"ScannedQty":0.0},{"Size":"39","Qty":100.0000000000,"ScannedQty":0.0},{"Size":"40","Qty":100.0000000000,"ScannedQty":0.0}]
// SizeRelations : [{"Size":"38","BarCode":"12023000070119"},{"Size":"39","BarCode":"12023000070121"},{"Size":"40","BarCode":"12023000070123"}]

class MoldingScanBulletinReportInfo {
  MoldingScanBulletinReportInfo({
    this.deptID,
    this.workCardInterID,
    this.workCardNo,
    this.mapNumber,
    this.clientOrderNumber,
    this.moID,
    this.mtoNo,
    this.productName,
    this.color,
    this.priorityLevel,
    this.entryFID,
    this.sizeInfo,
    this.sizeRelations,
  });

  MoldingScanBulletinReportInfo.fromJson(dynamic json) {
    deptID = JsonParse.str(json['DeptID']);
    workCardInterID = JsonParse.str(json['WorkCardInterID']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    mapNumber = JsonParse.str(json['MapNumber']);
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    moID = JsonParse.str(json['MoID']);
    mtoNo = JsonParse.str(json['MtoNo']);
    productName = JsonParse.str(json['ProductName']);
    color = JsonParse.str(json['Color']);
    priorityLevel = JsonParse.str(json['PriorityLevel']);
    entryFID = JsonParse.str(json['EntryFID']);
    if (json['ScWorkCardSizeInfos'] != null) {
      sizeInfo = [];
      json['ScWorkCardSizeInfos'].forEach((v) {
        sizeInfo?.add(ScWorkCardSizeInfos.fromJson(v));
      });
      if (sizeInfo!.isNotEmpty) {
        double totalQty = 0;
        double totalTodayReportQty = 0;
        double totalScannedQty = 0;
        sizeInfo?.forEach((e) {
          totalQty += e.qty ?? 0;
          totalTodayReportQty += e.todayReportQty ?? 0;
          totalScannedQty += e.scannedQty ?? 0;
        });
        sizeInfo?.add(ScWorkCardSizeInfos(
          size: 'molding_scan_bulletin_report_table_hint7'.tr,
          qty: totalQty,
          todayReportQty: totalTodayReportQty,
          scannedQty: totalScannedQty,
        ));
      }
    }
    sizeRelations = JsonParse.list(json['SizeRelations'], SizeRelations.fromJson);
  }

  String? deptID; //部门ID
  String? workCardInterID; //生产派工单ID
  String? workCardNo; //生产派工单号
  String? mapNumber; //客户货号
  String? clientOrderNumber; //客户订单号
  String? moID; //指令ID
  String? mtoNo; //指令号
  String? productName; //型体名称
  String? color; //型体颜色
  String? priorityLevel; //派工单优先级
  String? entryFID; //
  List<ScWorkCardSizeInfos>? sizeInfo;
  List<SizeRelations>? sizeRelations;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptID'] = deptID;
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['MapNumber'] = mapNumber;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['MoID'] = moID;
    map['MtoNo'] = mtoNo;
    map['ProductName'] = productName;
    map['Color'] = color;
    map['PriorityLevel'] = priorityLevel;
    map['EntryFID'] = entryFID;
    if (sizeInfo != null) {
      map['ScWorkCardSizeInfos'] = sizeInfo?.map((v) => v.toJson()).toList();
    }
    if (sizeRelations != null) {
      map['SizeRelations'] = sizeRelations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// Size : "38"
// BarCode : "12023000070119"

class SizeRelations {
  SizeRelations({
    this.size,
    this.barCode,
  });

  SizeRelations.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    barCode = JsonParse.str(json['BarCode']);
  }

  String? size; //尺码
  String? barCode; //鞋盒条条码

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['BarCode'] = barCode;
    return map;
  }
}

// Size : "38"
// Qty : 100.0000000000
// ScannedQty : 0.0

class ScWorkCardSizeInfos {
  ScWorkCardSizeInfos({
    this.size,
    this.qty,
    this.todayReportQty,
    this.scannedQty,
  });

  ScWorkCardSizeInfos.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    // todayReportQty = JsonParse.toDouble(json['TodayReportQty']);
    todayReportQty = 0;
    scannedQty = JsonParse.toDouble(json['ScannedQty']);
  }

  String? size; //尺码
  double? qty; //指令数
  double? todayReportQty; //汇报数
  double? scannedQty; //累计汇报数

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['TodayReportQty'] = todayReportQty;
    map['ScannedQty'] = scannedQty;
    return map;
  }

  double getOwe() {
    return qty! - scannedQty!;
  }

  String getCompletionRate() {
    var completionRate = (1 - getOwe() / qty!) * 100;
    return "${Decimal.parse(completionRate.toStringAsFixed(2))}%";
  }
}
