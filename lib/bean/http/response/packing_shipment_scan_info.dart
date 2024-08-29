import 'dart:ffi';

class PackingShipmentScanInfo {
  PackingShipmentScanInfo({
    this.GT_ITEMS,
    this.GT_ITEMS2,
  });

  PackingShipmentScanInfo.fromJson(dynamic json) {

    if (json['GTITEMS'] != null) {
      GT_ITEMS = [];
      json['ReportList'].forEach((v) {
        GT_ITEMS?.add(gtItems.fromJson(v));
      });
    }
    if (json['GTITEMS2'] != null) {
      GT_ITEMS2 = [];
      json['BarCodeList'].forEach((v) {
        GT_ITEMS2?.add(gtItems2.fromJson(v));
      });
    }
  }

  List<gtItems>? GT_ITEMS;
  List<gtItems2>? GT_ITEMS2;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};

    if (GT_ITEMS != null) {
      map['gtItems'] = GT_ITEMS?.map((v) => v.toJson()).toList();
    }
    if (GT_ITEMS2 != null) {
      map['gtItems2'] = GT_ITEMS2?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class gtItems {
  gtItems({
    this.ZZKHPO2,
    this.ZZYCXS,
    this.YFXS,
    this.ZYSDDHS,
    this.VBELNS,
    this.isThis,
  });

  String? ZZKHPO2;  //客户PO&仓库编号(订单号)
  String? ZZYCXS;    //箱数(应出箱数)
  String? YFXS;     //已发箱数
  String? ZYSDDHS;    //原始订单号合并
  String? VBELNS;   //销售凭证合并
  bool? isThis;   //传的是不是这条


  gtItems.fromJson(dynamic json) {
    ZZKHPO2 = json['ZZKHPO2'];
    ZZYCXS = json['ZZYCXS'];
    YFXS = json['YFXS'];
    ZYSDDHS = json['ZYSDDHS'];
    VBELNS = json['VBELNS'];
    isThis = json['isThis'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZZKHPO2'] = ZZKHPO2;
    map['ZZYCXS'] = ZZYCXS;
    map['YFXS'] = YFXS;
    map['ZYSDDHS'] = ZYSDDHS;
    map['VBELNS'] = VBELNS;
    map['isThis'] = isThis;
    return map;
  }
}

class gtItems2 {
  gtItems2({
    this.ZCTNLABEL,
    this.ZZKHPO2,
    this.VBELN_VL,
  });

  String? ZCTNLABEL; //外箱条码
  double? ZZKHPO2; //订单号
  String? VBELN_VL; //交货号

  gtItems2.fromJson(dynamic json) {
    ZCTNLABEL = json['ZCTNLABEL'];
    ZZKHPO2 = json['ZZKHPO2'];
    VBELN_VL = json['VBELN_VL'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZCTNLABEL'] = ZCTNLABEL;
    map['ZZKHPO2'] = ZZKHPO2;
    map['VBELN_VL'] = VBELN_VL;
    return map;
  }
}
