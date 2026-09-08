import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/utils/extension_util.dart';

/// OrderType : "Z001"
/// CompanyCode : "1000"
/// PurchaseVoucherNo : "4501200655"
/// PurchaseDocumentItemNumber : "00020"
/// PlanningLineNumber : "0010"
/// IsColorSeparation : ""
/// IsReturns : ""
/// SupplierNumber : "0000100760"
/// MaterialDescription : "0.22mm*1.5m白色JY28可特（针织布/100%涤纶）"
/// MaterialCode : "021800294"
/// MaterialDocumentNo : ""
/// MaterialDocumentNumberReversal : ""
/// MaterialVoucherYear : "0000"
/// MaterialVoucherAnnualReversal : "0000"
/// TaxCode : "J2"
/// Name1 : "晋江市三洋鞋材贸易有限公司"
/// CharacteristicValue : ""
/// SalesAndDistributionVoucherNumber : ""
/// FactoryNumber : "1001"
/// BaseQuantity : "369.447"
/// BasicUnit : "M"
/// BillDate : "2025-05-30"
/// TempreBillDate : "2025-05-29"
/// Biller : "650809"
/// BillTime : "16:18:41"
/// InspectionOrderNo : "330000498192"
/// InspectionLineNumber : "00003"
/// InspectionMethod : "全检"
/// InspectionQuantity : "27.778"
/// SamplingRatio : "0.0"
/// Coefficient : "13.3"
/// CommonUnits : "KG"
/// DeleteReason : ""
/// DeliAddress : "金旭"
/// ItemLineItem : "0000"
/// MaterialVoucherItem : ""
/// DetailIDReversal : "0000"
/// StorageQuantity : "0.0"
/// Location : ""
/// Location1 : ""
/// QualifiedQuantity : "27.778"
/// Remarks : "50kg"
/// Remarks1 : ""
/// SamplingQuantity : "27.778"
/// ShortCodesNumber : "0.0"
/// SourceOrderType : "送货单"
/// TemporaryNo : "320000492955"
/// TemporaryCollectionBankNo : "00030"
/// UnqualifiedQuantity : "0.0"
/// UnqualifiedReason : ""
/// DistributiveForm : "PDS25400367-02"
/// FullCheckFlag : ""
/// BatchIdentification : ""
/// FactoryType : ""
/// IsSelect : false
/// IsCodeRunningMaterial : ""
/// ColorSeparation : ""
/// IsPiece : ""
/// TrackNo : ""

