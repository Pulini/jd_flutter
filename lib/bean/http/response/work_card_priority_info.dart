// WorkCardInterID : 854379
// GroupName : "DUA_Line 5"
// Priority : 1
// WorkCardNo : "P2512277"
// WorkCardDate : "2025-01-21"
// ProductName : "PDS25312387-03"
// SONo : "L2400263"
// ClientOrderNumber : "4602451145MYPUT"
// MapNumber : "31238703"
// RequireQty : 1000
// UndoneQty : 20

class WorkCardPriorityInfo {
  WorkCardPriorityInfo({
    this.workCardInterID,
    this.groupName,
    this.priority,
    this.workCardNo,
    this.workCardDate,
    this.productName,
    this.sONo,
    this.clientOrderNumber,
    this.mapNumber,
    this.requireQty,
    this.undoneQty,
    this.index=0,
    this.isChange=false,
  });

  WorkCardPriorityInfo.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    groupName = json['GroupName'];
    priority = json['Priority'];
    workCardNo = json['WorkCardNo'];
    workCardDate = json['WorkCardDate'];
    productName = json['ProductName'];
    sONo = json['SONo'];
    clientOrderNumber = json['ClientOrderNumber'];
    mapNumber = json['MapNumber'];
    requireQty = json['RequireQty'];
    undoneQty = json['UndoneQty'];
  }

  int? workCardInterID;
  String? groupName;
  int? priority;
  String? workCardNo; //型体
  String? workCardDate;
  String? productName;
  String? sONo; //销售订单
  String? clientOrderNumber; //客户订单
  String? mapNumber;
  double? requireQty; //派工数量
  double? undoneQty; //欠数
  bool isChange = false; //是否做过更改
  int index = 0; //原序号

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkCardInterID'] = workCardInterID;
    map['GroupName'] = groupName;
    map['Priority'] = priority;
    map['WorkCardNo'] = workCardNo;
    map['WorkCardDate'] = workCardDate;
    map['ProductName'] = productName;
    map['SONo'] = sONo;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['MapNumber'] = mapNumber;
    map['RequireQty'] = requireQty;
    map['UndoneQty'] = undoneQty;
    return map;
  }
}
