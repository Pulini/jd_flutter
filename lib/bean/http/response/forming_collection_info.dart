import 'package:jd_flutter/utils/utils.dart';

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
    this.entryFID,
    this.isClose,
    this.scWorkCardSizeInfos,
    this.sizeRelations,
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
    entryFID = json['EntryFID'];
    isClose = json['IsClose'];
    if (json['AbnormalQualityInfo'] != null) {
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

  String? deptID;  //部门ID
  String? workCardInterID;  //生产派工单ID
  String? workCardNo; //生产派工单号
  String? mapNumber; //客户货号
  String? clientOrderNumber;  //客户订单号
  String? moID;  //指令ID
  String? mtoNo;  //指令号
  String? productName;  //型体名称
  String? color;  //型体颜色
  String? priorityLevel;  //派工单优先级
  int? entryFID;  //唯一值
  bool? isClose;  //开关状态
  List<ScWorkCardSizeInfos>? scWorkCardSizeInfos;
  List<SizeRelations>? sizeRelations;
  bool isShow = false ; //是否显示

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
    map['IsClose'] = isClose;

    return map;
  }
}

class ScWorkCardSizeInfos {
  ScWorkCardSizeInfos({
    this.size,
    this.qty,
    this.scannedQty,
    this.todayScannedQty,
  });

  ScWorkCardSizeInfos.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    scannedQty = json['ScannedQty'];
    todayScannedQty = json['TodayScannedQty'];
  }

  String? size;  //尺码
  double? qty;  //指令数
  double? scannedQty; //累计汇报数
  double? todayScannedQty;  //今天汇报数

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['ScannedQty'] = scannedQty;
    map['TodayScannedQty'] = todayScannedQty;

    return map;
  }

  String getCompletionRate(){
      if(qty!>0.0){
       return '${(scannedQty!.div(qty!).mul(100)).mul(10).round()}%';
      }else{
        return '0%';
      }
  }

}

class SizeRelations {
  SizeRelations({
    this.size,
    this.barCode,
  });

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