class StuffQualityInspectionInfo {
  StuffQualityInspectionInfo({
    this.orderType, //订单类型（采购）BSART
    this.companyCode, //公司代码BUKRS
    this.purchaseVoucherNo, //采购凭证号EBELN
    this.purchaseDocumentItemNumber, //采购凭证的项目编号EBELP
    this.planningLineNumber, //计划行编号ETENR
    this.isColorSeparation, //是否分色ISCOSEP
    this.isReturns, //是否已退货ISRETURNS
    this.supplierNumber, //供应商编号LIFNR
    this.materialDescription, //物料描述MAKTX
    this.materialCode, //物料编码MATNR
    this.materialDocumentNo, //物料凭证编号MBLNR
    this.materialDocumentNumberReversal, //物料凭证编号冲销MBLNR_REV
    this.materialVoucherYear, //物料凭证年度MJAHR
    this.materialVoucherAnnualReversal, //物料凭证年度冲销MJAHR_REV
    this.taxCode, //税码MWSKZ
    this.name1, //供应商名称
    this.characteristicValue, //特性值（季节性采购）SIZE1
    this.salesAndDistributionVoucherNumber, //销售和分销凭证号VBELN
    this.factoryNumber, //工厂编号WERKS
    this.baseQuantity, //基本数量ZBASEQTY
    this.basicUnit, //基本单位ZBASEUNIT
    this.billDate, //制单日期ZBILLDATE
    this.tempreBillDate, //暂收日期ZBILLDATE_TEMPRE
    this.biller, //制单人ZBILLER
    this.billTime, //制单时间ZBILLTIME
    this.inspectionOrderNo, //检验单号ZCHECKBNO
    this.inspectionLineNumber, //检验单行号检验单行号ZCHECKBSEQ
    this.inspectionMethod, //检验方式ZCHECKMETHOD
    this.inspectionQuantity, //检验数量ZCHECKQTY
    this.samplingRatio, //抽检比例ZCHECKSCALE
    this.coefficient, //系数ZCOEFFICIENT
    this.commonUnits, //常用单位ZCOMMUNIT
    this.deleteReason, //删除原因ZDELETETEXT
    this.deliAddress, //送货地点ZDELIADDRESS
    this.itemLineItem, //物料行项目ZEILE
    this.materialVoucherItem, //物料凭证项目(逗号隔开)ZEILES
    this.detailIDReversal, //明细id冲销ZEILE_REV
    this.storageQuantity, //入库数量ZINSTOCKQTY
    this.location, //货位ZLOCAL
    this.location1, //货位ZLOCAL1
    this.qualifiedQuantity, //合格数量ZQUALIQTY
    this.remarks, //备注ZREMARK
    this.remarks1, //备注ZREMARK_D2
    this.samplingQuantity, //抽检数量ZSCALEQTY
    this.shortCodesNumber, //短码数量ZSHORTCQTY
    this.sourceOrderType, //源单类型ZSOURCETYPE
    this.temporaryNo, //暂收单号ZTEMPRENO
    this.temporaryCollectionBankNo, //暂收单行号ZTEMPRESEQ
    this.unqualifiedQuantity, //不合格数量ZUNQUALIQTY
    this.unqualifiedReason, //不合格原因ZUNQUALITEXT
    this.distributiveForm, //分配型体ZXT
    this.fullCheckFlag, //全检标志位，需要全检时为'X'ZZFSFLG
    this.batchIdentification, //批次物料flag，可以分色时为'X'XCHAR
    this.factoryType, //工厂型体ZZGCXT
    this.isCodeRunningMaterial, //是否是跑码物料ZISCLRUN
    this.colorSeparation, //是否分色
    this.isPiece, //是否  X启用
    this.trackNo, //跟踪号
    this.colorDistinguishEnable, //是否需要分色扫码
    this.barCode, //标签

  });

