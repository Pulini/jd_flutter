
class PackingShipmentScanInfo {
  PackingShipmentScanInfo({
    this.item1,
    this.item2,
  });

  PackingShipmentScanInfo.fromJson(dynamic json) {

    if (json['GT_ITEMS'] != null) {
      item1 = [];
      json['GT_ITEMS'].forEach((v) {
        item1?.add(GtItem.fromJson(v));
      });
    }
    if (json['GT_ITEMS2'] != null) {
      item2 = [];
      json['GT_ITEMS2'].forEach((v) {
        item2?.add(GtItem2.fromJson(v));
      });
    }
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
    this.isThis,
  });

  String? customerPO;  //客户PO&仓库编号(订单号)
  String? boxNumber;    //箱数(应出箱数)
  String? sendBox;     //已发箱数
  String? originalOrderNumber;    //原始订单号合并
  String? salesDocument;   //销售凭证合并
  bool? isThis;   //传的是不是这条


  GtItem.fromJson(dynamic json) {
    customerPO = json['ZZKHPO2'];
    boxNumber = json['ZZYCXS'];
    sendBox = json['YFXS'];
    originalOrderNumber = json['ZYSDDHS'];
    salesDocument = json['VBELNS'];
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
    barCodes = json['ZCTNLABEL'];
    orderNumber = json['ZZKHPO2'];
    deliveryNumber = json['VBELN_VL'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZCTNLABEL'] = barCodes;
    map['ZZKHPO2'] = orderNumber;
    map['VBELN_VL'] = deliveryNumber;
    return map;
  }
}
