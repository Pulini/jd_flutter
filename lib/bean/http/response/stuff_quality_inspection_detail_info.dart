/// InspectionOrderNo : "330000494762"
/// InspectionLineNumber : "00001"
/// TemporaryNo : "320000488347"
/// TemporaryCollectionBankNo : "00010"
/// PurchaseOrderNumber : "4501124928"
/// PurchaseOrderLineItem : "00020"
/// SalesAndDistributionVoucherNumber : "J2424997"
/// FactoryType : "DX13552-56A"
/// MaterialCode : "02280102229"
/// MaterialDescription : "180g*1.37m灰褐色5微弹超纤（麂皮绒）"
/// BasicUnit : "M"
/// BasicQuantity : "1.400"
/// Coefficient : "1.0000"
/// CommonUnits : "M"
/// InspectionMethod : "全检"
/// SamplingRatio : "0"
/// InspectionQuantity : "1.400"
/// QualifiedQuantity : "1.400"
/// UnqualifiedQuantity : "0"
/// ShortCodesNumber : "0"
/// StorageQuantity : "1.400"
/// Remarks : "A，56+113=169，B，58"
/// Location : ""
/// UnqualifiedList : []
/// ColorSeparationList : [{"Factory":"1000","InspectionOrderNo":"330000494762","InspectionLineNumber":"00016","ColorSeparationSheetNumber":"100000052818","ColorSeparationSingleLineNumber":"00001","Batch":"20250521C1","ColorSeparationQuantity":"226.000","Location":"","MaterialCode":"02280102229","MaterialDescription":"180g*1.37m灰褐色5微弹超纤（麂皮绒）"}]

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