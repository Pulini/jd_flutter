import 'package:get/get.dart';

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
    materialCode = json['SATNR'];
    materialName = json['MAKTX_YB'];
    supplier = json['LIFNR'];
    supplierName = json['NAME1'];
    salesOrder = json['VBELN'];
    materialDocumentNo = json['MBLNR'];
    materialVoucherYear = json['MJAHR'];
    materialVoucherItem = json['ZEILE'];
    receiptQty = json['MENGE'];
    unit = json['MEINS'];
    purchaseOrder = json['EBELN'];
    purchaseOrderLineItem = json['EBELP'];
    postingDate = json['BUDAT'];
    user = json['ZUSNAM'];
    userNameCN = json['ZNAME_CN'];
    userNameEN = json['ZNAME_EN'];
    moveType = json['BWART'];
    reversalVoucher = json['LFBNR'];
  }
}