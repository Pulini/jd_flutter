import 'package:get/get.dart';

/// DeptID : "1036956"
/// WorkCardInterID : "935122"
/// WorkCardNo : "P2593129"
/// MapNumber : "40374101"
/// ClientOrderNumber : "4602582000"
/// MoID : "426928"
/// MtoNo : "JZ2502317"
/// ProductName : "PYW25403741-01"
/// Color : "PUMA 白/金"
/// PriorityLevel : "1"
/// IsClose : false
/// ToDayPlanQty : 0
/// ToDayFinishQty : 0
/// FinishQtyTotal : 0
/// EntryFID : "2359800"
/// ScWorkCardSizeInfos : [{"Size":"4","Qty":58,"ScannedQty":0,"TodayScannedQty":0},{"Size":"5","Qty":58,"ScannedQty":0,"TodayScannedQty":0},{"Size":"6","Qty":58,"ScannedQty":0,"TodayScannedQty":0},{"Size":"7","Qty":58,"ScannedQty":0,"TodayScannedQty":0},{"Size":"8","Qty":58,"ScannedQty":0,"TodayScannedQty":0},{"Size":"9","Qty":58,"ScannedQty":0,"TodayScannedQty":0}]
/// SizeRelations : [{"Size":"6","BarCode":"198551876318"},{"Size":"7","BarCode":"198551876325"},{"Size":"3","BarCode":"4069156875630"},{"Size":"4.5","BarCode":"4069156875708"},{"Size":"5","BarCode":"4069156875654"},{"Size":"8.5","BarCode":"4069156875715"},{"Size":"4","BarCode":"4069156875647"},{"Size":"6","BarCode":"4069156875661"},{"Size":"5","BarCode":"198551876301"},{"Size":"7","BarCode":"4069156875678"},{"Size":"3","BarCode":"198551876288"},{"Size":"9","BarCode":"4069156875692"},{"Size":"8","BarCode":"198551876332"},{"Size":"8","BarCode":"4069156875685"},{"Size":"4","BarCode":"198551876295"},{"Size":"9","BarCode":"198551876349"}]

class FormingCollectionInfo {
  FormingCollectionInfo({
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
      this.isClose, 
      this.toDayPlanQty, 
      this.toDayFinishQty, 
      this.finishQtyTotal, 
      this.entryFID, 
      this.scWorkCardSizeInfos, 
      this.sizeRelations,
      this.isShow = false,
      this.isScanShow = false,
  });

  FormingCollectionInfo.fromJson(dynamic json) {
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
    isClose = json['IsClose'];
    toDayPlanQty = json['ToDayPlanQty'];
    toDayFinishQty = json['ToDayFinishQty'];
    finishQtyTotal = json['FinishQtyTotal'];
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
  String? deptID;
  String? workCardInterID;
  String? workCardNo;
  String? mapNumber;
  String? clientOrderNumber;
  String? moID;
  String? mtoNo;
  String? productName;
  String? color;
  String? priorityLevel;
  bool? isClose;
  double? toDayPlanQty;
  double? toDayFinishQty;
  double? finishQtyTotal;
  String? entryFID;
  List<ScWorkCardSizeInfos>? scWorkCardSizeInfos;
  List<SizeRelations>? sizeRelations;
  bool isShow = false;   //当前扫码显示
  bool isScanShow = false;  //扫码清尾显示
  RxBool isSelect = false.obs;

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
    map['IsClose'] = isClose;
    map['ToDayPlanQty'] = toDayPlanQty;
    map['ToDayFinishQty'] = toDayFinishQty;
    map['FinishQtyTotal'] = finishQtyTotal;
    map['EntryFID'] = entryFID;
    if (scWorkCardSizeInfos != null) {
      map['ScWorkCardSizeInfos'] = scWorkCardSizeInfos?.map((v) => v.toJson()).toList();
    }
    if (sizeRelations != null) {
      map['SizeRelations'] = sizeRelations?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// Size : "6"
/// BarCode : "198551876318"

class SizeRelations {
  SizeRelations({
      this.size, 
      this.barCode,});

  SizeRelations.fromJson(dynamic json) {
    size = json['Size'];
    barCode = json['BarCode'];
  }
  String? size;
  String? barCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['BarCode'] = barCode;
    return map;
  }

}

/// Size : "4"
/// Qty : 58
/// ScannedQty : 0
/// TodayScannedQty : 0

class ScWorkCardSizeInfos {
  ScWorkCardSizeInfos({
      this.size, 
      this.qty, 
      this.scannedQty, 
      this.todayScannedQty,});

  ScWorkCardSizeInfos.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    scannedQty = json['ScannedQty'];
    todayScannedQty = json['TodayScannedQty'];
  }
  String? size;
  double? qty;
  double? scannedQty;
  double? todayScannedQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['ScannedQty'] = scannedQty;
    map['TodayScannedQty'] = todayScannedQty;
    return map;
  }

}