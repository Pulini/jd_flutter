import 'package:jd_flutter/utils/extension_util.dart';
class MaterialDispatchLabelDetail {
  MaterialDispatchLabelDetail({
    this.billNo,
    this.qty,
  });

  MaterialDispatchLabelDetail.fromJson(dynamic json) {
    billNo = JsonParse.str(json['BillNo']);
    qty = JsonParse.toDouble(json['Qty']);

  }

  String? billNo;
  double? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillNo'] = billNo;
    map['Qty'] = qty;

    return map;
  }
}

