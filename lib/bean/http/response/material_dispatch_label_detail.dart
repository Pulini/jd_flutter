class MaterialDispatchLabelDetail {
  MaterialDispatchLabelDetail({
    this.billNo,
    this.qty,
  });

  MaterialDispatchLabelDetail.fromJson(dynamic json) {
    billNo = json['BillNo'];
    qty = json['Qty'];

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

