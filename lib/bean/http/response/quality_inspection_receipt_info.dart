class QualityInspectionReceiptInfo {
  String? materialCode; //物料编码
  String? materialDescription; //物料描述
  List<Item>? item;

  QualityInspectionReceiptInfo.fromJson(dynamic json) {
    materialCode = json['MATNR'];
    materialDescription = json['MAKTX'];
    if (json['GT_ITEMS'] != null) {
      item = [];
      json['GT_ITEMS'].forEach((v) {
        item?.add(Item.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['MATNR'] = materialCode;
    map['MAKTX'] = materialDescription;
    if (item != null) {
      map['GT_ITEMS'] = item?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Item {
  String? batch; //批次
  double? qty; //数量


  Item({
    this.batch,
    this.qty,

  });

  Item.fromJson(dynamic json) {
    batch = json['CHARG'];
    qty = json['ZCOSEPQTY'];

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['CHARG'] = batch;
    map['ZCOSEPQTY'] = qty;

    return map;
  }
}

