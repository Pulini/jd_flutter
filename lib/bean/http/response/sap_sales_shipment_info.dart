import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/utils/utils.dart';

class SapSalesShipmentInfo {
  String? factory; //工厂  WERKS
  String? instructionNo; //指令号 ZVBELN_ORI
  String? typeBody; //型体 ZZXTNO
  String? saleOrder; //销售订单号 VBELN
  String? deliveryDate; //订单交期 EDATU
  String? size; //尺码 SIZE1
  String? materialCode; //物料编号 MATNR
  String? materialName; //物料名称 MAKTX
  double? orderQty; //订单数量 KWMENG
  double? deliveredQty; //已交货数量  LFIMG
  double? recordedQty; //已过帐数量 LFIMG_POSTED
  double? undeliveredQty; //未交货数量  LFIMG_REMAIN
  String? unit; //单位 MEINS

  SapSalesShipmentInfo({
    this.factory,
    this.instructionNo,
    this.typeBody,
    this.saleOrder,
    this.deliveryDate,
    this.size,
    this.materialCode,
    this.materialName,
    this.orderQty,
    this.deliveredQty,
    this.recordedQty,
    this.undeliveredQty,
    this.unit,
  });

  SapSalesShipmentInfo.fromJson(dynamic json) {
    factory = json['WERKS'];
    instructionNo = json['ZVBELN_ORI'];
    typeBody = json['ZZXTNO'];
    saleOrder = json['VBELN'];
    deliveryDate = json['EDATU'];
    size = json['SIZE1'];
    materialCode = json['MATNR'];
    materialName = json['MAKTX'];
    orderQty = json['KWMENG'];
    deliveredQty = json['LFIMG'].toDouble();
    recordedQty = json['LFIMG_POSTED'].toDouble();
    undeliveredQty = json['LFIMG_REMAIN'].toDouble();
    unit = json['MEINS'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['WERKS'] = factory;
    map['ZVBELN_ORI'] = instructionNo;
    map['ZZXTNO'] = typeBody;
    map['VBELN'] = saleOrder;
    map['EDATU'] = deliveryDate;
    map['SIZE1'] = size;
    map['MATNR'] = materialCode;
    map['MAKTX'] = materialName;
    map['KWMENG'] = orderQty;
    map['LFIMG'] = deliveredQty;
    map['LFIMG_POSTED'] = recordedQty;
    map['LFIMG_REMAIN'] = undeliveredQty;
    map['MEINS'] = unit;
    return map;
  }
}

class SapSalesShipmentPalletInfo {
  List<SapSalesShipmentInfo> instructionList = [];
  List<SapPalletDetailInfo> palletList = [];
  double materialPickQty(String materialCode) {
    if (palletList.isEmpty) {
      return 0;
    } else {
      return palletList
          .where((v) => v.materialCode == materialCode)
          .map((v) => v.pickQty)
          .reduce((a, b) => a.add(b));
    }
  }
}
