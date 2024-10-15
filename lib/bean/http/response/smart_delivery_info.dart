
class SmartDeliveryOrderInfo {
  SmartDeliveryOrderInfo({
    this.lineNo,
    this.workCardInterID,
    this.workCardNo,
    this.salesOrderNo,
    this.typeBody,
    this.dispatchDate,
    this.dispatchQty,
    this.materialIssuanceStatus,
    this.depName,
  });

  SmartDeliveryOrderInfo.fromJson(dynamic json) {
    lineNo = json['LineNo'];
    workCardInterID = json['WorkCardInterID'];
    workCardNo = json['WorkCardNo'];
    salesOrderNo = json['SalesOrderNo'];
    typeBody = json['TypeBody'];
    dispatchDate = json['DispatchDate'];
    dispatchQty = json['DispatchQty'];
    materialIssuanceStatus = json['MaterialIssuanceStatus'];
    depName = json['DepName'];
  }

  int? lineNo; //行号
  int? workCardInterID; //生产派工单ID
  String? workCardNo; //派工单号
  String? salesOrderNo; //销售订单z
  String? typeBody; //工厂型体
  String? dispatchDate; //派工日期
  double? dispatchQty; //派工总量
  String? materialIssuanceStatus; //发料情况
  String? depName; //课组名称

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LineNo'] = lineNo;
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['SalesOrderNo'] = salesOrderNo;
    map['TypeBody'] = typeBody;
    map['DispatchDate'] = dispatchDate;
    map['DispatchQty'] = dispatchQty;
    map['MaterialIssuanceStatus'] = materialIssuanceStatus;
    map['DepName'] = depName;
    return map;
  }
}
