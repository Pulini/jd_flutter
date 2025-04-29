/// ProductName : "鞋面-DX192116-B2B"
/// List : [{"Type":0,"Name":"烫钻TPU商标字体（2片/双）","Mtono":"J2502376","Size":"37","MtonoQty":75.0000000000,"Qty":75.00000,"EmpName":"安艳芝"}]

class ReportDetailsInfo {
  ReportDetailsInfo({
    this.productName,
    this.list,});

  ReportDetailsInfo.fromJson(dynamic json) {
    productName = json['ProductName'];
    if (json['List'] != null) {
      list = [];
      json['List'].forEach((v) {
        list?.add(SummaryLists.fromJson(v));
      });
    }
  }
  String? productName;
  List<SummaryLists>? list;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProductName'] = productName;
    if (list != null) {
      map['List'] = list?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// Type : 0
/// Name : "烫钻TPU商标字体（2片/双）"
/// Mtono : "J2502376"
/// Size : "37"
/// MtonoQty : 75.0000000000
/// Qty : 75.00000
/// EmpName : "安艳芝"

class SummaryLists {
  SummaryLists({
    this.type,
    this.name,
    this.mtono,
    this.size,
    this.mtonoQty,
    this.qty,
    this.empName,});

  SummaryLists.fromJson(dynamic json) {
    type = json['Type'];
    name = json['Name'];
    mtono = json['Mtono'];
    size = json['Size'];
    mtonoQty = json['MtonoQty'];
    qty = json['Qty'];
    empName = json['EmpName'];
  }
  int? type;
  String? name;
  String? mtono;
  String? size;
  double? mtonoQty;
  double? qty;
  String? empName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['Name'] = name;
    map['Mtono'] = mtono;
    map['Size'] = size;
    map['MtonoQty'] = mtonoQty;
    map['Qty'] = qty;
    map['EmpName'] = empName;
    return map;
  }

}