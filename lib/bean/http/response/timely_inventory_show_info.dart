class TimelyInventoryShowInfo {
  TimelyInventoryShowInfo({
    this.materialNumber="",
    this.materialName='',
    this.stockID='',
    this.factoryNumber='',
    this.batch='',
    this.factoryDescribe='',
    this.lgobe='',
    this.materialCode='',
    this.mtono='',
    this.productName='',
    this.stockQty='',
    this.stockQty1='',
    this.unit='',
    this.unit1='',
    this.zcoefficient='',
    this.zlocal='',
  });

  TimelyInventoryShowInfo.fromJson(dynamic json) {
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    stockID = json['StockID'];
    factoryNumber = json['FactoryNumber'];
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

  String? materialNumber;
  String? materialName;
  String? stockID;
  String? factoryNumber;
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

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['StockID'] = stockID;
    map['FactoryNumber'] = factoryNumber;
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

