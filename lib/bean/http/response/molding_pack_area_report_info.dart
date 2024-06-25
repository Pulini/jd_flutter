class MoldingPackAreaReportInfo {
  /// 类型
  int? type;

  /// 线别
  String? departmentName;

  /// 指令ID
  int? interID;

  /// 销售订单
  String? orderNo;

  /// 客户订单号
  String? clientOrderNumber;

  /// 交期
  String? fetchDate;

  /// 型体
  String? factoryType;

  /// 颜色
  String? color;

  /// 订单件数
  double? orderPiece;

  /// 订单双数
  double? orderQty;

  /// 入包装区双数
  double? inPackAreaQty;

  /// 未入包装区双数
  double? notInPackAreaQty;

  /// 可配箱双数
  double? distributedQty;

  /// 可配箱件数
  double? distributedPiece;

  /// 偏码数
  double? remainQty;

  /// SAP过账双数
  double? sapFinishQty;

  /// SAP过账件数
  double? sapFinishPiece;

  /// SAP未过账双数
  double? sapUnFinishQty;

  /// SAP未过账件数
  double? sapUnFinishPiece;

  MoldingPackAreaReportInfo({
    this.type,
    this.departmentName,
    this.interID,
    this.orderNo,
    this.clientOrderNumber,
    this.fetchDate,
    this.factoryType,
    this.color,
    this.orderPiece,
    this.orderQty,
    this.inPackAreaQty,
    this.notInPackAreaQty,
    this.distributedQty,
    this.distributedPiece,
    this.remainQty,
    this.sapFinishQty,
    this.sapFinishPiece,
    this.sapUnFinishQty,
    this.sapUnFinishPiece,
  });

  MoldingPackAreaReportInfo.fromJson(dynamic json) {
    type = json['Type'];
    departmentName = json['DepartmentName'] ?? '';
    interID = json['InterID'];
    orderNo = json['OrderNo'];
    clientOrderNumber = json['ClientOrderNumber'];
    fetchDate = json['FetchDate'];
    factoryType = json['FactoryType'];
    color = json['Color'];
    orderPiece = json['OrderPiece'];
    orderQty = json['OrderQty'];
    inPackAreaQty = json['InPackAreaQty'];
    notInPackAreaQty = json['NotInPackAreaQty'];
    distributedQty = json['DistributedQty'];
    distributedPiece = json['DistributedPiece'];
    remainQty = json['RemainQty'];
    sapFinishQty = json['SAPFinishQty'];
    sapFinishPiece = json['SAPFinishPiece'];
    sapUnFinishQty = json['SAPUnfinishQty'];
    sapUnFinishPiece = json['SAPUnfinishPiece'];
  }
}

class MoldingPackAreaReportDetailInfo {
  /// 客户订单号
  String? clientOrderNumber;

  /// 订单行号
  String? clientOrderIndex;

  /// 尺码
  String? size;

  /// 订单双数
  double? orderQty;

  /// 订单件数
  double? orderPiece;

  /// 分配双数
  double? distributedQty;

  /// 分配件数
  double? distributedPiece;

  /// 偏码数
  double? remainQty;

  MoldingPackAreaReportDetailInfo({
    this.clientOrderNumber,
    this.clientOrderIndex,
    this.size,
    this.orderQty,
    this.orderPiece,
    this.distributedQty,
    this.distributedPiece,
    this.remainQty,
  });

  MoldingPackAreaReportDetailInfo.fromJson(dynamic json) {
    clientOrderNumber = json['ClientOrderNumber'];
    clientOrderIndex = json['ClientOrderIndex'];
    size = json['Size'];
    orderQty = json['OrderQty'];
    orderPiece = json['OrderPiece'];
    distributedQty = json['DistributedQty'];
    distributedPiece = json['DistributedPiece'];
    remainQty = json['RemainQty'];
  }
}
