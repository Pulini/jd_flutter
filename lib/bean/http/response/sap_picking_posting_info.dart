import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class SapPickingPostingInfo {
  String label='';

  /// 行类型
  String? rowType;

  /// 物料编码
  String? materialCode;

  /// 物料描述
  String? materialName;

  /// 销售订单
  String? salesOrder;

  /// 销售订单项目
  int? salesOrderItem;

  /// 数量
  double? quantity;

  SapPickingPostingInfo({
    this.rowType,
    this.materialCode,
    this.materialName,
    this.salesOrder,
    this.salesOrderItem,
    this.quantity,
    this.label='',
  });

  factory SapPickingPostingInfo.fromJsonWithLabel(dynamic json,String  label) {
    return SapPickingPostingInfo(
      rowType: json['TYPE'],
      materialCode: json['MATNR'],
      materialName: json['MAKTX'],
      salesOrder: json['VBELN'],
      salesOrderItem: json['POSNR'].toString().toIntTry(),
      quantity: json['MENGE'].toString().toDoubleTry(),
    )..label=label;
  }
  factory SapPickingPostingInfo.fromJson(dynamic json) {
    return SapPickingPostingInfo(
      rowType: json['TYPE'],
      materialCode: json['MATNR'],
      materialName: json['MAKTX'],
      salesOrder: json['VBELN'],
      salesOrderItem: json['POSNR'].toString().toIntTry(),
      quantity: json['MENGE'].toString().toDoubleTry(),
      label: json['BQID']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'TYPE': rowType,
      'MATNR': materialCode,
      'MAKTX': materialName,
      'VBELN': salesOrder,
      'POSNR': salesOrderItem,
      'MENGE': quantity,
    };
  }
}
class SapPickingPostingCacheInfo{
  /// 订单号
  String? orderNum;

  /// 订单状态
  String? orderStatus;

  /// 物料编码
  String? materialCode;

  /// 物料描述
  String? materialName;

  /// 销售订单
  String? salesOrder;

  /// 销售订单项目
  int? salesOrderItem;

  /// 数量
  double? quantity;

  /// 创建日期
  String? createDate;

  /// 创建人
  String? creator;


  SapPickingPostingCacheInfo({
    this.orderNum,
    this.orderStatus,
    this.materialCode,
    this.materialName,
    this.salesOrder,
    this.salesOrderItem,
    this.quantity,
    this.createDate,
    this.creator,
  });

  factory SapPickingPostingCacheInfo.fromJson(Map<String, dynamic> json) {
    return SapPickingPostingCacheInfo(
      orderNum: json['ORDER_NUM'],
      orderStatus: json['ORDER_STATUS'],
      materialCode: json['MATNR'],
      materialName: json['MAKTX'],
      salesOrder: json['VBELN'],
      salesOrderItem: json['POSNR'].toString().toIntTry(),
      quantity: json['MENGE'].toString().toDoubleTry(),
      createDate: json['ERDAT'],
      creator: json['ERNAM'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ORDER_NUM': orderNum,
      'ORDER_STATUS': orderStatus,
      'MATNR': materialCode,
      'MAKTX': materialName,
      'VBELN': salesOrder,
      'POSNR': salesOrderItem,
      'MENGE': quantity,
      'ERDAT': createDate,
      'ERNAM': creator,
    };
  }
}


class SapPickingPostingGroup {
  var dataList = <SapPickingPostingInfo>[].obs;

  String material()=>'(${dataList.first.materialCode})${dataList.first.materialName}';
  int scanCount() => dataList.length;
  double cumulativeQty() => dataList
      .map((v) => v.quantity ?? 0)
      .reduce((a, b) => a.add(b));
  bool isExists(SapPickingPostingInfo data)=> dataList.any((v) => v.label == data.label);

}