  StuffQualityInspectionInfo.fromJson(dynamic json) {
    orderType = JsonParse.str(json['OrderType']);
    companyCode = JsonParse.str(json['CompanyCode']);
    purchaseVoucherNo = JsonParse.str(json['PurchaseVoucherNo']);
    purchaseDocumentItemNumber = JsonParse.str(json['PurchaseDocumentItemNumber']);
    planningLineNumber = JsonParse.str(json['PlanningLineNumber']);
    isColorSeparation = JsonParse.str(json['IsColorSeparation']);
    isReturns = JsonParse.str(json['IsReturns']);
    supplierNumber = JsonParse.str(json['SupplierNumber']);
    materialDescription = JsonParse.str(json['MaterialDescription']);
    materialCode = JsonParse.str(json['MaterialCode']);
    materialDocumentNo = JsonParse.str(json['MaterialDocumentNo']);
    materialDocumentNumberReversal = JsonParse.str(json['MaterialDocumentNumberReversal']);
    materialVoucherYear = JsonParse.str(json['MaterialVoucherYear']);
    materialVoucherAnnualReversal = JsonParse.str(json['MaterialVoucherAnnualReversal']);
    taxCode = JsonParse.str(json['TaxCode']);
    name1 = JsonParse.str(json['Name1']);
    characteristicValue = JsonParse.str(json['CharacteristicValue']);
    salesAndDistributionVoucherNumber =
        json['SalesAndDistributionVoucherNumber'];
    factoryNumber = JsonParse.str(json['FactoryNumber']);
    baseQuantity = JsonParse.str(json['BaseQuantity']);
    basicUnit = JsonParse.str(json['BasicUnit']);
    billDate = JsonParse.str(json['BillDate']);
    tempreBillDate = JsonParse.str(json['TempreBillDate']);
    biller = JsonParse.str(json['Biller']);
    billTime = JsonParse.str(json['BillTime']);
    inspectionOrderNo = JsonParse.str(json['InspectionOrderNo']);
    inspectionLineNumber = JsonParse.str(json['InspectionLineNumber']);
    inspectionMethod = JsonParse.str(json['InspectionMethod']);
    inspectionQuantity = JsonParse.str(json['InspectionQuantity']);
    samplingRatio = JsonParse.str(json['SamplingRatio']);
    coefficient = JsonParse.str(json['Coefficient']);
    commonUnits = JsonParse.str(json['CommonUnits']);
    deleteReason = JsonParse.str(json['DeleteReason']);
    deliAddress = JsonParse.str(json['DeliAddress']);
    itemLineItem = JsonParse.str(json['ItemLineItem']);
    materialVoucherItem = JsonParse.str(json['MaterialVoucherItem']);
    detailIDReversal = JsonParse.str(json['DetailIDReversal']);
    storageQuantity = JsonParse.str(json['StorageQuantity']);
    location = JsonParse.str(json['Location']);
    location1 = JsonParse.str(json['Location1']);
    qualifiedQuantity = JsonParse.str(json['QualifiedQuantity']);
    remarks = JsonParse.str(json['Remarks']);
    remarks1 = JsonParse.str(json['Remarks1']);
    samplingQuantity = JsonParse.str(json['SamplingQuantity']);
    shortCodesNumber = JsonParse.str(json['ShortCodesNumber']);
    sourceOrderType = JsonParse.str(json['SourceOrderType']);
    temporaryNo = JsonParse.str(json['TemporaryNo']);
    temporaryCollectionBankNo = JsonParse.str(json['TemporaryCollectionBankNo']);
    unqualifiedQuantity = JsonParse.str(json['UnqualifiedQuantity']);
    unqualifiedReason = JsonParse.str(json['UnqualifiedReason']);
    distributiveForm = JsonParse.str(json['DistributiveForm']);
    fullCheckFlag = JsonParse.str(json['FullCheckFlag']);
    batchIdentification = JsonParse.str(json['BatchIdentification']);
    factoryType = JsonParse.str(json['FactoryType']);
    isCodeRunningMaterial = JsonParse.str(json['IsCodeRunningMaterial']);
    colorSeparation = JsonParse.str(json['ColorSeparation']);
    isPiece = JsonParse.str(json['IsPiece']);
    trackNo = JsonParse.str(json['TrackNo']);
    colorDistinguishEnable = json['ColorDistinguishEnable'] == 'X';
    barCode = JsonParse.str(json['BQID_Org']);
  }

