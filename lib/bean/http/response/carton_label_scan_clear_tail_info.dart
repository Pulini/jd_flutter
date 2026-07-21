// FactoryBody : "D13677-22B M"
// GroupName : "金帝PUMA成型5线后段"
// SalesOrder : "JZ2400002"
// CustomerOrderNumber : "202301040002"
// DispatchNumber : "P26115469"
// Brand : "DHM"
// SizeList : [{"Size":"35","OrderQty":2,"FullBoxQty":0,"UnFullBoxQty":0,"Arrears":0,"BarCode":"12001230091"},{"Size":"36","OrderQty":3,"FullBoxQty":0,"UnFullBoxQty":0,"Arrears":0,"BarCode":"12001230115"},{"Size":"37","OrderQty":4,"FullBoxQty":0,"UnFullBoxQty":0,"Arrears":0,"BarCode":"12001230117"},{"Size":"38":"OrderQty":5,"FullBoxQty":0,"UnFullBoxQty":0,"Arrears":0,"BarCode":"12001230119"}]

class CartonLabelScanClearTailInfo {
  CartonLabelScanClearTailInfo({
      this.factoryBody,
      this.groupName,
      this.salesOrder,
      this.customerOrderNumber,
      this.dispatchNumber,
      this.sizeList,

  });

  CartonLabelScanClearTailInfo.fromJson(dynamic json) {
    factoryBody = json['FactoryBody'];
    groupName = json['GroupName'];
    salesOrder = json['SalesOrder'];
    customerOrderNumber = json['CustomerOrderNumber'];
    dispatchNumber = json['DispatchNumber'];
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(ClearTailListInfo.fromJson(v));
      });
    }
  }
  String? factoryBody;
  String? groupName;
  String? salesOrder;
  String? customerOrderNumber;
  String? dispatchNumber;
  List<ClearTailListInfo>? sizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryBody'] = factoryBody;
    map['GroupName'] = groupName;
    map['SalesOrder'] = salesOrder;
    map['CustomerOrderNumber'] = customerOrderNumber;
    map['DispatchNumber'] = dispatchNumber;
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// Size : "35"
/// OrderQty : 2
/// FullBoxQty : 0
/// UnFullBoxQty : 0
/// Arrears : 0
/// BarCode : "12001230091"

class ClearTailListInfo {
  ClearTailListInfo({
      this.size,
      this.orderQty,
      this.fullBoxQty,
      this.unFullBoxQty,
      this.arrears,
      this.barCode,});

  ClearTailListInfo.fromJson(dynamic json) {
    size = json['Size'];
    orderQty = json['OrderQty'];
    fullBoxQty = json['FullBoxQty'];
    unFullBoxQty = json['UnFullBoxQty'];
    arrears = json['Arrears'];
    barCode = json['BarCode'];
  }
  String? size;
  int? orderQty;
  int? fullBoxQty;
  int? unFullBoxQty;
  int? arrears;
  int? thisScanQty=0;
  String? barCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['OrderQty'] = orderQty;
    map['FullBoxQty'] = fullBoxQty;
    map['UnFullBoxQty'] = unFullBoxQty;
    map['Arrears'] = arrears;
    map['BarCode'] = barCode;
    return map;
  }

}
