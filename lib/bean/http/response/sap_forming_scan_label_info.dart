class SapProduceStockInLabelInfo {
  int scanQty=0;

  String? division;//事业部  ZDIVISION
  String? customerPO;//客户PO ZZKHPO1
  String? labelCode;//外箱标(外箱条码) ZCTNLABEL
  String? packingMethod; //装箱方式  ZZZXFS
  int? labelTotalQty; //外箱标 总箱数 ZZXS
  int? labelReceivedQty; //外箱标 已入库箱数  ZYRKXS
  String? needCheck; //需要检查装箱方式:X表示要检查，''表示不检查 ZZXFS_CHECK
  String? deliveryOrder; //交货单 VBELN_IM

  SapProduceStockInLabelInfo({
    this.division,
    this.customerPO,
    this.labelCode,
    this.packingMethod,
    this.labelTotalQty,
    this.labelReceivedQty,
    this.needCheck,
    this.deliveryOrder,
  });

  SapProduceStockInLabelInfo.fromJson(dynamic json) {
    division = json['ZDIVISION'];
    customerPO = json['ZZKHPO1'];
    labelCode = json['ZCTNLABEL'];
    packingMethod = json['ZZZXFS'];
    labelTotalQty = json['ZZXS'];
    labelReceivedQty = json['ZYRKXS'];
    needCheck = json['ZZXFS_CHECK'];
    deliveryOrder = json['VBELN_IM'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZDIVISION'] = division;
    map['ZZKHPO1'] = customerPO;
    map['ZCTNLABEL'] = labelCode;
    map['ZZZXFS'] = packingMethod;
    map['ZZXS'] = labelTotalQty;
    map['ZYRKXS'] = labelReceivedQty;
    map['ZZXFS_CHECK'] = needCheck;
    map['VBELN_IM'] = deliveryOrder;
    return map;
  }
 String scanProgress(){
    return '$scanQty/${(labelTotalQty??0)-(labelReceivedQty??0)}';
  }
}

