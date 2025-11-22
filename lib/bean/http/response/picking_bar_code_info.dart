import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// InterID : 67660
// Mtono : "JZ2300102"
// Size : "36"
// Qty : 200.0
// LabelCount : 1
// TotalQty : 800.0

class PickingBarCodeInfo {
  PickingBarCodeInfo({
    this.interID,
    this.mtono,
    this.size,
    this.qty,
    this.labelCount,
    this.totalQty,
  });

  PickingBarCodeInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    mtono = json['Mtono'];
    size = json['Size'];
    qty = json['Qty'];
    labelCount = json['LabelCount'];
    totalQty = json['TotalQty'];
    packingQty = (qty == 0.0) ? 0 : totalQty.sub(qty ?? 0);
    surplusQty=totalQty.sub(qty??0);
  }

  bool isSelected = false;
  int? interID;
  String? mtono;
  String? size;
  double? qty;
  int? labelCount;
  double? totalQty;
  double packingQty = 0.0;
  double surplusQty = 0.0;
  TextEditingController controller = TextEditingController();


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['Mtono'] = mtono;
    map['Size'] = size;
    map['Qty'] = qty;
    map['LabelCount'] = labelCount;
    map['TotalQty'] = totalQty;
    return map;
  }

  int maxLabel()=> packingQty == 0.0 ? 0 : totalQty.div(packingQty).ceil();


}
