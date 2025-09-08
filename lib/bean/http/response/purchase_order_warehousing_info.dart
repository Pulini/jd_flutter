//   "EINDT_QR": "",
//  [
//       "": "0000",//ETENR
//       "": "0199001",//MATNR
//       "": "2025-04-24",//EINDT_QR
//       "": "",//ZXT
//       "": "",//ZZBZ
//       "": "218",//W_WEMNG
//  ]

//{
//   "CompanyCode": "1000",
//   "FactoryNumber": "1098",
//   "FactoryDescription": "金帝贸易仓库",
//   "PurchaseOrderNumber": "",
//   "MaterialNo": "0199001",//SATNR
//   "MaterialName": "0.8mm厚废PU",//MAKTX_YB
//   "FactoryArea": "",//ZQY
//   "TypeBody": "XD13552-5A",//ZZXTNO
//   "SalesOrder": "M2200731",//VBELN
//   "Supplier": "0000500289",//LIFNR
//   "SupplierName": "浙江冠亚鞋业有限公司",//NAME1
//   "Unit": "千克",//MEINS
//   "IsScanPieces": "",
//   "IsNoCheck": "",
//   "CustomerPO": "",
//   "Type": "  1",
//   "Details": [//ZCGSLTZD_ITEM
//     {
//       "PurchaseOrder": "4510010321",//EBELN
//       "PurchaseOrderLineItem": "00010",//EBELP
//       "Remark": "",//ZREMARK
//       "Size": "0",//SIZE1
//       "OrderQty": "228",//MENGE
//       "ReceivedQty": "10",//WEMNG
//       "UnderNum": "0",
//       "IssuedDeliveryOrderNum": "228",
//       "UnqualifiedNum": "0",
//       "Location": "1001",
//       "LocationDescription": "面料仓",
//       "CustomerPO": "",
//       "TrackNo": "",
//       "ReceiptVoucher": [//GT_ITEMS
//         {
//           "MaterialDocumentNo": "5000014951",//MBLNR
//           "MaterialVoucherYear": "2025",//MJAHR
//           "MaterialVoucherItem": "0001",//ZEILE
//           "Quantity": "10.0",//MENGE
//           "Unit": "米"//MEINS
//         }
//       ]
//     }
//   ]
// }
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
    companyCode = json['CompanyCode'];
    factoryNumber = json['FactoryNumber'];
    factoryDescription = json['FactoryDescription'];
    purchaseOrderNumber = json['PurchaseOrderNumber'];
    materialCode = json['SATNR'];
    materialName = json['MAKTX_YB'];
    factoryArea = json['ZQY'];
    typeBody = json['ZZXTNO'];
    salesOrder = json['VBELN'];
    supplier = json['LIFNR'];
    supplierName = json['NAME1'];
    unit = json['MEINS'];
    isScanPieces = json['IsScanPieces'];
    isNoCheck = json['IsNoCheck'];
    customerPO = json['CustomerPO'];
    type = json['Type'];
    details = [];
    if (json['ZCGSLTZD_ITEM'] != null) {
      json['ZCGSLTZD_ITEM'].forEach((v) {
        details!.add(PurchaseOrderDetailsInfo.fromJson(v,unit??''));
      });
    }
  }

  bool isSelectAll() => details!.every((v) => v.isSelected.value);

  selectAll(bool select) {
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
    purchaseOrder = json['EBELN'];
    purchaseOrderLineItem = json['EBELP'];
    remark = json['ZREMARK'];
    size = json['SIZE1'];
    orderQty = json['MENGE'];
    receivedQty = json['WEMNG'];
    underNum = json['UnderNum'];
    issuedDeliveryOrderNum = json['IssuedDeliveryOrderNum'];
    unqualifiedNum = json['UnqualifiedNum'];
    location = json['Location'];
    locationDescription = json['LocationDescription'];
    customerPO = json['CustomerPO'];
    trackNo = json['TrackNo'];
    if (json['GT_ITEMS'] != null) {
      receiptVoucher = [];
      json['GT_ITEMS'].forEach((v) {
        receiptVoucher!.add(ReceiptVoucherInfo.fromJson(v));
      });
    }
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
    materialDocumentNo = json['MBLNR'];
    materialVoucherYear = json['MJAHR'];
    materialVoucherItem = json['ZEILE'];
    quantity = json['MENGE'];
    unit = json['MEINS'];
  }
}
