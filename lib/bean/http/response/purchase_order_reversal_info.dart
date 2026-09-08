import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class PurchaseOrderReversalInfo{
  RxBool isSelect=false.obs;

  String? materialCode;//SATNR  物料编码
  String? materialName;//MAKTX_YB 物料描述
  String? supplier;//LIFNR  供应商
  String? supplierName;//NAME1  供应商名称
  String? salesOrder;//VBELN  销售订单号
  String? materialDocumentNo;//MBLNR  物料凭证号
  String? materialVoucherYear;//MJAHR 凭证年度
  String? materialVoucherItem;//ZEILE 凭证行项目
  double? receiptQty;//MENGE  数量
  String? unit;//MEINS  单位
  String? purchaseOrder;//EBELN 采购订单号
  String? purchaseOrderLineItem;//EBELP 采购订单行
  String? postingDate;//BUDAT 过账日期
  String? user;//ZUSNAM 用户名
  String? userNameCN;//ZNAME_CN 中文
  String? userNameEN;//ZNAME_EN 英文
  String? moveType;//BWART  移动类型
  String? reversalVoucher;//LFBNR 冲销凭证

  PurchaseOrderReversalInfo({
    this.materialCode,
    this.materialName,
    this.supplier,
    this.supplierName,
    this.salesOrder,
    this.materialDocumentNo,
    this.materialVoucherYear,
    this.materialVoucherItem,
    this.receiptQty,
    this.unit,
    this.purchaseOrder,
    this.purchaseOrderLineItem,
    this.postingDate,
    this.user,
    this.userNameCN,
    this.userNameEN,
    this.moveType,
    this.reversalVoucher
  });
  PurchaseOrderReversalInfo.fromJson(dynamic json) {
    materialCode = JsonParse.str(json['SATNR']);
    materialName = JsonParse.str(json['MAKTX_YB']);
    supplier = JsonParse.str(json['LIFNR']);
    supplierName = JsonParse.str(json['NAME1']);
    salesOrder = JsonParse.str(json['VBELN']);
    materialDocumentNo = JsonParse.str(json['MBLNR']);
    materialVoucherYear = JsonParse.str(json['MJAHR']);
    materialVoucherItem = JsonParse.str(json['ZEILE']);
    receiptQty = JsonParse.toDouble(json['MENGE']);
    unit = JsonParse.str(json['MEINS']);
    purchaseOrder = JsonParse.str(json['EBELN']);
    purchaseOrderLineItem = JsonParse.str(json['EBELP']);
    postingDate = JsonParse.str(json['BUDAT']);
    user = JsonParse.str(json['ZUSNAM']);
    userNameCN = JsonParse.str(json['ZNAME_CN']);
    userNameEN = JsonParse.str(json['ZNAME_EN']);
    moveType = JsonParse.str(json['BWART']);
    reversalVoucher = JsonParse.str(json['LFBNR']);
  }
}