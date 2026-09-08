import 'package:jd_flutter/utils/extension_util.dart';
class QualityInspectionReceiptInfo {
  String? materialCode; //物料编码
  String? materialDescription; //物料描述
  List<Item>? item;

  QualityInspectionReceiptInfo.fromJson(dynamic json) {
    materialCode = JsonParse.str(json['MATNR']);
    materialDescription = JsonParse.str(json['MAKTX']);
    item = JsonParse.list(json['GT_ITEMS'], Item.fromJson);
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
    batch = JsonParse.str(json['CHARG']);
    qty = JsonParse.toDouble(json['ZCOSEPQTY']);

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['CHARG'] = batch;
    map['ZCOSEPQTY'] = qty;

    return map;
  }
}

