import 'package:jd_flutter/utils/extension_util.dart';

class PackingShipmentScanInfo {
  PackingShipmentScanInfo({
    this.item1,
    this.item2,
  });

  PackingShipmentScanInfo.fromJson(dynamic json) {

    item1 = JsonParse.list(json['GT_ITEMS'], GtItem.fromJson);
    item2 = JsonParse.list(json['GT_ITEMS2'], GtItem2.fromJson);
  }

  List<GtItem>? item1;
  List<GtItem2>? item2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (item1 != null) {
      map['GT_ITEMS'] = item1?.map((v) => v.toJson()).toList();
    }
    if (item2 != null) {
      map['gtItems2'] = item2?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class GtItem {
  GtItem({
    this.customerPO,
    this.boxNumber,
    this.sendBox,
    this.originalOrderNumber,
    this.salesDocument,
  });

  String? customerPO;  //客户PO&仓库编号(订单号)
  int? boxNumber;    //箱数(应出箱数)
  int? sendBox;     //已发箱数
  String? originalOrderNumber;    //原始订单号合并
  String? salesDocument;   //销售凭证合并
  bool isThis = false;   //传的是不是这条


  GtItem.fromJson(dynamic json) {
    customerPO = JsonParse.str(json['ZZKHPO2']);
    boxNumber = JsonParse.toInt(json['ZZYCXS']);
    sendBox = JsonParse.toInt(json['YFXS']);
    originalOrderNumber = JsonParse.str(json['ZYSDDHS']);
    salesDocument = JsonParse.str(json['VBELNS']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZZKHPO2'] = customerPO;
    map['ZZYCXS'] = boxNumber;
    map['YFXS'] = sendBox;
    map['ZYSDDHS'] = originalOrderNumber;
    map['VBELNS'] = salesDocument;
    return map;
  }
}

class GtItem2 {
  GtItem2({
    this.barCodes,
    this.orderNumber,
    this.deliveryNumber,
  });

  String? barCodes; //外箱条码
  String? orderNumber; //订单号
  String? deliveryNumber; //交货号

  GtItem2.fromJson(dynamic json) {
    barCodes = JsonParse.str(json['ZCTNLABEL']);
    orderNumber = JsonParse.str(json['ZZKHPO2']);
    deliveryNumber = JsonParse.str(json['VBELN_VL']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZCTNLABEL'] = barCodes;
    map['ZZKHPO2'] = orderNumber;
    map['VBELN_VL'] = deliveryNumber;
    return map;
  }
}