  String? orderType;
  String? companyCode;
  String? purchaseVoucherNo;
  String? purchaseDocumentItemNumber;
  String? planningLineNumber;
  String? isColorSeparation;
  String? isReturns;
  String? supplierNumber;
  String? materialDescription;
  String? materialCode;
  String? materialDocumentNo;
  String? materialDocumentNumberReversal;
  String? materialVoucherYear;
  String? materialVoucherAnnualReversal;
  String? taxCode;
  String? name1;
  String? characteristicValue;
  String? salesAndDistributionVoucherNumber;
  String? factoryNumber;
  String? baseQuantity;
  String? basicUnit;
  String? billDate;
  String? tempreBillDate;
  String? biller;
  String? billTime;
  String? inspectionOrderNo;
  String? inspectionLineNumber;
  String? inspectionMethod;
  String? inspectionQuantity;
  String? samplingRatio;
  String? coefficient;
  String? commonUnits;
  String? deleteReason;
  String? deliAddress;
  String? itemLineItem;
  String? materialVoucherItem;
  String? detailIDReversal;
  String? storageQuantity;
  String? location;
  String? location1;
  String? qualifiedQuantity;
  String? remarks;
  String? remarks1;
  String? samplingQuantity;
  String? shortCodesNumber;
  String? sourceOrderType;
  String? temporaryNo;
  String? temporaryCollectionBankNo;
  String? unqualifiedQuantity;
  String? unqualifiedReason;
  String? distributiveForm;
  String? fullCheckFlag;
  String? batchIdentification;
  String? factoryType;
  String? isCodeRunningMaterial;
  String? colorSeparation;
  String? isPiece;
  String? trackNo;
  bool? colorDistinguishEnable;
  RxBool isSelected = false.obs;
  String? barCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['OrderType'] = orderType;
    map['CompanyCode'] = companyCode;
    map['PurchaseVoucherNo'] = purchaseVoucherNo;
    map['PurchaseDocumentItemNumber'] = purchaseDocumentItemNumber;
    map['PlanningLineNumber'] = planningLineNumber;
    map['IsColorSeparation'] = isColorSeparation;
    map['IsReturns'] = isReturns;
    map['SupplierNumber'] = supplierNumber;
    map['MaterialDescription'] = materialDescription;
    map['MaterialCode'] = materialCode;
    map['MaterialDocumentNo'] = materialDocumentNo;
    map['MaterialDocumentNumberReversal'] = materialDocumentNumberReversal;
    map['MaterialVoucherYear'] = materialVoucherYear;
    map['MaterialVoucherAnnualReversal'] = materialVoucherAnnualReversal;
    map['TaxCode'] = taxCode;
    map['Name1'] = name1;
    map['CharacteristicValue'] = characteristicValue;
    map['SalesAndDistributionVoucherNumber'] =
        salesAndDistributionVoucherNumber;
    map['FactoryNumber'] = factoryNumber;
    map['BaseQuantity'] = baseQuantity;
    map['BasicUnit'] = basicUnit;
    map['BillDate'] = billDate;
    map['TempreBillDate'] = tempreBillDate;
    map['Biller'] = biller;
    map['BillTime'] = billTime;
    map['InspectionOrderNo'] = inspectionOrderNo;
    map['InspectionLineNumber'] = inspectionLineNumber;
    map['InspectionMethod'] = inspectionMethod;
    map['InspectionQuantity'] = inspectionQuantity;
    map['SamplingRatio'] = samplingRatio;
    map['Coefficient'] = coefficient;
    map['CommonUnits'] = commonUnits;
    map['DeleteReason'] = deleteReason;
    map['DeliAddress'] = deliAddress;
    map['ItemLineItem'] = itemLineItem;
    map['MaterialVoucherItem'] = materialVoucherItem;
    map['DetailIDReversal'] = detailIDReversal;
    map['StorageQuantity'] = storageQuantity;
    map['Location'] = location;
    map['Location1'] = location1;
    map['QualifiedQuantity'] = qualifiedQuantity;
    map['Remarks'] = remarks;
    map['Remarks1'] = remarks1;
    map['SamplingQuantity'] = samplingQuantity;
    map['ShortCodesNumber'] = shortCodesNumber;
    map['SourceOrderType'] = sourceOrderType;
    map['TemporaryNo'] = temporaryNo;
    map['TemporaryCollectionBankNo'] = temporaryCollectionBankNo;
    map['UnqualifiedQuantity'] = unqualifiedQuantity;
    map['UnqualifiedReason'] = unqualifiedReason;
    map['DistributiveForm'] = distributiveForm;
    map['FullCheckFlag'] = fullCheckFlag;
    map['BatchIdentification'] = batchIdentification;
    map['FactoryType'] = factoryType;
    map['IsCodeRunningMaterial'] = isCodeRunningMaterial;
    map['ColorSeparation'] = colorSeparation;
    map['IsPiece'] = isPiece;
    map['TrackNo'] = trackNo;
    map['ColorDistinguishEnable'] = colorDistinguishEnable;
    map['BQID_Org'] = barCode;
    return map;
  }

  String getDataID() => '${inspectionOrderNo}_$materialCode';
}

class StuffQualityInspectionDetailInfo {
  StuffQualityInspectionDetailInfo({
    this.inspectionOrderNo,
    this.inspectionLineNumber,
    this.temporaryNo,
    this.temporaryCollectionBankNo,
    this.purchaseOrderNumber,
    this.purchaseOrderLineItem,
    this.salesAndDistributionVoucherNumber,
    this.factoryType,
    this.materialCode,
    this.materialDescription,
    this.basicUnit,
    this.basicQuantity,
    this.coefficient,
    this.commonUnits,
    this.inspectionMethod,
    this.samplingRatio,
    this.inspectionQuantity,
    this.qualifiedQuantity,
    this.unqualifiedQuantity,
    this.shortCodesNumber,
    this.storageQuantity,
    this.remarks,
    this.location,
    this.unqualifiedList,
    this.stuffColorSeparationList,
  });

