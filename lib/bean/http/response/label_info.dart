import 'package:jd_flutter/utils/extension_util.dart';

// BillNo : "JZ2300102"
// BarCode : "20488980010236/002"
// MaterialOtherName : []
// GrossWeight : 600.0
// NetWeight : 1000.0
// Meas : "1x1x1"
// FactoryType : "D13677-22B M"
// MaterialID : 452554
// MaterialCode : "800200818"
// MaterialName : "鞋面-D13677-22B M"
// IsBillPrint : false
// IsTempRec : false
// IsInStock : false
// IsOutStock : false
// IsScReport : false
// IsScProcessReport : false
// ServiceName : ""
// BarCodeTypeID : 81
// PackType : true
// InterID : 67660
// DepartName : "金帝针车2组"
// Items : [{"BillNo":"JZ2300102","Size":"36","Qty":200.0}]

class LabelInfo {
  LabelInfo({
    this.barCode,
    this.grossWeight,
    this.netWeight,
    this.isBillPrint,
    this.isTempRec,
    this.isInStock,
    this.isOutStock,
    this.isScReport,
    this.isScProcessReport,
    this.serviceName,
    this.barCodeTypeID,
    this.packType,
    this.interID,
    this.customFactoryID,
    this.labelType,
    this.departName,
    this.myanmarApprovalDocument,
    this.trackNo,
    this.customsDeclarationUnit,
    this.customsDeclarationType,
    this.pieceNo,
    this.pieceID,
    this.volume,
    this.manufactureDate,
    this.notes,
    this.productName,
    this.orderType,
    this.supplier,
  });

  LabelInfo.fromJson(dynamic json) {
    orderType = JsonParse.str(json['OrderType']);
    productName = JsonParse.str(json['ProductName']);
    barCode = JsonParse.str(json['BarCode']);
    grossWeight = JsonParse.toDouble(json['GrossWeight']);
    netWeight = JsonParse.toDouble(json['NetWeight']);
    isBillPrint = JsonParse.toBool(json['IsBillPrint']);
    isTempRec = JsonParse.toBool(json['IsTempRec']);
    isInStock = JsonParse.toBool(json['IsInStock']);
    isOutStock = JsonParse.toBool(json['IsOutStock']);
    isScReport = JsonParse.toBool(json['IsScReport']);
    isScProcessReport = JsonParse.toBool(json['IsScProcessReport']);
    serviceName = JsonParse.str(json['ServiceName']);
    barCodeTypeID = JsonParse.toInt(json['BarCodeTypeID']);
    packType = JsonParse.toBool(json['PackType']);
    interID = JsonParse.toInt(json['InterID']);
    customFactoryID = JsonParse.str(json['CustomFactoryID']);
    myanmarApprovalDocument = JsonParse.str(json['MyanmarApprovalDocument']);
    trackNo = JsonParse.str(json['TrackNo']);
    customsDeclarationUnit = JsonParse.str(json['CustomsDeclarationUnit']);
    customsDeclarationType = JsonParse.str(json['CustomsDeclarationType']);
    pieceNo = JsonParse.str(json['PieceNo']);
    pieceID = JsonParse.str(json['PieceID']);
    volume = JsonParse.str(json['Volume']);
    supplier = JsonParse.str(json['Supplier']);
    manufactureDate = JsonParse.str(json['ManufactureDate']);
    notes = JsonParse.str(json['Notes']);
    labelType = JsonParse.toInt(json['LabelType']);
    labelModel = JsonParse.str(json['LabelModel']);
    departName = JsonParse.str(json['DepartName']);
    subList = [
      if (json['SubList'] != null)
        for (var item in json['SubList']) LabelMaterialInfo.fromJson(item)
    ];

  }

  bool select = false;

