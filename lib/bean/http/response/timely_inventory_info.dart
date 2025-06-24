// MaterialNumber : "1201190"
// MaterialName : "聚氨酯水溶液（水性胶）"
// StockID : "1001"
// FactoryNumber : "1000"
// Items : [{"FactoryDescribe":"GOLD EMPEROR GROUP CO., LTD","Zlocal":"","Lgobe":"金帝面料仓","Mtono":"","ProductName":"","MaterialCode":"","Size":"","Batch":"","Unit":"千克","StockQty":"773872.468","Unit1":"桶","StockQty1":"38693.623","Zcoefficient":"20"}]

class TimelyInventoryInfo {
  TimelyInventoryInfo({
      this.materialNumber, 
      this.materialName, 
      this.stockID, 
      this.factoryNumber, 
      this.items,});

  TimelyInventoryInfo.fromJson(dynamic json) {
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    stockID = json['StockID'];
    factoryNumber = json['FactoryNumber'];
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(TimeItems.fromJson(v));
      });
    }
  }
  String? materialNumber;
  String? materialName;
  String? stockID;
  String? factoryNumber;
  List<TimeItems>? items;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['StockID'] = stockID;
    map['FactoryNumber'] = factoryNumber;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

// FactoryDescribe : "GOLD EMPEROR GROUP CO., LTD"
// Zlocal : ""
// Lgobe : "金帝面料仓"
// Mtono : ""
// ProductName : ""
// MaterialCode : ""
// Size : ""
// Batch : ""
// Unit : "千克"
// StockQty : "773872.468"
// Unit1 : "桶"
// StockQty1 : "38693.623"
// Zcoefficient : "20"

class TimeItems {
  TimeItems({
      this.factoryDescribe, 
      this.zlocal, 
      this.lgobe, 
      this.mtono, 
      this.productName, 
      this.materialCode, 
      this.size, 
      this.batch, 
      this.unit, 
      this.stockQty, 
      this.unit1, 
      this.stockQty1, 
      this.zcoefficient,});

  TimeItems.fromJson(dynamic json) {
    factoryDescribe = json['FactoryDescribe'];
    zlocal = json['Zlocal'];
    lgobe = json['Lgobe'];
    mtono = json['Mtono'];
    productName = json['ProductName'];
    materialCode = json['MaterialCode'];
    size = json['Size'];
    batch = json['Batch'];
    unit = json['Unit'];
    stockQty = json['StockQty'];
    unit1 = json['Unit1'];
    stockQty1 = json['StockQty1'];
    zcoefficient = json['Zcoefficient'];
  }
  String? factoryDescribe;
  String? zlocal;
  String? lgobe;
  String? mtono;
  String? productName;
  String? materialCode;
  String? size;
  String? batch;
  String? unit;
  String? stockQty;
  String? unit1;
  String? stockQty1;
  String? zcoefficient;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryDescribe'] = factoryDescribe;
    map['Zlocal'] = zlocal;
    map['Lgobe'] = lgobe;
    map['Mtono'] = mtono;
    map['ProductName'] = productName;
    map['MaterialCode'] = materialCode;
    map['Size'] = size;
    map['Batch'] = batch;
    map['Unit'] = unit;
    map['StockQty'] = stockQty;
    map['Unit1'] = unit1;
    map['StockQty1'] = stockQty1;
    map['Zcoefficient'] = zcoefficient;
    return map;
  }

}