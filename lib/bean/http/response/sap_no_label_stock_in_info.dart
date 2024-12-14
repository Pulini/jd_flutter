import 'package:jd_flutter/utils/utils.dart';

class SapNoLabelStockInInfo {
  double pickQty = 0;
  double notReceivedQty = 0;

  String? dispatchNumber; //派工单号 DISPATCH_NO
  String? dispatchLineNumber; //派工单行号  DISPATCH_ITEM
  String? dispatchDate; //派工日期 ERDAT
  String? reportDate; //报工日期 ZZBGRQ
  String? process; //制程  KTSCH
  String? productionOrderNo; //生产订单号 AUFNR
  String? factoryNo; //工厂  WERKS
  String? typeBody; //型体 ZZXTNO
  String? materialCode; //物料编号 MATNR
  String? materialName; //物料名称 MAKTX
  String? size; //尺码 ZCM
  double? dispatchQty; //派工数量  ENMNG
  double? receivedQty; //已入库数  ENMNG_Y
  double? reportQty; //报工数 ENMNG_C
  String? basicUnit; //基本单位  MEINS
  String? palletNumber; //托盘号  ZFTRAYNO
  String? labelNumber; //标签号 BQID

  SapNoLabelStockInInfo({
    this.dispatchNumber,
    this.dispatchLineNumber,
    this.dispatchDate,
    this.reportDate,
    this.process,
    this.productionOrderNo,
    this.factoryNo,
    this.typeBody,
    this.materialCode,
    this.materialName,
    this.size,
    this.dispatchQty,
    this.receivedQty,
    this.reportQty,
    this.basicUnit,
    this.palletNumber,
    this.labelNumber,
  });

  SapNoLabelStockInInfo.fromJson(dynamic json) {
    dispatchNumber = json['DISPATCH_NO'];
    dispatchLineNumber = json['DISPATCH_ITEM'];
    dispatchDate = json['ERDAT'];
    reportDate = json['ZZBGRQ'];
    process = json['KTSCH'];
    productionOrderNo = json['AUFNR'];
    factoryNo = json['WERKS'];
    typeBody = json['ZZXTNO'];
    materialCode = json['MATNR'];
    materialName = json['MAKTX'];
    size = json['ZCM'];
    dispatchQty = json['ENMNG'];
    receivedQty = json['ENMNG_Y'];
    reportQty = json['ENMNG_C'];
    basicUnit = json['MEINS'];
    palletNumber = json['ZFTRAYNO'];
    labelNumber = json['BQID'];
    notReceivedQty= (reportQty ?? 0).sub(receivedQty ?? 0);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DISPATCH_NO'] = dispatchNumber;
    map['DISPATCH_ITEM'] = dispatchLineNumber;
    map['ERDAT'] = dispatchDate;
    map['ZZBGRQ'] = reportDate;
    map['KTSCH'] = process;
    map['AUFNR'] = productionOrderNo;
    map['WERKS'] = factoryNo;
    map['ZZXTNO'] = typeBody;
    map['MATNR'] = materialCode;
    map['MAKTX'] = materialName;
    map['ZCM'] = size;
    map['ENMNG'] = dispatchQty;
    map['ENMNG_Y'] = receivedQty;
    map['ENMNG_C'] = reportQty;
    map['MEINS'] = basicUnit;
    map['ZFTRAYNO'] = palletNumber;
    map['BQID'] = labelNumber;
    return map;
  }


}

class SapNoLabelStockInItemInfo {
  bool select = false;
  double notReceivedQty = 0;
  List<SapNoLabelStockInInfo> materialList = [];

  SapNoLabelStockInItemInfo.fromDataList(List<SapNoLabelStockInInfo> data){
    materialList.addAll(data);
    notReceivedQty=  data.map((v)=>v.notReceivedQty).reduce((a,b)=>a.add(b));
  }
  double pickQty()=> materialList.map((v)=>v.pickQty).reduce((a,b)=>a.add(b));
}
