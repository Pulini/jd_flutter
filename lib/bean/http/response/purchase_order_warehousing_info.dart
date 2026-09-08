import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class PurchaseOrderInfo {
  String? companyCode; //公司代码
  String? factoryNumber; //工厂编号
  String? factoryDescription; //工厂描述
  String? purchaseOrderNumber; //采购订单号
  String? materialCode; //一般物料编号
  String? materialName; //一般物料描述
  String? factoryArea; //区域
  String? typeBody; //型体
  String? salesOrder; //销售订单
  String? supplier; //供应商
  String? supplierName; //供应商名称
  String? unit; //单位
  String? isScanPieces; //是否需要绑定标签 "X" or ""
  String? isNoCheck; //是否免检
  String? customerPO; //客户PO号
  String? type; //订单类型
  List<PurchaseOrderDetailsInfo>? details;

  PurchaseOrderInfo({
    this.companyCode,
    this.factoryNumber,
    this.factoryDescription,
    this.purchaseOrderNumber,
    this.materialCode,
    this.materialName,
    this.factoryArea,
    this.typeBody,
    this.salesOrder,
    this.supplier,
    this.supplierName,
    this.unit,
    this.isScanPieces,
    this.isNoCheck,
    this.customerPO,
    this.type,
    this.details,
  });

  PurchaseOrderInfo.fromJson(dynamic json) {
    companyCode = JsonParse.str(json['CompanyCode']);
    factoryNumber = JsonParse.str(json['FactoryNumber']);
    factoryDescription = JsonParse.str(json['FactoryDescription']);
    purchaseOrderNumber = JsonParse.str(json['PurchaseOrderNumber']);
    materialCode = JsonParse.str(json['SATNR']);
    materialName = JsonParse.str(json['MAKTX_YB']);
    factoryArea = JsonParse.str(json['ZQY']);
    typeBody = JsonParse.str(json['ZZXTNO']);
    salesOrder = JsonParse.str(json['VBELN']);
    supplier = JsonParse.str(json['LIFNR']);
    supplierName = JsonParse.str(json['NAME1']);
    unit = JsonParse.str(json['MEINS']);
    isScanPieces = JsonParse.str(json['IsScanPieces']);
    isNoCheck = JsonParse.str(json['IsNoCheck']);
    customerPO = JsonParse.str(json['CustomerPO']);
    type = JsonParse.str(json['Type']);
    details = [];
    if (json['ZCGSLTZD_ITEM'] != null) {
      json['ZCGSLTZD_ITEM'].forEach((v) {
        details!.add(PurchaseOrderDetailsInfo.fromJson(v,unit??''));
      });
    }
  }

  bool isSelectAll() => details!.every((v) => v.isSelected.value);

  void selectAll(bool select) {
    for (var v in details!) {
      v.isSelected.value = select;
    }
  }
}

class PurchaseOrderDetailsInfo {
  RxDouble qty = 0.0.obs;
  RxBool isSelected = false.obs;
  String unit='';

  String? purchaseOrder; //采购订单行
  String? purchaseOrderLineItem; //采购订单行
  String? remark; //备注
  String? size; //尺码
  String? orderQty; //订单数量
  String? receivedQty; //已收货数量
  String? underNum; //欠数
  String? issuedDeliveryOrderNum; //已送货数
  String? unqualifiedNum; //不合格数
  String? location; //库位
  String? locationDescription; //库位描述
  String? customerPO; //客户PO号
  String? trackNo; //跟踪号
  List<ReceiptVoucherInfo>? receiptVoucher;

  PurchaseOrderDetailsInfo({
    this.purchaseOrder,
    this.purchaseOrderLineItem,
    this.remark,
    this.size,
    this.orderQty,
    this.receivedQty,
    this.underNum,
    this.issuedDeliveryOrderNum,
    this.unqualifiedNum,
    this.location,
    this.locationDescription,
    this.customerPO,
    this.trackNo,
    this.receiptVoucher,
  });

  PurchaseOrderDetailsInfo.fromJson(dynamic json,this.unit) {
    purchaseOrder = JsonParse.str(json['EBELN']);
    purchaseOrderLineItem = JsonParse.str(json['EBELP']);
    remark = JsonParse.str(json['ZREMARK']);
    size = JsonParse.str(json['SIZE1']);
    orderQty = JsonParse.str(json['MENGE']);
    receivedQty = JsonParse.str(json['WEMNG']);
    underNum = JsonParse.str(json['UnderNum']);
    issuedDeliveryOrderNum = JsonParse.str(json['IssuedDeliveryOrderNum']);
    unqualifiedNum = JsonParse.str(json['UnqualifiedNum']);
    location = JsonParse.str(json['Location']);
    locationDescription = JsonParse.str(json['LocationDescription']);
    customerPO = JsonParse.str(json['CustomerPO']);
    trackNo = JsonParse.str(json['TrackNo']);
    receiptVoucher = JsonParse.list(json['GT_ITEMS'], ReceiptVoucherInfo.fromJson);
    qty.value=underNum.toDoubleTry();
  }
}

class ReceiptVoucherInfo {
  String? materialDocumentNo; //物料凭证编号
  String? materialVoucherYear; //物料凭证年度
  String? materialVoucherItem; //物料凭证项目
  String? quantity; //数量
  String? unit; //单位

  ReceiptVoucherInfo({
    this.materialDocumentNo,
    this.materialVoucherYear,
    this.materialVoucherItem,
    this.quantity,
    this.unit,
  });

  ReceiptVoucherInfo.fromJson(dynamic json) {
    materialDocumentNo = JsonParse.str(json['MBLNR']);
    materialVoucherYear = JsonParse.str(json['MJAHR']);
    materialVoucherItem = JsonParse.str(json['ZEILE']);
    quantity = JsonParse.str(json['MENGE']);
    unit = JsonParse.str(json['MEINS']);
  }
}
