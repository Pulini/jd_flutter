/// WorkCardInterID : 1231836
/// WorkCardNo : "P26124283"
/// WorkCardDate : "2026-06-24"
/// FetchDate : "2026-06-23"
/// DepartmentName : "IDN_LastingLine_01"
/// ProductName : "PNW25402632-02"
/// SeOrderNo : "L2605324"

class OrderProductionExecutionInfo {
  OrderProductionExecutionInfo({
      this.workCardInterID, 
      this.workCardNo, 
      this.workCardDate, 
      this.fetchDate, 
      this.departmentName, 
      this.seOrderQty,
      this.productName,
      this.searchType,
      this.scanQty,
      this.seOrderNo,});

  OrderProductionExecutionInfo.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    workCardNo = json['WorkCardNo'];
    workCardDate = json['WorkCardDate'];
    fetchDate = json['FetchDate'];
    departmentName = json['DepartmentName'];
    productName = json['ProductName'];
    seOrderNo = json['SeOrderNo'];
    seOrderQty = json['SeOrderQty'];
    scanQty = json['ScanQty'];
    searchType = json['SearchType'];
  }
  int? workCardInterID;
  double? seOrderQty;
  int? scanQty;
  String? workCardNo;
  String? workCardDate;
  String? fetchDate;
  String? departmentName;
  String? productName;
  String? seOrderNo;
  int? searchType;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ScanQty'] = scanQty;
    map['SeOrderQty'] = seOrderQty;
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['WorkCardDate'] = workCardDate;
    map['FetchDate'] = fetchDate;
    map['DepartmentName'] = departmentName;
    map['ProductName'] = productName;
    map['SeOrderNo'] = seOrderNo;
    map['SearchType'] = searchType;
    return map;
  }

}