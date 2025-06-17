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
  String? trackNo; //跟踪号
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
    this.trackNo,
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
    produceOrderNo = json['ScWorkcardNo'];
    isScanPieces = json['IsScanPieces'];
    isPiece = json['IsPiece'];
    division = json['Division'];
    trackNo = json['TrackNo'];
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
    deliSize?.forEach((v) {
      deliveryQty = deliveryQty.add(v.qty.toDoubleTry());
    });
    return deliveryQty;
  }

  double deliveryBaseQty() {
    var deliveryBaseQty = 0.0;
    deliSize?.forEach((v) {
      deliveryBaseQty = deliveryBaseQty.add(v.baseQty.toDoubleTry());
    });
    return deliveryBaseQty;
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

class DeliveryOrderDetailInfo {
  String? deliveryNumber; //运单编号ZDELINO
  String? contractNo; //合同编号ZEBELN
  String? salesAndDistributionVoucherNumber; //销售和分销凭证号ZVBELN
  String? planningLineNumber; //计划行编号ZETENR
  String? factoryType; //工厂型体ZZGCXT
  String? companyNumber; //工厂编号ZBUKRS
  String? supplierCode; //供应商编码ZLIFNR
  String? supplierName; //供应商NAME1
  String? orderType; //订单类型ZBSART
  String? buildOperationOpenID; //制单OpenID ZBILLOPENID
  String? builder; //制单人ZBILLER
  String? buildDate; //制单时间ZBILLDATE
  String? auditor; //审核人ZAUDITOR
  String? auditDate; //审核时间ZAUDITDATE
  String? modifyOperationOpenID; //修改人OpenID ZMODIFYOPENID
  String? modifier; //修改人ZMODIFIER
  String? modifyDate; //修改时间ZMODIFYDATE
  String? delete; //删除状态ZDELETE
  String? deleteOperationOpenID; //删除人OpenID ZDELETEOPENID
  String? deleter; //删除人ZDELETER
  String? deleteDate; //删除时间ZDELETEDATE
  String? remarks; //备注ZREMARK
  String? deliveryAddress; //删除人ZDELETER
  String? basicUnit; //基本单位ZBASEUNIT
  String? coefficient; //系数ZCOEFFICIENT
  String? commonUnits; //常用单位ZCOMMUNIT
  String? materialDocumentNo; //物料凭证编号MBLNR
  String? materialDocumentNumberReversal; //物料凭证编号冲销MBLNR_REV
  String? reasonsStockInWriteOff; //入库冲销原因MBLNR_REV_TXT
  List<DeliveryOrderDetailItemInfo>? deliveryDetailItem; //详情DELIDetailItem
  String? inspector; //核查人
  String? inspectDate; //核查日期
  String? inspectTime; //核查时间
  String? location; //存储位置编号ZLGORT
  String? locationName; //存储位置名字
  String? division; //事业部

  DeliveryOrderDetailInfo({
    required this.deliveryNumber,
    required this.contractNo,
    required this.salesAndDistributionVoucherNumber,
    required this.planningLineNumber,
    required this.factoryType,
    required this.companyNumber,
    required this.supplierCode,
    required this.supplierName,
    required this.orderType,
    required this.buildOperationOpenID,
    required this.builder,
    required this.buildDate,
    required this.auditor,
    required this.auditDate,
    required this.modifyOperationOpenID,
    required this.modifier,
    required this.modifyDate,
    required this.delete,
    required this.deleteOperationOpenID,
    required this.deleter,
    required this.deleteDate,
    required this.remarks,
    required this.deliveryAddress,
    required this.basicUnit,
    required this.coefficient,
    required this.commonUnits,
    required this.materialDocumentNo,
    required this.materialDocumentNumberReversal,
    required this.reasonsStockInWriteOff,
    required this.deliveryDetailItem,
    required this.inspector,
    required this.inspectDate,
    required this.inspectTime,
    required this.location,
    required this.locationName,
    required this.division,
  });

  factory DeliveryOrderDetailInfo.fromJson(dynamic json) {
    var data = DeliveryOrderDetailInfo(
      deliveryNumber: json['DeliveryNumber'],
      contractNo: json['ContractNo'],
      salesAndDistributionVoucherNumber:
          json['SalesAndDistributionVoucherNumber'],
      planningLineNumber: json['PlanningLineNumber'],
      factoryType: json['FactoryType'],
      companyNumber: json['CompanyNumber'],
      supplierCode: json['SupplierCode'],
      supplierName: json['SupplierName'],
      orderType: json['OrderType'],
      buildOperationOpenID: json['BuildOperationOpenID'],
      builder: json['Builder'],
      buildDate: json['BuildDate'],
      auditor: json['Auditor'],
      auditDate: json['AuditDate'],
      modifyOperationOpenID: json['ModifyOperationOpenID'],
      modifier: json['Modifier'],
      modifyDate: json['ModifyDate'],
      delete: json['Delete'],
      deleteOperationOpenID: json['DeleteOperationOpenID'],
      deleter: json['Deleter'],
      deleteDate: json['DeleteDate'],
      remarks: json['Remarks'],
      deliveryAddress: json['DeliveryAddress'],
      basicUnit: json['BasicUnit'],
      coefficient: json['Coefficient'],
      commonUnits: json['CommonUnits'],
      materialDocumentNo: json['MaterialDocumentNo'],
      materialDocumentNumberReversal: json['MaterialDocumentNumberReversal'],
      reasonsStockInWriteOff: json['ReasonsStockInWriteOff'],
      deliveryDetailItem: json['DeliveryDetailItem'] == null
          ? []
          : (json['DeliveryDetailItem'] as List)
              .map((i) => DeliveryOrderDetailItemInfo.fromJson(i))
              .toList(),
      inspector: json['Inspector'],
      inspectDate: json['InspectDate'],
      inspectTime: json['InspectTime'],
      location: json['Location'],
      locationName: json['LocationName'],
      division: json['Division'],
    );
    if (data.modifier?.isEmpty == true) {
      data.modifyDate = '';
    }
    if (data.inspector?.isEmpty == true) {
      data.deliveryDetailItem?.forEach((v) {
        v.checkQuantity = v.deliverySumQty;
      });
    }
    return data;
  }
}

class DeliveryOrderDetailItemInfo {
  List<DeliveryOrderDetailSizeInfo>? deliveryDetailSizeItem; //尺码列表
  double? deliverySumQty; //送货数量合计ZSUMDELIQTY
  double? shortQuantity; //短码数量ZSUMSHORTCQTY
  double? temporaryReceiveQuantity; //暂收数量ZTEMPREQTY
  double? qualifiedQuantity; //合格数量ZQUALIQTY
  double? unqualifiedQuantity; //不合格数量ZUNQUALIQTY
  double? storageQuantity; //入库数量ZINSTOCKQTY
  String? materialCode; //物料编号ZMATNR
  String? factoryType; //工厂型体ZZGCXT
  String? distributiveForm; //分配型体ZXT
  String? materialDescription; //物料描述ZMAKTX
  String? deliveryDate; //交货日期EEIND
  String? mainMaterialCode; //主要物料编码ZSATNR
  String? remarks1; //备注1ZREMARK1
  String? remarks2; //备注2ZREMARK2
  String? numPage; //分页ZNUMPAGE
  String? salesAndDistributionVoucherNumber; //指令单号
  String? pickingDepartment; //领料部门ARBPL
  double? checkQuantity; //核查数量
  String? deliveryOrderLineNumber; //送货单行号
  String? stockOutVoucher; //出库凭证OUTMBLNR
  String? stockOutWriteOffVoucher; //出库冲销凭证OUTMBLNR_REV
  String? reasonsStockOutWriteOff; //出库冲销原因OUTMBLNR_REV_TXT

  DeliveryOrderDetailItemInfo({
    required this.deliveryDetailSizeItem,
    required this.deliverySumQty,
    required this.shortQuantity,
    required this.temporaryReceiveQuantity,
    required this.qualifiedQuantity,
    required this.unqualifiedQuantity,
    required this.storageQuantity,
    required this.materialCode,
    required this.factoryType,
    required this.distributiveForm,
    required this.materialDescription,
    required this.deliveryDate,
    required this.mainMaterialCode,
    required this.remarks1,
    required this.remarks2,
    required this.numPage,
    required this.salesAndDistributionVoucherNumber,
    required this.pickingDepartment,
    required this.checkQuantity,
    required this.deliveryOrderLineNumber,
    required this.stockOutVoucher,
    required this.stockOutWriteOffVoucher,
    required this.reasonsStockOutWriteOff,
  });

  factory DeliveryOrderDetailItemInfo.fromJson(dynamic json) {
    return DeliveryOrderDetailItemInfo(
      deliveryDetailSizeItem: json['DeliveryDetailSizeItem'] == null
          ? []
          : (json['DeliveryDetailSizeItem'] as List)
              .map((i) => DeliveryOrderDetailSizeInfo.fromJson(i))
              .toList(),
      deliverySumQty: json['DeliverySumQty'],
      shortQuantity: json['ShortQuantity'],
      temporaryReceiveQuantity: json['TemporaryReceiveQuantity'],
      qualifiedQuantity: json['QualifiedQuantity'],
      unqualifiedQuantity: json['UnqualifiedQuantity'],
      storageQuantity: json['StorageQuantity'],
      materialCode: json['MaterialCode'],
      factoryType: json['FactoryType'],
      distributiveForm: json['DistributiveForm'],
      materialDescription: json['MaterialDescription'],
      deliveryDate: json['DeliveryDate'],
      mainMaterialCode: json['MainMaterialCode'],
      remarks1: json['Remarks1'],
      remarks2: json['Remarks2'],
      numPage: json['NumPage'],
      salesAndDistributionVoucherNumber:
          json['SalesAndDistributionVoucherNumber'],
      pickingDepartment: json['PickingDepartment'],
      checkQuantity: json['CheckQuantity'],
      deliveryOrderLineNumber: json['DeliveryOrderLineNumber'],
      stockOutVoucher: json['StockOutVoucher'],
      stockOutWriteOffVoucher: json['StockOutWriteOffVoucher'],
      reasonsStockOutWriteOff: json['ReasonsStockOutWriteOff'],
    );
  }

  bool _hasSize() =>
      deliveryDetailSizeItem?.every((v) => v.size?.isNotEmpty == true) == true;

  String size() {
    var size = '非尺码物料';
    if (_hasSize()) {
      size = deliveryDetailSizeItem!
          .map((v) => '<尺码：${v.size} / 数量：${v.qty}>')
          .join(' ');
    }
    return size;
  }
}

class DeliveryOrderDetailSizeInfo {
  String? size; //尺码
  String? qty; //暂收数量
  String? baseQty; //基本数量

  DeliveryOrderDetailSizeInfo({
    required this.size,
    required this.qty,
    required this.baseQty,
  });

  factory DeliveryOrderDetailSizeInfo.fromJson(dynamic json) {
    return DeliveryOrderDetailSizeInfo(
      size: json['Size'],
      qty: json['Qty'],
      baseQty: json['BaseQty'],
    );
  }
}

class ReversalLabelInfo {
  String? pieceNo; //件号-标签 ZPIECE_NO
  String? materialCode; //物料编号 MATNR
  String? materialName; //物料描述 ZMAKTX
  String? quantity; //装箱数量 ZXNUM
  String? unit; //单位 MEINS
  String? volume; //体积 LADEVOL
  String? grossWeight; //毛重  BRGEW
  String? netWeight; //净重  NTGEW

  ReversalLabelInfo({
    required this.pieceNo,
    required this.materialCode,
    required this.materialName,
    required this.quantity,
    required this.unit,
    required this.volume,
    required this.grossWeight,
    required this.netWeight,
  });

  factory ReversalLabelInfo.fromJson(dynamic json) {
    return ReversalLabelInfo(
      pieceNo: json['PIECE_NO'],
      materialCode: json['MATNR'],
      materialName: json['MAKTX'],
      quantity: json['ZXNUM'],
      unit: json['MEINS'],
      volume: json['LDEVOL'],
      grossWeight: json['BRGEW'],
      netWeight: json['NTGEW'],
    );
  }
}

class DeliveryOrderPieceInfo {
  String? pieceNo; //ZPICECE_NO  件号
  double? volume; //LDEVOL  体积
  double? grossWeight; //BRGEW  毛重
  double? netWeight; //NTGEW  净重
  String? date; //ZMADAT  生产日期
  String? materialCategory; //ZMATNRCAT  物料类别
  List<DeliveryOrderLabelInfo>? labelList; //GT_ITEMS  子项

  DeliveryOrderPieceInfo({
    required this.pieceNo,
    required this.volume,
    required this.grossWeight,
    required this.netWeight,
    required this.date,
    required this.materialCategory,
    required this.labelList,
  });

  factory DeliveryOrderPieceInfo.fromJson(dynamic json) {
    return DeliveryOrderPieceInfo(
      pieceNo: json['ZPIECE_NO'],
      volume: json['LADEVOL'],
      grossWeight: json['BRGEW'],
      netWeight: json['NTGEW'],
      date: json['ZMADAT'],
      materialCategory: json['ZMATNRCAT'],
      labelList: [
        if (json['GT_ITEMS'] != null)
          for (var item in json['GT_ITEMS'])
            DeliveryOrderLabelInfo.fromJson(item)
      ],
    );
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZPIECE_NO'] = pieceNo;
    map['LADEVOL'] = volume;
    map['BRGEW'] = grossWeight;
    map['NTGEW'] = netWeight;
    map['ZMATNRCAT'] = materialCategory;
    map['GT_ITEMS'] = labelList!.map((e) => e.toJson()).toList();
    return map;
  }
}

class DeliveryOrderLabelInfo {
  String? labelNumber; //BQID  标签id
  String? materialCode; //MATNR  物料编号
  String? materialName; //ZMAKTX  物料描述
  double? quantity; //ZXNUM  数量
  String? unit; //MEINS  单位

  DeliveryOrderLabelInfo({
    required this.labelNumber,
    required this.materialCode,
    required this.materialName,
    required this.quantity,
    required this.unit,
  });

  factory DeliveryOrderLabelInfo.fromJson(dynamic json) {
    return DeliveryOrderLabelInfo(
      labelNumber: json['BQID'],
      materialCode: json['MATNR'],
      materialName: json['ZMAKTX'],
      quantity: json['ZXNUM'],
      unit: json['MEINS'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'BQID': labelNumber,
      'MATNR': materialCode,
      'ZMAKTX': materialName,
      'ZXNUM': quantity,
      'MEINS': unit,
    };
  }
}
