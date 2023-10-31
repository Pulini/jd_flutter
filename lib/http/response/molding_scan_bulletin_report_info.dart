import 'dart:ui';

/// DeptID : "554744"
/// WorkCardInterID : "213249"
/// WorkCardNo : "P2048786"
/// MapNumber : "1202300007"
/// ClientOrderNumber : "20230304001"
/// MoID : "155919"
/// MtoNo : "JZ2300007"
/// ProductName : "D13677-22B M"
/// Color : ""
/// PriorityLevel : "3"
/// EntryFID : "555868"
/// ScWorkCardSizeInfos : [{"Size":"38","Qty":100.0000000000,"ScannedQty":0.0},{"Size":"39","Qty":100.0000000000,"ScannedQty":0.0},{"Size":"40","Qty":100.0000000000,"ScannedQty":0.0}]
/// SizeRelations : [{"Size":"38","BarCode":"12023000070119"},{"Size":"39","BarCode":"12023000070121"},{"Size":"40","BarCode":"12023000070123"}]

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
    this.scWorkCardSizeInfos,
    this.sizeRelations,
  });

  MoldingScanBulletinReportInfo.fromJson(dynamic json) {
    deptID = json['DeptID'];
    workCardInterID = json['WorkCardInterID'];
    workCardNo = json['WorkCardNo'];
    mapNumber = json['MapNumber'];
    clientOrderNumber = json['ClientOrderNumber'];
    moID = json['MoID'];
    mtoNo = json['MtoNo'];
    productName = json['ProductName'];
    color = json['Color'];
    priorityLevel = json['PriorityLevel'];
    entryFID = json['EntryFID'];
    if (json['ScWorkCardSizeInfos'] != null) {
      scWorkCardSizeInfos = [];
      json['ScWorkCardSizeInfos'].forEach((v) {
        scWorkCardSizeInfos?.add(ScWorkCardSizeInfos.fromJson(v));
      });
    }
    if (json['SizeRelations'] != null) {
      sizeRelations = [];
      json['SizeRelations'].forEach((v) {
        sizeRelations?.add(SizeRelations.fromJson(v));
      });
    }
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
  List<ScWorkCardSizeInfos>? scWorkCardSizeInfos;
  List<SizeRelations>? sizeRelations;

  Color? itemColor; //item背景色

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
    if (scWorkCardSizeInfos != null) {
      map['ScWorkCardSizeInfos'] =
          scWorkCardSizeInfos?.map((v) => v.toJson()).toList();
    }
    if (sizeRelations != null) {
      map['SizeRelations'] = sizeRelations?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// Size : "38"
/// BarCode : "12023000070119"

class SizeRelations {
  SizeRelations({
    this.size,
    this.barCode,
  });

  SizeRelations.fromJson(dynamic json) {
    size = json['Size'];
    barCode = json['BarCode'];
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

/// Size : "38"
/// Qty : 100.0000000000
/// ScannedQty : 0.0

class ScWorkCardSizeInfos {
  ScWorkCardSizeInfos({
    this.size,
    this.qty,
    this.todayReportQty,
    this.scannedQty,
  });

  ScWorkCardSizeInfos.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    // todayReportQty = json['TodayReportQty'];
    todayReportQty = 0;
    scannedQty = json['ScannedQty'];
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
}