  StuffQualityInspectionDetailInfo.fromJson(dynamic json) {
    inspectionOrderNo = JsonParse.str(json['InspectionOrderNo']);
    inspectionLineNumber = JsonParse.str(json['InspectionLineNumber']);
    temporaryNo = JsonParse.str(json['TemporaryNo']);
    temporaryCollectionBankNo = JsonParse.str(json['TemporaryCollectionBankNo']);
    purchaseOrderNumber = JsonParse.str(json['PurchaseOrderNumber']);
    purchaseOrderLineItem = JsonParse.str(json['PurchaseOrderLineItem']);
    salesAndDistributionVoucherNumber =
        json['SalesAndDistributionVoucherNumber'];
    factoryType = JsonParse.str(json['FactoryType']);
    materialCode = JsonParse.str(json['MaterialCode']);
    materialDescription = JsonParse.str(json['MaterialDescription']);
    basicUnit = JsonParse.str(json['BasicUnit']);
    basicQuantity = JsonParse.str(json['BasicQuantity']);
    coefficient = JsonParse.str(json['Coefficient']);
    commonUnits = JsonParse.str(json['CommonUnits']);
    inspectionMethod = JsonParse.str(json['InspectionMethod']);
    samplingRatio = JsonParse.str(json['SamplingRatio']);
    inspectionQuantity = JsonParse.str(json['InspectionQuantity']);
    qualifiedQuantity = JsonParse.str(json['QualifiedQuantity']);
    unqualifiedQuantity = JsonParse.str(json['UnqualifiedQuantity']);
    shortCodesNumber = JsonParse.str(json['ShortCodesNumber']);
    storageQuantity = JsonParse.str(json['StorageQuantity']);
    remarks = JsonParse.str(json['Remarks']);
    location = JsonParse.str(json['Location']);
    unqualifiedList = JsonParse.list(json['UnqualifiedList'], UnqualifiedList.fromJson);
    stuffColorSeparationList = JsonParse.list(json['ColorSeparationList'], StuffColorSeparationList.fromJson);
  }

