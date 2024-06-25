/// BillNo : "JZ2300102"
/// BarCode : "20488980010236/002"
/// MaterialOtherName : []
/// GrossWeight : 600.0
/// NetWeight : 1000.0
/// Meas : "1x1x1"
/// FactoryType : "D13677-22B M"
/// MaterialID : 452554
/// MaterialCode : "800200818"
/// MaterialName : "鞋面-D13677-22B M"
/// IsBillPrint : false
/// IsTempRec : false
/// IsInStock : false
/// IsOutStock : false
/// IsScReport : false
/// IsScProcessReport : false
/// ServiceName : ""
/// BarCodeTypeID : 81
/// PackType : true
/// InterID : 67660
/// DepartName : "金帝针车2组"
/// Items : [{"BillNo":"JZ2300102","Size":"36","Qty":200.0}]

class LabelInfo {
  LabelInfo({
    this.billNo,
    this.barCode,
    this.materialOtherName,
    this.grossWeight,
    this.netWeight,
    this.meas,
    this.factoryType,
    this.materialID,
    this.materialCode,
    this.materialName,
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
    this.departName,
    this.items,
  });

  LabelInfo.fromJson(dynamic json) {
    billNo = json['BillNo'];
    barCode = json['BarCode'];
    if (json['MaterialOtherName'] != null) {
      materialOtherName = [];
      json['MaterialOtherName'].forEach((v) {
        materialOtherName?.add(LabelMaterialInfo.fromJson(v));
      });
    }
    grossWeight = json['GrossWeight'];
    netWeight = json['NetWeight'];
    meas = json['Meas'];
    factoryType = json['FactoryType'];
    materialID = json['MaterialID'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
    isBillPrint = json['IsBillPrint'];
    isTempRec = json['IsTempRec'];
    isInStock = json['IsInStock'];
    isOutStock = json['IsOutStock'];
    isScReport = json['IsScReport'];
    isScProcessReport = json['IsScProcessReport'];
    serviceName = json['ServiceName'];
    barCodeTypeID = json['BarCodeTypeID'];
    packType = json['PackType'];
    interID = json['InterID'];
    departName = json['DepartName'];
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(LabelSizeInfo.fromJson(v));
      });
    }
  }
  bool select=false;

  String? billNo;
  String? barCode;
  List<LabelMaterialInfo>? materialOtherName;
  double? grossWeight;
  double? netWeight;
  String? meas;
  String? factoryType;
  int? materialID;
  String? materialCode;
  String? materialName;
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
  String? departName;
  List<LabelSizeInfo>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillNo'] = billNo;
    map['BarCode'] = barCode;
    if (materialOtherName != null) {
      map['MaterialOtherName'] =
          materialOtherName?.map((v) => v.toJson()).toList();
    }
    map['GrossWeight'] = grossWeight;
    map['NetWeight'] = netWeight;
    map['Meas'] = meas;
    map['FactoryType'] = factoryType;
    map['MaterialID'] = materialID;
    map['MaterialCode'] = materialCode;
    map['MaterialName'] = materialName;
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
    map['DepartName'] = departName;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  int labelState() {
    return (isScProcessReport ?? false)
        ? 1
        : (isBillPrint ?? false)
            ? 2
            : 0;
  }
}

/// BillNo : "JZ2300102"
/// Size : "36"
/// Qty : 200.0

class LabelSizeInfo {
  LabelSizeInfo({
    this.isSubtotal,
    this.billNo,
    this.size,
    this.qty,
  });

  LabelSizeInfo.fromJson(dynamic json) {
    billNo = json['BillNo'];
    size = json['Size'];
    qty = json['Qty'];
  }
  bool? isSubtotal=false;
  String? billNo;
  String? size;
  double? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillNo'] = billNo;
    map['Size'] = size;
    map['Qty'] = qty;
    return map;
  }
}

class LabelMaterialInfo {
  LabelMaterialInfo({
    this.deliveryDate,
    this.languageCode,
    this.languageName,
    this.name,
    this.pageNumber,
    this.unitName,
  });

  LabelMaterialInfo.fromJson(dynamic json) {
    deliveryDate = json['DeliveryDate'];
    languageCode = json['LanguageCode'];
    languageName = json['LanguageName'];
    name = json['Name'];
    pageNumber = json['PageNumber'];
    unitName = json['UnitName'];
  }

  String? deliveryDate;
  String? languageCode;
  String? languageName;
  String? name;
  String? pageNumber;
  double? unitName;

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
