import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

class DeliveryOrderInfo {
  RxBool isSelected = false.obs;

  String? baseUnit; //基本单位
  String? billDate; //创建时间
  String? checkQuantity; //核查数
  String? inspector; //核查人
  String? coefficient; //系数
  String? commUnit; //常用单位
  String? companyCode; //公司代码
  String? deliNo; //送货单号
  String? finalCustomer; //最终客户kunnrLast
  String? deliveryLocation; //送货地点
  String? distributionType; //分配型体
  String? factoryNO; //工厂ID
  String? factoryName; //工厂名称~
  bool? isExempt; //,//免检
  String? isGenerate; //是否已生成暂收单
  bool? isPackingMaterials; //是否是包材类的工单(即入即出)
  String? materialCode; //物料编码
  String? materialName; //物料名称
  String? model; //型体
  String? numPage; //件数
  String? remark; //表头备注
  String? remarks; //备注
  String? supplierCode; //供应商编码
  String? supplierName; //供应商名称
  String? location; //存储地点ID
  String? locationName; //存储地点名称
  String? matchCode; //配码
  String? produceOrderNo; //scWorkcardNo
  String? isScanPieces; //是否需要绑定标签 'X' or ''
  String? isPiece; //启用键管理
  String? division; //事业部
  List<DeliveryOrderSizeInfo>? deliSize; //
  List<DeliveryOrderLineInfo>? deliSeqList; //
  List<DeliveryOrderBindingLabelInfo>? deliJbq; //

  DeliveryOrderInfo({
    this.baseUnit,
    this.billDate,
    this.checkQuantity,
    this.inspector,
    this.coefficient,
    this.commUnit,
    this.companyCode,
    this.deliNo,
    this.finalCustomer,
    this.deliveryLocation,
    this.distributionType,
    this.factoryNO,
    this.factoryName,
    this.isExempt,
    this.isGenerate,
    this.isPackingMaterials,
    this.materialCode,
    this.materialName,
    this.model,
    this.numPage,
    this.remark,
    this.remarks,
    this.supplierCode,
    this.supplierName,
    this.location,
    this.locationName,
    this.matchCode,
    this.produceOrderNo,
    this.isScanPieces,
    this.isPiece,
    this.division,
    this.deliSize,
    this.deliSeqList,
    this.deliJbq,
  });

  DeliveryOrderInfo.fromJson(dynamic json) {
    baseUnit = json['BaseUnit'];
    billDate = json['BillDate'];
    checkQuantity = json['CheckQuantity'];
    inspector = json['Inspector'];
    coefficient = json['Coefficient'];
    commUnit = json['CommUnit'];
    companyCode = json['CompanyCode'];
    deliNo = json['DeliNo'];
    finalCustomer = json['FinalCustomer'];
    deliveryLocation = json['DeliveryLocation'];
    distributionType = json['DistributionType'];
    factoryNO = json['FactoryNO'];
    factoryName = json['FactoryName'];
    isExempt = json['IsExempt'];
    isGenerate = json['IsGenerate'];
    isPackingMaterials = json['IsPackingMaterials'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
    model = json['Model'];
    numPage = json['NumPage'];
    remark = json['Remark'];
    remarks = json['Remarks'];
    supplierCode = json['SupplierCode'];
    supplierName = json['SupplierName'];
    location = json['Location'];
    locationName = json['LocationName'];
    matchCode = json['MatchCode'];
    produceOrderNo = json['ProduceOrderNo'];
    isScanPieces = json['IsScanPieces'];
    isPiece = json['IsPiece'];
    division = json['Division'];
    deliSize = [];
    if (json['DeliSize'] != null) {
      json['DeliSize'].forEach((v) {
        deliSize?.add(DeliveryOrderSizeInfo.fromJson(v));
      });
    }
    deliSeqList = [];
    if (json['DeliSeqList'] != null) {
      json['DeliSeqList'].forEach((v) {
        deliSeqList?.add(DeliveryOrderLineInfo.fromJson(v));
      });
    }
    deliJbq = [];
    if (json['DeliJbq'] != null) {
      json['DeliJbq'].forEach((v) {
        deliJbq?.add(DeliveryOrderBindingLabelInfo.fromJson(v));
      });
    }
  }

  bool isTemporarilyReceived() => isGenerate?.isNotEmpty == true;

  bool isInspected() => inspector?.isNotEmpty == true;

  bool hasSubscript() => isTemporarilyReceived() || isInspected();

  double deliveryQty() {
    var deliveryQty = 0.0;
    deliSize?.forEach((v){
      deliveryQty=deliveryQty.add(v.qty.toDoubleTry());
    });
    return deliveryQty;
  }
}

class DeliveryOrderSizeInfo {
  String? size; //尺码
  String? qty; //实发数量 常用数量
  String? baseQty; //基本数量

  DeliveryOrderSizeInfo({
    this.size,
    this.qty,
    this.baseQty,
  });

  DeliveryOrderSizeInfo.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    baseQty = json['BaseQty'];
  }
}

class DeliveryOrderLineInfo {
  String? deliSeq; //行号
  String? remarks; //备注
  String? verifyQty; //核查数量
  String? purchaseOrderNumber; // 合同编号ZEBELN
  String? purchaseDocumentItemNumber; // 采购单行号ZEBELP

  DeliveryOrderLineInfo({
    this.deliSeq,
    this.remarks,
    this.verifyQty,
    this.purchaseOrderNumber,
    this.purchaseDocumentItemNumber,
  });

  DeliveryOrderLineInfo.fromJson(dynamic json) {
    deliSeq = json['DeliSeq'];
    remarks = json['Remarks'];
    verifyQty = json['VerifyQty'];
    purchaseOrderNumber = json['PurchaseOrderNumber'];
    purchaseDocumentItemNumber = json['PurchaseDocumentItemNumber'];
  }
}

class DeliveryOrderBindingLabelInfo {
  String? pieceNo; //件号
  String? volume; //体积
  String? grossWeight; //毛重
  String? netWeight; //净重
  String? quantity; //数量

  DeliveryOrderBindingLabelInfo({
    this.pieceNo,
    this.volume,
    this.grossWeight,
    this.netWeight,
    this.quantity,
  });

  DeliveryOrderBindingLabelInfo.fromJson(dynamic json) {
    pieceNo = json['PieceNo'];
    volume = json['Ladevol'];
    grossWeight = json['Brgew'];
    netWeight = json['Ntgew'];
    quantity = json['Qty'];
  }
}
