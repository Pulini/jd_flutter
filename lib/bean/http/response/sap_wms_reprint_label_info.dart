
class ReprintLabelInfo {
  bool select=false;

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
  String? unit; // MEINS
  String? deliveryDate; //单位 EINDT
  String? numPage; //交货日期  ZPQYM
  String? dispatchNumber; //页码 DISPATCH_NO
  String? decrementTableNumber; //派工单号 ZZDJBH
  String? dispatchDate; //递减表号 DISPATCH_DATE
  String? dayOrNightShift; //派工日期  ZZBC
  String? machineNumber; //昼夜班 ZZPGJT
  String? process; //机台号 KTSCH
  String? isNewLabel; //制程 ISNEW

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
    factory = json['WERKS'];
    warehouse = json['LGORT'];
    palletNumber = json['ZFTRAYNO'];
    labelNumber = json['BQID'];
    boxCapacity = json['ZXR'];
    materialCode = json['SATNR'];
    materialName = json['MAKTX'];
    typeBody = json['ZZXTNO'];
    size = json['SIZE1'];
    instructionNo = json['ZVBELN_ORI'];
    salesOrderNumber = json['KDAUF'];
    salesOrderLineItem = json['KDPOS'];
    quantity = json['MENGE'];
    unit = json['MEINS'];
    deliveryDate = json['EINDT'];
    numPage = json['ZPQYM'];
    dispatchNumber = json['DISPATCH_NO'];
    decrementTableNumber = json['ZZDJBH'];
    dispatchDate = json['DISPATCH_DATE'];
    dayOrNightShift = json['ZZBC'];
    machineNumber = json['ZZPGJT'];
    process = json['KTSCH'];
    isNewLabel = json['ISNEW'];
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