  String? supplier;
  String? orderType;
  String? productName;
  String? barCode;
  List<LabelMaterialInfo>? subList;
  double? grossWeight;
  double? netWeight;
  bool? isBillPrint;
  bool? isTempRec;
  bool? isInStock;
  bool? isOutStock;
  bool? isScReport;
  bool? isScProcessReport;
  String? serviceName;
  int? barCodeTypeID;
  bool? packType;
  int? interID;
  String? customFactoryID;
  int? labelType;
  String? labelModel;
  String? departName;
  String? myanmarApprovalDocument;
  String? trackNo;
  String? customsDeclarationUnit;
  String? customsDeclarationType;
  String? pieceNo;
  String? pieceID;
  String? volume;
  String? manufactureDate;
  String? notes;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Supplier'] = supplier;
    map['OrderType'] = orderType;
    map['ProductName'] = productName;
    map['BarCode'] = barCode;
    map['GrossWeight'] = grossWeight;
    map['NetWeight'] = netWeight;
    map['IsBillPrint'] = isBillPrint;
    map['IsTempRec'] = isTempRec;
    map['IsInStock'] = isInStock;
    map['IsOutStock'] = isOutStock;
    map['IsScReport'] = isScReport;
    map['IsScProcessReport'] = isScProcessReport;
    map['ServiceName'] = serviceName;
    map['BarCodeTypeID'] = barCodeTypeID;
    map['PackType'] = packType;
    map['InterID'] = interID;
    map['CustomFactoryID'] = customFactoryID;
    map['LabelType'] = labelType;
    map['DepartName'] = departName;
    map['MyanmarApprovalDocument'] = myanmarApprovalDocument;
    map['TrackNo'] = trackNo;
    map['CustomsDeclarationUnit'] = customsDeclarationUnit;
    map['CustomsDeclarationType'] = customsDeclarationType;
    map['PieceNo'] = pieceNo;
    map['PieceID'] = pieceID;
    map['Volume'] = volume;
    map['ManufactureDate'] = manufactureDate;
    map['Notes'] = notes;
    map['SubList'] = subList?.map((v) => v.toJson()).toList();
    return map;
  }

  int labelState() {
    return (isScProcessReport ?? false)
        ? 1
        : (isBillPrint ?? false)
            ? 2
            : 0;
  }

  bool hasSize(String size) =>
      subList!.any((v) => v.items!.any((v2) => v2.size == size));

  double totalQty() => subList.isNullOrEmpty()
      ? 0.0
      : subList!.map((v) => v.totalQty()).reduce((a, b) => a.add(b));
}

class LabelMaterialInfo {
  String? billNo;
  List<LabelLanguageInfo>? materialOtherName;
  String? meas;
  String? factoryType;
  int? materialID;
  String? materialCode;
  String? materialName;
  List<LabelSizeInfo>? items;

  LabelMaterialInfo.fromJson(dynamic json) {
    billNo = JsonParse.str(json['BillNo']);
    materialOtherName = [
      if (json['MaterialOtherName'] != null)
        for (var item in json['MaterialOtherName'])
          LabelLanguageInfo.fromJson(item)
    ];
    meas = JsonParse.str(json['Meas']);
    factoryType = JsonParse.str(json['FactoryType']);
    materialID = JsonParse.toInt(json['MaterialID']);
    materialCode = JsonParse.str(json['MaterialCode']);
    materialName = JsonParse.str(json['MaterialName']);
    items = [
      if (json['Items'] != null)
        for (var item in json['Items']) LabelSizeInfo.fromJson(item)
    ];
    items?.sort((a, b) => a.size.toDoubleTry().compareTo(b.size.toDoubleTry()));
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillNo'] = billNo;
    if (materialOtherName != null) {
      map['MaterialOtherName'] =
          materialOtherName?.map((v) => v.toJson()).toList();
    }
    map['Meas'] = meas;
    map['FactoryType'] = factoryType;
    map['MaterialID'] = materialID;
    map['MaterialCode'] = materialCode;
    map['MaterialName'] = materialName;
    map['Items'] = items?.map((v) => v.toJson()).toList();
    return map;
  }

  String getMaterialLanguage(String language) {
    var material = materialName ?? '';
    materialOtherName?.forEach((v) {
      if (v.languageCode == language) {
        material =  '($materialCode)${v.name}';
        return;
      }
    });
    return material;
  }

  double totalQty() => items.isNullOrEmpty()
      ? 0.0
      : items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));
}
// BillNo : "JZ2300102"
// Size : "36"
// Qty : 200.0

class LabelSizeInfo {
  LabelSizeInfo({
    this.size,
    this.qty,
  });

  LabelSizeInfo.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
  }

  String? size;
  double? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    return map;
  }
}

class LabelLanguageInfo {
  LabelLanguageInfo({
    this.deliveryDate,
    this.languageCode,
    this.languageName,
    this.name,
    this.pageNumber,
    this.unitName,
  });

  LabelLanguageInfo.fromJson(dynamic json) {
    deliveryDate = JsonParse.str(json['DeliveryDate']);
    languageCode = JsonParse.str(json['LanguageCode']);
    languageName = JsonParse.str(json['LanguageName']);
    name = JsonParse.str(json['Name']);
    pageNumber = JsonParse.str(json['PageNumber']);
    unitName = JsonParse.str(json['UnitName']);
  }

  String? deliveryDate;
  String? languageCode;
  String? languageName;
  String? name;
  String? pageNumber;
  String? unitName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeliveryDate'] = deliveryDate;
    map['LanguageCode'] = languageCode;
    map['LanguageName'] = languageName;
    map['Name'] = name;
    map['PageNumber'] = pageNumber;
    map['UnitName'] = unitName;
    return map;
  }
}
