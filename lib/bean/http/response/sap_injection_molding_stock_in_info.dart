import 'package:jd_flutter/utils/extension_util.dart';

class SapInjectionMoldingStockInInfo {
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
  double? dispatchQty; //派工数量 ENMNG
  double? receivedQty; //已入库数 ENMNG_Y
  double? reportQty; //报工数  ENMNG_C
  String? basicUnit; //基本单位  MEINS
  String? palletNumber; //托盘号  ZFTRAYNO
  String? labelNumber;//标签  BQID

  SapInjectionMoldingStockInInfo({
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
  SapInjectionMoldingStockInInfo.fromJson(dynamic json) {
    dispatchNumber = JsonParse.str(json['DISPATCH_NO']);
    dispatchLineNumber = JsonParse.str(json['DISPATCH_ITEM']);
    dispatchDate = JsonParse.str(json['ERDAT']);
    reportDate = JsonParse.str(json['ZZBGRQ']);
    process = JsonParse.str(json['KTSCH']);
    productionOrderNo = JsonParse.str(json['AUFNR']);
    factoryNo = JsonParse.str(json['WERKS']);
    typeBody = JsonParse.str(json['ZZXTNO']);
    materialCode = JsonParse.str(json['MATNR']);
    materialName = JsonParse.str(json['MAKTX']);
    size = JsonParse.str(json['ZCM']);
    dispatchQty = JsonParse.toDouble(json['ENMNG']);
    receivedQty = JsonParse.toDouble(json['ENMNG_Y']);
    reportQty = JsonParse.toDouble(json['ENMNG_C']);
    basicUnit = JsonParse.str(json['MEINS']);
    palletNumber = JsonParse.str(json['ZFTRAYNO']);
    labelNumber = JsonParse.str(json['BQID']);
  }
  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
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