  String? inspectionOrderNo;
  String? inspectionLineNumber;
  String? temporaryNo;
  String? temporaryCollectionBankNo;
  String? purchaseOrderNumber;
  String? purchaseOrderLineItem;
  String? salesAndDistributionVoucherNumber;
  String? factoryType;
  String? materialCode;
  String? materialDescription;
  String? basicUnit;
  String? basicQuantity;
  String? coefficient;
  String? commonUnits;
  String? inspectionMethod;
  String? samplingRatio;
  String? inspectionQuantity;
  String? qualifiedQuantity;
  String? unqualifiedQuantity;
  String? shortCodesNumber;
  String? storageQuantity;
  String? remarks;
  String? location;
  List<UnqualifiedList>? unqualifiedList;
  List<StuffColorSeparationList>? stuffColorSeparationList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InspectionOrderNo'] = inspectionOrderNo;
    map['InspectionLineNumber'] = inspectionLineNumber;
    map['TemporaryNo'] = temporaryNo;
    map['TemporaryCollectionBankNo'] = temporaryCollectionBankNo;
    map['PurchaseOrderNumber'] = purchaseOrderNumber;
    map['PurchaseOrderLineItem'] = purchaseOrderLineItem;
    map['SalesAndDistributionVoucherNumber'] =
        salesAndDistributionVoucherNumber;
    map['FactoryType'] = factoryType;
    map['MaterialCode'] = materialCode;
    map['MaterialDescription'] = materialDescription;
    map['BasicUnit'] = basicUnit;
    map['BasicQuantity'] = basicQuantity;
    map['Coefficient'] = coefficient;
    map['CommonUnits'] = commonUnits;
    map['InspectionMethod'] = inspectionMethod;
    map['SamplingRatio'] = samplingRatio;
    map['InspectionQuantity'] = inspectionQuantity;
    map['QualifiedQuantity'] = qualifiedQuantity;
    map['UnqualifiedQuantity'] = unqualifiedQuantity;
    map['ShortCodesNumber'] = shortCodesNumber;
    map['StorageQuantity'] = storageQuantity;
    map['Remarks'] = remarks;
    map['Location'] = location;
    if (unqualifiedList != null) {
      map['UnqualifiedList'] = unqualifiedList?.map((v) => v.toJson()).toList();
    }
    if (stuffColorSeparationList != null) {
      map['ColorSeparationList'] =
          stuffColorSeparationList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// Factory : "1000"
/// InspectionOrderNo : "330000494762"
/// InspectionLineNumber : "00016"
/// ColorSeparationSheetNumber : "100000052818"
/// ColorSeparationSingleLineNumber : "00001"
/// Batch : "20250521C1"
/// ColorSeparationQuantity : "226.000"
/// Location : ""
/// MaterialCode : "02280102229"
/// MaterialDescription : "180g*1.37m灰褐色5微弹超纤（麂皮绒）"

class StuffColorSeparationList {
  StuffColorSeparationList({
    this.factory,
    this.inspectionOrderNo,
    this.inspectionLineNumber,
    this.colorSeparationSheetNumber,
    this.colorSeparationSingleLineNumber,
    this.batch,
    this.colorSeparationQuantity,
    this.location,
    this.materialCode,
    this.materialDescription,
  });

  StuffColorSeparationList.fromJson(dynamic json) {
    factory = JsonParse.str(json['Factory']);
    inspectionOrderNo = JsonParse.str(json['InspectionOrderNo']);
    inspectionLineNumber = JsonParse.str(json['InspectionLineNumber']);
    colorSeparationSheetNumber = JsonParse.str(json['ColorSeparationSheetNumber']);
    colorSeparationSingleLineNumber = JsonParse.str(json['ColorSeparationSingleLineNumber']);
    batch = JsonParse.str(json['Batch']);
    colorSeparationQuantity = JsonParse.str(json['ColorSeparationQuantity']);
    location = JsonParse.str(json['Location']);
    materialCode = JsonParse.str(json['MaterialCode']);
    materialDescription = JsonParse.str(json['MaterialDescription']);
  }

  String? factory;
  String? inspectionOrderNo;
  String? inspectionLineNumber;
  String? colorSeparationSheetNumber;
  String? colorSeparationSingleLineNumber;
  String? batch;
  String? colorSeparationQuantity;
  String? location;
  String? materialCode;
  String? materialDescription;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Factory'] = factory;
    map['InspectionOrderNo'] = inspectionOrderNo;
    map['InspectionLineNumber'] = inspectionLineNumber;
    map['ColorSeparationSheetNumber'] = colorSeparationSheetNumber;
    map['ColorSeparationSingleLineNumber'] = colorSeparationSingleLineNumber;
    map['Batch'] = batch;
    map['ColorSeparationQuantity'] = colorSeparationQuantity;
    map['Location'] = location;
    map['MaterialCode'] = materialCode;
    map['MaterialDescription'] = materialDescription;
    return map;
  }
}

class UnqualifiedList {
  UnqualifiedList({
    this.inspectionLineNumber,
    this.unqualifiedNumber,
    this.unqualifiedLineNumber,
    this.unqualifiedReason,
  });

  UnqualifiedList.fromJson(dynamic json) {
    inspectionLineNumber = JsonParse.str(json['InspectionLineNumber']);
    unqualifiedNumber = JsonParse.str(json['UnqualifiedNumber']);
    unqualifiedLineNumber = JsonParse.str(json['UnqualifiedLineNumber']);
    unqualifiedReason = JsonParse.str(json['UnqualifiedReason']);
  }

  String? inspectionLineNumber; // 检验单行号ZCHECKBSEQ
  String? unqualifiedNumber; // 不合格编号ZUNQUALINO
  String? unqualifiedLineNumber; // 不合格编号ZUNQUALINO
  String? unqualifiedReason; // 不合格原因ZUNQUALITEXT

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InspectionLineNumber'] = inspectionLineNumber;
    map['UnqualifiedNumber'] = unqualifiedNumber;
    map['UnqualifiedLineNumber'] = unqualifiedLineNumber;
    map['UnqualifiedReason'] = unqualifiedReason;
    return map;
  }
}

class QualityInspectionShowColor {
  QualityInspectionShowColor({
    this.subItem,
    this.name,
    this.code,
    this.color,
    this.qty,
    this.allQty,
  });

