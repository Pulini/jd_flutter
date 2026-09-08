import 'package:jd_flutter/utils/extension_util.dart';
class ProcessModifyInfo {
  ProcessModifyInfo({
      this.barCode,
      this.mustQty,
      this.qty,
      this.size,});

  ProcessModifyInfo.fromJson(dynamic json) {
    barCode = JsonParse.str(json['BarCode']);
    size = JsonParse.str(json['Size']);
    mustQty = JsonParse.str(json['MustQty']);
    qty = JsonParse.str(json['Qty']);

  }
  String? barCode;
  String? size;
  String? mustQty;
  String? qty;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Size'] = size;
    map['MustQty'] = mustQty;
    map['Qty'] = qty;

    return map;
  }

}