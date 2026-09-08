import 'package:jd_flutter/utils/extension_util.dart';
class MoldingPackAreaReportInfo {
  // 类型
  int? type;

  // 线别
  String? departmentName;

  // 指令ID
  int? interID;

  // 销售订单
  String? orderNo;

  // 客户订单号
  String? clientOrderNumber;

  // 交期
  String? fetchDate;

  // 型体
  String? factoryType;

  // 颜色
  String? color;

  // 订单件数
  double? orderPiece;

  // 订单双数
  double? orderQty;

  // 入包装区双数
  double? inPackAreaQty;

  // 未入包装区双数
  double? notInPackAreaQty;

  // 可配箱双数
  double? distributedQty;

  // 可配箱件数
  double? distributedPiece;

  // 偏码数
  double? remainQty;

  // SAP过账双数
  double? sapFinishQty;

  // SAP过账件数
  double? sapFinishPiece;

  // SAP未过账双数
  double? sapUnFinishQty;

  // SAP未过账件数
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
    type = JsonParse.toInt(json['Type']);
    departmentName = json['DepartmentName'] ?? '';
    interID = JsonParse.toInt(json['InterID']);
    orderNo = JsonParse.str(json['OrderNo']);
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    fetchDate = JsonParse.str(json['FetchDate']);
    factoryType = JsonParse.str(json['FactoryType']);
    color = JsonParse.str(json['Color']);
    orderPiece = JsonParse.toDouble(json['OrderPiece']);
    orderQty = JsonParse.toDouble(json['OrderQty']);
    inPackAreaQty = JsonParse.toDouble(json['InPackAreaQty']);
    notInPackAreaQty = JsonParse.toDouble(json['NotInPackAreaQty']);
    distributedQty = JsonParse.toDouble(json['DistributedQty']);
    distributedPiece = JsonParse.toDouble(json['DistributedPiece']);
    remainQty = JsonParse.toDouble(json['RemainQty']);
    sapFinishQty = JsonParse.toDouble(json['SAPFinishQty']);
    sapFinishPiece = JsonParse.toDouble(json['SAPFinishPiece']);
    sapUnFinishQty = JsonParse.toDouble(json['SAPUnfinishQty']);
    sapUnFinishPiece = JsonParse.toDouble(json['SAPUnfinishPiece']);
  }
}

class MoldingPackAreaReportDetailInfo {
  // 客户订单号
  String? clientOrderNumber;

  // 订单行号
  String? clientOrderIndex;

  // 尺码
  String? size;

  // 订单双数
  double? orderQty;

  // 订单件数
  double? orderPiece;

  // 分配双数
  double? distributedQty;

  // 分配件数
  double? distributedPiece;

  // 偏码数
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
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    clientOrderIndex = JsonParse.str(json['ClientOrderIndex']);
    size = JsonParse.str(json['Size']);
    orderQty = JsonParse.toDouble(json['OrderQty']);
    orderPiece = JsonParse.toDouble(json['OrderPiece']);
    distributedQty = JsonParse.toDouble(json['DistributedQty']);
    distributedPiece = JsonParse.toDouble(json['DistributedPiece']);
    remainQty = JsonParse.toDouble(json['RemainQty']);
  }
}
