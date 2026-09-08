import 'package:jd_flutter/utils/extension_util.dart';
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
    materialNumber = JsonParse.str(json['MaterialNumber']);
    materialName = JsonParse.str(json['MaterialName']);
    stockID = JsonParse.str(json['StockID']);
    factoryNumber = JsonParse.str(json['FactoryNumber']);
    batch = JsonParse.str(json['Batch']);
    factoryDescribe = JsonParse.str(json['FactoryDescribe']);
    lgobe = JsonParse.str(json['Lgobe']);
    materialCode = JsonParse.str(json['MaterialCode']);
    mtono = JsonParse.str(json['Mtono']);
    productName = JsonParse.str(json['ProductName']);
    size = JsonParse.str(json['Size']);
    stockQty = JsonParse.str(json['StockQty']);
    stockQty1 = JsonParse.str(json['StockQty1']);
    unit = JsonParse.str(json['Unit']);
    unit1 = JsonParse.str(json['Unit1']);
    zcoefficient = JsonParse.str(json['Zcoefficient']);
    zlocal = JsonParse.str(json['Zlocal']);

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