  String? subItem; //是否合计栏
  String? name; //物料名称
  String? code; //物料编码
  String? color; //色系
  double? qty; //数量
  double? allQty; //数量
  RxBool isSelected = false.obs;
}

class QualityInspectionColorInfo {
  String? inspectionOrderNo; //检验单号ZCHECKBNO
  String? materialCode; //物料编码MATNR
  String? batchNo; //批次号  CHARG
  double? qty; //数量 ZCOSEPQTY
  String? unit; //单位  ZCOMMUNIT

  var bindingLabels = <QualityInspectionLabelBindingInfo>[].obs;

  QualityInspectionColorInfo({
    this.inspectionOrderNo,
    this.materialCode,
    this.batchNo,
    this.qty,
    this.unit,
  });

  QualityInspectionColorInfo.fromJson(dynamic json) {
    inspectionOrderNo = JsonParse.str(json['ZCHECKBNO']);
    materialCode = JsonParse.str(json['MATNR']);
    batchNo = JsonParse.str(json['CHARG']);
    qty = json['ZCOSEPQTY'].toString().toDoubleTry();
    unit = JsonParse.str(json['ZCOMMUNIT']);
  }

  double getMaterialTotalQty() =>bindingLabels.isEmpty?0:bindingLabels.map((v)=>v.commonQty).reduce((a,b)=>a.add(b));
}

class QualityInspectionLabelInfo {
  String? labelID; //标签ID BQID
  String? pieceNo; //	件号  ZPIECE_NO
  String? orderNo; //工单号  ZDELINO
  List<QualityInspectionLabelMaterialInfo>? materialList; //	物料列表 GT_ITEM2

  QualityInspectionLabelInfo({
    this.labelID,
    this.pieceNo,
    this.orderNo,
    this.materialList,
  });

  QualityInspectionLabelInfo.fromJson(dynamic json) {
    labelID = JsonParse.str(json['BQID']);
    pieceNo = JsonParse.str(json['ZPIECE_NO']);
    orderNo = JsonParse.str(json['ZDELINO']);
    materialList = [
      if (json['GT_ITEM2'] != null)
        for (var item in json['GT_ITEM2'])
          QualityInspectionLabelMaterialInfo.fromJson(item)
    ];
  }

}

class QualityInspectionLabelMaterialInfo {
  String? labelID; //标签ID BQID
  String? materialNumber; //物料编号  MATNR
  String? materialName; //物料名称 ZMAKTX
  double? baseQty; //MENGE  基本数量
  String? baseUnit; //MEINS  基本单位
  double? commonQty; //ERFMG  常用数量
  String? commonUnit; //ERFME  常用单位
  QualityInspectionLabelMaterialInfo({
    this.labelID,
    this.materialNumber,
    this.materialName,
    this.baseQty,
    this.baseUnit,
    this.commonQty,
    this.commonUnit,
  });

  QualityInspectionLabelMaterialInfo.fromJson(dynamic json) {
    labelID = JsonParse.str(json['BQID']);
    materialNumber = JsonParse.str(json['MATNR']);
    materialName = JsonParse.str(json['ZMAKTX']);
    baseQty = json['MENGE'].toString().toDoubleTry();
    baseUnit = JsonParse.str(json['MEINS']);
    commonQty = json['ERFMG'].toString().toDoubleTry();
    commonUnit = JsonParse.str(json['ERFME']);
  }
  String dataId()=>'$labelID$materialNumber';
}

class QualityInspectionLabelBindingInfo {
  RxBool isScanned=false.obs;
  String pieceNo; //	件号  ZPIECE_NO
  String labelID; //标签ID BQID
  String materialNumber; //物料编号  MATNR
  String materialName; //物料名称 ZMAKTX
  double commonQty; //ERFMG  常用数量
  String commonUnit; //ERFME  常用单位
  QualityInspectionLabelBindingInfo({
    required this.pieceNo,
    required this.labelID,
    required this.materialNumber,
    required this.materialName,
    required this.commonQty,
    required this.commonUnit,
  });

  String dataId()=>'$labelID$materialNumber';
  String getMaterial()=>'($materialNumber)$materialName';
}
