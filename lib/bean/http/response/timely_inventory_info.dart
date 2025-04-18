class TimelyInventoryInfo {
  TimelyInventoryInfo({
    this.items,
    this.materialNumber,
    this.materialName,
    this.stockID,
    this.factoryNumber,
  });

  TimelyInventoryInfo.fromJson(dynamic json) {
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    stockID = json['StockID'];
    factoryNumber = json['FactoryNumber'];
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(TimeItems.fromJson(
          json: json,
          factoryNumber: factoryNumber ?? '',
          materialNumber: materialNumber ?? '',
          materialName: materialName ?? '',
          stockID: stockID ?? '',
        ));
      });
    }
  }

  List<TimeItems>? items;
  String? materialNumber;
  String? materialName;
  String? stockID;
  String? factoryNumber;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['StockID'] = stockID;
    map['FactoryNumber'] = factoryNumber;

    return map;
  }
}

class TimeItems {
  TimeItems({
    this.batch,
    this.factoryDescribe,
    this.lgobe,
    this.materialCode,
    this.mtono,
    this.productName,
    this.stockQty,
    this.stockQty1,
    this.unit,
    this.unit1,
    this.zcoefficient,
    this.zlocal,
    required this.factoryNumber,
    required this.materialNumber,
    required this.materialName,
    required this.stockID,
  });

  TimeItems.fromJson({
    required dynamic json,
    required this.factoryNumber,
    required this.materialNumber,
    required this.materialName,
    required this.stockID,
  }) {
    batch = json['Batch'];
    factoryDescribe = json['FactoryDescribe'];
    lgobe = json['Lgobe'];
    materialCode = json['MaterialCode'];
    mtono = json['Mtono'];
    productName = json['ProductName'];
    size = json['Size'];
    stockQty = json['StockQty'];
    stockQty1 = json['StockQty1'];
    unit = json['Unit'];
    unit1 = json['Unit1'];
    zcoefficient = json['Zcoefficient'];
    zlocal = json['Zlocal'];
  }

  String? batch;
  String? factoryDescribe;
  String? lgobe;
  String? materialCode;
  String? mtono;
  String? productName;
  String? size;
  String? stockQty;
  String? stockQty1;
  String? unit;
  String? unit1;
  String? zcoefficient;
  String? zlocal;

  String factoryNumber;
  String materialNumber;
  String materialName;
  String stockID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Batch'] = batch;
    map['FactoryDescribe'] = factoryDescribe;
    map['Lgobe'] = lgobe;
    map['MaterialCode'] = materialCode;
    map['Mtono'] = mtono;
    map['ProductName'] = productName;
    map['Size'] = size;
    map['StockQty'] = stockQty;
    map['StockQty1'] = stockQty1;
    map['Unit'] = unit;
    map['Unit1'] = unit1;
    map['Zcoefficient'] = zcoefficient;
    map['Zlocal'] = zlocal;

    return map;
  }
}
