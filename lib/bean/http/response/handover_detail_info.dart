import 'package:jd_flutter/utils/extension_util.dart';
class HandoverDetailInfo {
  HandoverDetailInfo({
    this.factoryType,
    this.upPartName,
    this.downPartName,
    this.upProcessName,
    this.downProcessName,
    this.upDeptName,
    this.downDeptName,
    this.items,
    this.summary,
  });

  HandoverDetailInfo.fromJson(dynamic json) {
    factoryType = JsonParse.str(json['FactoryType']);
    upPartName = JsonParse.str(json['UpPartName']);
    downPartName = JsonParse.str(json['DownPartName']);
    upProcessName = JsonParse.str(json['UpProcessName']);
    downProcessName = JsonParse.str(json['DownProcessName']);
    upDeptName = JsonParse.str(json['UpDeptName']);
    downDeptName = JsonParse.str(json['DownDeptName']);
    items = JsonParse.list(json['Items'], Item.fromJson);
    summary = JsonParse.list(json['Summary'], SummaryList.fromJson);
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryType'] = factoryType;
    map['UpPartName'] = upPartName;
    map['DownPartName'] = downPartName;
    map['UpProcessName'] = upProcessName;
    map['DownProcessName'] = downProcessName;
    map['UpDeptName'] = upDeptName;
    map['DownDeptName'] = downDeptName;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      map['Summary'] = summary?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String? factoryType; //型体
  String? upPartName;  //上游部件
  String? downPartName;  //下游部件
  String? upProcessName; //上游工序
  String? downProcessName; //下游工序
  String? upDeptName; //上游部门
  String? downDeptName; //下游部门
  List<Item>? items;
  List<SummaryList>? summary;
}

class Item {
  Item({
    this.barCode,
    this.size,
    this.qty,
    this.mtono,

  });

  Item.fromJson(dynamic json) {
    barCode = JsonParse.str(json['BarCode']);
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    mtono = JsonParse.str(json['Mtono']);

  }

  String? barCode;
  String? size;
  double? qty;
  String? mtono;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Size'] = size;
    map['Qty'] = qty;
    map['Mtono'] = mtono;
    return map;
  }
}

class SummaryList {
  SummaryList({
    this.type,
    this.partName, //部件名
    this.factoryType, //型体
    this.size,
    this.qty,  //数量
    this.mtonoQty,  //指令数量
    this.mtono,  //指令

  });

  SummaryList.fromJson(dynamic json) {
    type = JsonParse.toInt(json['Type']);
    partName = JsonParse.str(json['PartName']);
    factoryType = JsonParse.str(json['FactoryType']);
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    mtonoQty = JsonParse.toDouble(json['MtonoQty']);
    mtono = JsonParse.str(json['Mtono']);

  }

  int? type;
  String? partName;
  String? factoryType;
  String? size;
  double? qty;
  double? mtonoQty;
  String? mtono;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['PartName'] = partName;
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['Qty'] = qty;
    map['MtonoQty'] = mtonoQty;
    map['Mtono'] = mtono;
    return map;
  }
}
