// BQID : "005056B46EAE1EDD95D266C728B0DC5B"
// OPTYPE : ""
// DISPATCH_NO : "000000000449"
// WERKS : ""
// ZZZXFS : "PP混箱"
// ZUSNAM : "009134"
// AEDAT : "2022-10-27"
// AEZET : "00:00:00"
// ZXR : 60.00
// DELFLG : ""
// ZDYCS : 0
// ZBQZT : ""
// ITEM : [{"MANDT":"300","BQID":"005056B46EAE1EDD95D266C728B0DC5B","MATNR":"0601010000501","SIZE1_ATINN":"35","MENGE":30.000,"ZZXTNO":"","MEINS":""},{"MANDT":"300","BQID":"005056B46EAE1EDD95D266C728B0DC5B","MATNR":"0601010000502","SIZE1_ATINN":"36","MENGE":30.000}]

class StockInBarcodeInfo {
  StockInBarcodeInfo({
    this.barCode,
    this.dispatchNo,
    this.factory,
    this.num,
    this.date,
    this.item,
  });

  StockInBarcodeInfo.fromJson(dynamic json) {
    barCode = json['BQID'];
    dispatchNo = json['DISPATCH_NO'];
    num = json['ZPQYM'];
    factory = json['WERKS'];
    date = json['AEDAT'];
    if (json['ITEM'] != null) {
      item = [];
      json['ITEM'].forEach((v) {
        item?.add(Item.fromJson(v));
      });
    }
  }

  String? barCode; //打标用的bqid
  String? num; //序号
  String? dispatchNo; //派工单号
  String? factory; //工厂
  String? date; //派工日期
  List<Item>? item;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BQID'] = barCode;
    map['DISPATCH_NO'] = dispatchNo;
    map['WERKS'] = factory;
    map['AEDAT'] = date;
    map['ZPQYM'] = num;
    if (item != null) {
      map['ITEM'] = item?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

// MANDT : "300"
// BQID : "005056B46EAE1EDD95D266C728B0DC5B"
// MATNR : "0601010000501"
// SIZE1_ATINN : "35"
// MENGE : 30.000
// ZZXTNO : ""
// MEINS : ""

class Item {
  Item({
    this.subBarcode,
    this.qty,
    this.size,
    this.typeBody,
    this.unit,
  });

  Item.fromJson(dynamic json) {
    subBarcode = json['BQID'];
    qty = json['MENGE'];
    size = json['SIZE1_ATINN'];
    typeBody = json['ZZXTNO'];
    unit = json['MEINS'];
  }

  String? subBarcode;  //条码
  double? qty; //贴标数量
  String? size;  //尺码
  String? typeBody;  //型体
  String? unit;  //单位

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MEINS'] = unit;
    map['ZZXTNO'] = typeBody;
    map['BQID'] = subBarcode;
    map['MENGE'] = qty;
    map['SIZE1_ATINN'] = size;
    return map;
  }
}
