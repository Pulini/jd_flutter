class ProcessModifyInfo {
  ProcessModifyInfo({
      this.barCode,
      this.mustQty,
      this.qty,
      this.size,});

  ProcessModifyInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    size = json['Size'];
    mustQty = json['MustQty'];
    qty = json['Qty'];

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