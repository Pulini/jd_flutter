import 'package:get/get_rx/src/rx_types/rx_types.dart';

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
    this.orderType,   //订单类型（采购）BSART
    this.companyCode,    //公司代码BUKRS
    this.purchaseVoucherNo,   //采购凭证号EBELN
    this.purchaseDocumentItemNumber,    //采购凭证的项目编号EBELP
    this.planningLineNumber,    //计划行编号ETENR
    this.isColorSeparation,   //是否分色ISCOSEP
    this.isReturns,   //是否已退货ISRETURNS
    this.supplierNumber,    //供应商编号LIFNR
    this.materialDescription,  //物料描述MAKTX
    this.materialCode,   //物料编码MATNR
    this.materialDocumentNo,   //物料凭证编号MBLNR
    this.materialDocumentNumberReversal,  //物料凭证编号冲销MBLNR_REV
    this.materialVoucherYear,    //物料凭证年度MJAHR
    this.materialVoucherAnnualReversal,   //物料凭证年度冲销MJAHR_REV
    this.taxCode,    //税码MWSKZ
    this.name1,  //供应商名称
    this.characteristicValue,  //特性值（季节性采购）SIZE1
    this.salesAndDistributionVoucherNumber,  //销售和分销凭证号VBELN
    this.factoryNumber,  //工厂编号WERKS
    this.baseQuantity,  //基本数量ZBASEQTY
    this.basicUnit,  //基本单位ZBASEUNIT
    this.billDate, //制单日期ZBILLDATE
    this.tempreBillDate,  //暂收日期ZBILLDATE_TEMPRE
    this.biller,  //制单人ZBILLER
    this.billTime,  //制单时间ZBILLTIME
    this.inspectionOrderNo, //检验单号ZCHECKBNO
    this.inspectionLineNumber, //检验单行号检验单行号ZCHECKBSEQ
    this.inspectionMethod, //检验方式ZCHECKMETHOD
    this.inspectionQuantity, //检验数量ZCHECKQTY
    this.samplingRatio, //抽检比例ZCHECKSCALE
    this.coefficient, //系数ZCOEFFICIENT
    this.commonUnits, //常用单位ZCOMMUNIT
    this.deleteReason, //删除原因ZDELETETEXT
    this.deliAddress, //送货地点ZDELIADDRESS
    this.itemLineItem,  //物料行项目ZEILE
    this.materialVoucherItem,  //物料凭证项目(逗号隔开)ZEILES
    this.detailIDReversal,  //明细id冲销ZEILE_REV
    this.storageQuantity, //入库数量ZINSTOCKQTY
    this.location, //货位ZLOCAL
    this.location1,  //货位ZLOCAL1
    this.qualifiedQuantity, //合格数量ZQUALIQTY
    this.remarks, //备注ZREMARK
    this.remarks1,  //备注ZREMARK_D2
    this.samplingQuantity, //抽检数量ZSCALEQTY
    this.shortCodesNumber, //短码数量ZSHORTCQTY
    this.sourceOrderType,  //源单类型ZSOURCETYPE
    this.temporaryNo, //暂收单号ZTEMPRENO
    this.temporaryCollectionBankNo, //暂收单行号ZTEMPRESEQ
    this.unqualifiedQuantity,  //不合格数量ZUNQUALIQTY
    this.unqualifiedReason, //不合格原因ZUNQUALITEXT
    this.distributiveForm,  //分配型体ZXT
    this.fullCheckFlag, //全检标志位，需要全检时为'X'ZZFSFLG
    this.batchIdentification,  //批次物料flag，可以分色时为'X'XCHAR
    this.factoryType,  //工厂型体ZZGCXT
    this.isCodeRunningMaterial, //是否是跑码物料ZISCLRUN
    this.colorSeparation,  //是否分色
    this.isPiece,  //是否  X启用
    this.trackNo,  //跟踪号
    this.colorDistinguishEnable,  //是否需要分色扫码

  });

  StuffQualityInspectionInfo.fromJson(dynamic json) {
    orderType = json['OrderType'];
    companyCode = json['CompanyCode'];
    purchaseVoucherNo = json['PurchaseVoucherNo'];
    purchaseDocumentItemNumber = json['PurchaseDocumentItemNumber'];
    planningLineNumber = json['PlanningLineNumber'];
    isColorSeparation = json['IsColorSeparation'];
    isReturns = json['IsReturns'];
    supplierNumber = json['SupplierNumber'];
    materialDescription = json['MaterialDescription'];
    materialCode = json['MaterialCode'];
    materialDocumentNo = json['MaterialDocumentNo'];
    materialDocumentNumberReversal = json['MaterialDocumentNumberReversal'];
    materialVoucherYear = json['MaterialVoucherYear'];
    materialVoucherAnnualReversal = json['MaterialVoucherAnnualReversal'];
    taxCode = json['TaxCode'];
    name1 = json['Name1'];
    characteristicValue = json['CharacteristicValue'];
    salesAndDistributionVoucherNumber = json['SalesAndDistributionVoucherNumber'];
    factoryNumber = json['FactoryNumber'];
    baseQuantity = json['BaseQuantity'];
    basicUnit = json['BasicUnit'];
    billDate = json['BillDate'];
    tempreBillDate = json['TempreBillDate'];
    biller = json['Biller'];
    billTime = json['BillTime'];
    inspectionOrderNo = json['InspectionOrderNo'];
    inspectionLineNumber = json['InspectionLineNumber'];
    inspectionMethod = json['InspectionMethod'];
    inspectionQuantity = json['InspectionQuantity'];
    samplingRatio = json['SamplingRatio'];
    coefficient = json['Coefficient'];
    commonUnits = json['CommonUnits'];
    deleteReason = json['DeleteReason'];
    deliAddress = json['DeliAddress'];
    itemLineItem = json['ItemLineItem'];
    materialVoucherItem = json['MaterialVoucherItem'];
    detailIDReversal = json['DetailIDReversal'];
    storageQuantity = json['StorageQuantity'];
    location = json['Location'];
    location1 = json['Location1'];
    qualifiedQuantity = json['QualifiedQuantity'];
    remarks = json['Remarks'];
    remarks1 = json['Remarks1'];
    samplingQuantity = json['SamplingQuantity'];
    shortCodesNumber = json['ShortCodesNumber'];
    sourceOrderType = json['SourceOrderType'];
    temporaryNo = json['TemporaryNo'];
    temporaryCollectionBankNo = json['TemporaryCollectionBankNo'];
    unqualifiedQuantity = json['UnqualifiedQuantity'];
    unqualifiedReason = json['UnqualifiedReason'];
    distributiveForm = json['DistributiveForm'];
    fullCheckFlag = json['FullCheckFlag'];
    batchIdentification = json['BatchIdentification'];
    factoryType = json['FactoryType'];
    isCodeRunningMaterial = json['IsCodeRunningMaterial'];
    colorSeparation = json['ColorSeparation'];
    isPiece = json['IsPiece'];
    trackNo = json['TrackNo'];
    colorDistinguishEnable = json['ColorDistinguishEnable']=='X';
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
    map['SalesAndDistributionVoucherNumber'] = salesAndDistributionVoucherNumber;
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
    return map;
  }

  String getDataID()=>'${inspectionOrderNo}_$materialCode';

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
    this.stuffColorSeparationList,});

  StuffQualityInspectionDetailInfo.fromJson(dynamic json) {
    inspectionOrderNo = json['InspectionOrderNo'];
    inspectionLineNumber = json['InspectionLineNumber'];
    temporaryNo = json['TemporaryNo'];
    temporaryCollectionBankNo = json['TemporaryCollectionBankNo'];
    purchaseOrderNumber = json['PurchaseOrderNumber'];
    purchaseOrderLineItem = json['PurchaseOrderLineItem'];
    salesAndDistributionVoucherNumber = json['SalesAndDistributionVoucherNumber'];
    factoryType = json['FactoryType'];
    materialCode = json['MaterialCode'];
    materialDescription = json['MaterialDescription'];
    basicUnit = json['BasicUnit'];
    basicQuantity = json['BasicQuantity'];
    coefficient = json['Coefficient'];
    commonUnits = json['CommonUnits'];
    inspectionMethod = json['InspectionMethod'];
    samplingRatio = json['SamplingRatio'];
    inspectionQuantity = json['InspectionQuantity'];
    qualifiedQuantity = json['QualifiedQuantity'];
    unqualifiedQuantity = json['UnqualifiedQuantity'];
    shortCodesNumber = json['ShortCodesNumber'];
    storageQuantity = json['StorageQuantity'];
    remarks = json['Remarks'];
    location = json['Location'];
    if (json['UnqualifiedList'] != null) {
      unqualifiedList = [];
      json['UnqualifiedList'].forEach((v) {
        unqualifiedList?.add(UnqualifiedList.fromJson(v));
      });
    }
    if (json['ColorSeparationList'] != null) {
      stuffColorSeparationList = [];
      json['ColorSeparationList'].forEach((v) {
        stuffColorSeparationList?.add(StuffColorSeparationList.fromJson(v));
      });
    }
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
    map['SalesAndDistributionVoucherNumber'] = salesAndDistributionVoucherNumber;
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
      map['ColorSeparationList'] = stuffColorSeparationList?.map((v) => v.toJson()).toList();
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
    this.materialDescription,});

  StuffColorSeparationList.fromJson(dynamic json) {
    factory = json['Factory'];
    inspectionOrderNo = json['InspectionOrderNo'];
    inspectionLineNumber = json['InspectionLineNumber'];
    colorSeparationSheetNumber = json['ColorSeparationSheetNumber'];
    colorSeparationSingleLineNumber = json['ColorSeparationSingleLineNumber'];
    batch = json['Batch'];
    colorSeparationQuantity = json['ColorSeparationQuantity'];
    location = json['Location'];
    materialCode = json['MaterialCode'];
    materialDescription = json['MaterialDescription'];
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
    inspectionLineNumber = json['InspectionLineNumber'];
    unqualifiedNumber = json['UnqualifiedNumber'];
    unqualifiedLineNumber = json['UnqualifiedLineNumber'];
    unqualifiedReason = json['UnqualifiedReason'];

  }
  String? inspectionLineNumber;   // 检验单行号ZCHECKBSEQ
  String? unqualifiedNumber;  // 不合格编号ZUNQUALINO
  String? unqualifiedLineNumber;  // 不合格编号ZUNQUALINO
  String? unqualifiedReason;  // 不合格原因ZUNQUALITEXT


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


  String? subItem;  //是否合计栏
  String? name;  //物料名称
  String? code;  //物料编码
  String? color;  //色系
  double? qty;  //数量
  double? allQty;  //数量
  RxBool isSelected = false.obs;

}