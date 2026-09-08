import 'package:jd_flutter/utils/extension_util.dart';
class ReprintLabelInfo {
  bool select = false;

  String? factory; //工厂  WERKS
  String? warehouse; //仓库  LGORT
  String? palletNumber; //托盘号  ZFTRAYNO
  String? labelNumber; //标签号 BQID
  double? boxCapacity; //相容  ZXR
  String? materialCode; //物料编码 SATNR
  String? materialName; //物料名称 MAKTX
  String? typeBody; //型体 ZZXTNO
  String? size; //尺码 SIZE1
  String? instructionNo; //指令号 ZVBELN_ORI
  String? salesOrderNumber; //销售订单号  KDAUF
  int? salesOrderLineItem; //销售订单行号  KDPOS
  double? quantity; //数量 MENGE
  String? unit; //单位 MEINS
  String? deliveryDate; //交货日期 EINDT
  String? numPage; // 页码 ZPQYM
  String? dispatchNumber; //派工单号 DISPATCH_NO
  String? decrementTableNumber; //递减表号 ZZDJBH
  String? dispatchDate; //派工日期 DISPATCH_DATE
  String? dayOrNightShift; // 昼夜班 ZZBC
  String? machineNumber; //机台号 ZZPGJT
  String? process; //制程 KTSCH
  String? isNewLabel; //是否新标 ISNEW

  ReprintLabelInfo({
    this.factory,
    this.warehouse,
    this.palletNumber,
    this.labelNumber,
    this.boxCapacity,
    this.materialCode,
    this.materialName,
    this.typeBody,
    this.size,
    this.instructionNo,
    this.salesOrderNumber,
    this.salesOrderLineItem,
    this.quantity,
    this.unit,
    this.deliveryDate,
    this.numPage,
    this.dispatchNumber,
    this.decrementTableNumber,
    this.dispatchDate,
    this.dayOrNightShift,
    this.machineNumber,
    this.process,
    this.isNewLabel,
  });

  ReprintLabelInfo.fromJson(dynamic json) {
    factory = JsonParse.str(json['WERKS']);
    warehouse = JsonParse.str(json['LGORT']);
    palletNumber = JsonParse.str(json['ZFTRAYNO']);
    labelNumber = JsonParse.str(json['BQID']);
    boxCapacity = JsonParse.toDouble(json['ZXR']);
    materialCode = JsonParse.str(json['SATNR']);
    materialName = JsonParse.str(json['MAKTX']);
    typeBody = JsonParse.str(json['ZZXTNO']);
    size = JsonParse.str(json['SIZE1']);
    instructionNo = JsonParse.str(json['ZVBELN_ORI']);
    salesOrderNumber = JsonParse.str(json['KDAUF']);
    salesOrderLineItem = JsonParse.toInt(json['KDPOS']);
    quantity = json['MENGE'].toDouble();
    unit = JsonParse.str(json['MEINS']);
    deliveryDate = JsonParse.str(json['EINDT']);
    numPage = JsonParse.str(json['ZPQYM']);
    dispatchNumber = JsonParse.str(json['DISPATCH_NO']);
    decrementTableNumber = JsonParse.str(json['ZZDJBH']);
    dispatchDate = JsonParse.str(json['DISPATCH_DATE']);
    dayOrNightShift = JsonParse.str(json['ZZBC']);
    machineNumber = JsonParse.str(json['ZZPGJT']);
    process = JsonParse.str(json['KTSCH']);
    isNewLabel = JsonParse.str(json['ISNEW']);
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['WERKS'] = factory;
    map['LGORT'] = warehouse;
    map['ZFTRAYNO'] = palletNumber;
    map['BQID'] = labelNumber;
    map['ZXR'] = boxCapacity;
    map['SATNR'] = materialCode;
    map['MAKTX'] = materialName;
    map['ZZXTNO'] = typeBody;
    map['SIZE1'] = size;
    map['ZVBELN_ORI'] = instructionNo;
    map['KDAUF'] = salesOrderNumber;
    map['KDPOS'] = salesOrderLineItem;
    map['MENGE'] = quantity;
    map['MEINS'] = unit;
    map['EINDT'] = deliveryDate;
    map['ZPQYM'] = numPage;
    map['DISPATCH_NO'] = dispatchNumber;
    map['ZZDJBH'] = decrementTableNumber;
    map['DISPATCH_DATE'] = dispatchDate;
    map['ZZBC'] = dayOrNightShift;
    map['ZZPGJT'] = machineNumber;
    map['KTSCH'] = process;
    map['ISNEW'] = isNewLabel;
    return map;
  }
}
