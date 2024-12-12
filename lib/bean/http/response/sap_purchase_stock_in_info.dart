/// ZDELINO : "310000575861"
/// ZDELIISEQ : "00010"
/// LIFNR : "0000200759"
/// NAME1 : "浙江康润新材料有限公司"
/// ZDELIQTY : 90000.0
/// MATNR : "090500076"
/// ZMAKTX : "OPP薄膜袋(塑料袋）27*45"
/// ZREMARK : ""
/// EBELN : "4500968444"
/// EBELP : "00010"
/// WERKS : "1500"
/// ZBASEUNIT : "个"
/// ZCOMMUNIT : "个"
/// ZCOEFFICIENT : 1.0
/// ZNUMPAGE : 6
/// ISGENERATE : ""
/// ZISNOCHECK : "X"
/// ZLGORT : "1001"
/// ZVERIFYQTY : 0.0
/// ZINSPECTOR : ""
/// ZINSPECTDATE : "0000-00-00"
/// ZINSPECTTIME : "00:00:00"

class SapPurchaseStockInInfo {
  SapPurchaseStockInInfo({
    this.deliveryNumber,
    this.deliveryOrderLineNumber,
    this.supplierNumber,
    this.supplierName,
    this.qty,
    this.materialCode,
    this.materialDescription,
    this.remarks,
    this.purchaseOrder,
    this.purchaseOrderLineItem,
    this.factory,
    this.basicUnit,
    this.commonUnits,
    this.coefficient,
    this.numPage,
    this.isGenerate,
    this.isExempt,
    this.location,
    this.checkQty,
    this.inspector,
    this.inspectionDate,
    this.inspectionTime,
  });

  SapPurchaseStockInInfo.fromJson(dynamic json) {
    deliveryNumber = json['ZDELINO'];
    deliveryOrderLineNumber = json['ZDELIISEQ'];
    supplierNumber = json['LIFNR'];
    supplierName = json['NAME1'];
    qty = json['ZDELIQTY'];
    materialCode = json['MATNR'];
    materialDescription = json['ZMAKTX'];
    remarks = json['ZREMARK'];
    purchaseOrder = json['EBELN'];
    purchaseOrderLineItem = json['EBELP'];
    factory = json['WERKS'];
    basicUnit = json['ZBASEUNIT'];
    commonUnits = json['ZCOMMUNIT'];
    coefficient = json['ZCOEFFICIENT'];
    numPage = json['ZNUMPAGE'];
    isGenerate = json['ISGENERATE'];
    isExempt = json['ZISNOCHECK'];
    location = json['ZLGORT'];
    checkQty = json['ZVERIFYQTY'];
    inspector = json['ZINSPECTOR'];
    inspectionDate = json['ZINSPECTDATE'];
    inspectionTime = json['ZINSPECTTIME'];
  }

  String? deliveryNumber; //送货单号
  String? deliveryOrderLineNumber; //送货单行号
  String? supplierNumber; //供应商或债权人的帐号
  String? supplierName; //名称 1
  double? qty; //送货数量
  String? materialCode; //物料编号
  String? materialDescription; //文本 (150 个字符)
  String? remarks; //备注
  String? purchaseOrder; //采购凭证号
  String? purchaseOrderLineItem; //采购凭证的项目编号
  String? factory; //工厂
  String? basicUnit; //基本单位
  String? commonUnits; //常用单位
  double? coefficient; //系数
  int? numPage; //件数
  String? isGenerate; //是否生成暂收单
  String? isExempt; //是否免检
  String? location; //存储位置
  double? checkQty; //核对数量
  String? inspector; //稽查人
  String? inspectionDate; //稽查日期
  String? inspectionTime; //稽查时间

  double editQty = 0.0;
  bool select = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZDELINO'] = deliveryNumber;
    map['ZDELIISEQ'] = deliveryOrderLineNumber;
    map['LIFNR'] = supplierNumber;
    map['NAME1'] = supplierName;
    map['ZDELIQTY'] = qty;
    map['MATNR'] = materialCode;
    map['ZMAKTX'] = materialDescription;
    map['ZREMARK'] = remarks;
    map['EBELN'] = purchaseOrder;
    map['EBELP'] = purchaseOrderLineItem;
    map['WERKS'] = factory;
    map['ZBASEUNIT'] = basicUnit;
    map['ZCOMMUNIT'] = commonUnits;
    map['ZCOEFFICIENT'] = coefficient;
    map['ZNUMPAGE'] = numPage;
    map['ISGENERATE'] = isGenerate;
    map['ZISNOCHECK'] = isExempt;
    map['ZLGORT'] = location;
    map['ZVERIFYQTY'] = checkQty;
    map['ZINSPECTOR'] = inspector;
    map['ZINSPECTDATE'] = inspectionDate;
    map['ZINSPECTTIME'] = inspectionTime;
    return map;
  }
}

/// ZDELINO : "310000575861"
/// NAME1 : "浙江康润新材料有限公司"
/// ZDELIISEQ : "00010"
/// ZEBELN : "4500968444"
/// ZEBELP : "00010"
/// ZDELIADDRESS : "金臻"
/// ZMATNR : "090500076"
/// ZMAKTX : "OPP薄膜袋(塑料袋）27*45"
/// ZBASEUNIT : "EA"
/// ZBASEQTY : 90000.0
/// ZCOEFFICIENT : 1.0
/// ZCOMMUNIT : "EA"
/// ZDELIQTY : 90000.0
/// ZTEMPREQTY : 0.0
/// ZINSTOCKQTY : 0.0
/// ZNUMPAGE : 6
/// EEIND : "2024-10-19"
/// ZVERIFYQTY : 0.0
/// ZINSPECTOR : ""
/// ZINSPECTDATE : "0000-00-00"

class SapPurchaseStockInDetailInfo {
  SapPurchaseStockInDetailInfo({
    this.deliveryNumber,
    this.supplierName,
    this.deliveryOrderLineNumber,
    this.purchaseOrderNumber,
    this.purchaseOrderLineNumber,
    this.deliveryAddress,
    this.materialCode,
    this.materialDescription,
    this.basicUnit,
    this.baseQuantity,
    this.coefficient,
    this.commonUnits,
    this.deliveryQty,
    this.temporaryReceiveQuantity,
    this.storageQuantity,
    this.numPage,
    this.deliveryDate,
    this.checkQty,
    this.inspector,
    this.checkDate,
  });

  SapPurchaseStockInDetailInfo.fromJson(dynamic json) {
    deliveryNumber = json['ZDELINO'];
    supplierName = json['NAME1'];
    deliveryOrderLineNumber = json['ZDELIISEQ'];
    purchaseOrderNumber = json['ZEBELN'];
    purchaseOrderLineNumber = json['ZEBELP'];
    deliveryAddress = json['ZDELIADDRESS'];
    materialCode = json['ZMATNR'];
    materialDescription = json['ZMAKTX'];
    basicUnit = json['ZBASEUNIT'];
    baseQuantity = json['ZBASEQTY'];
    coefficient = json['ZCOEFFICIENT'];
    commonUnits = json['ZCOMMUNIT'];
    deliveryQty = json['ZDELIQTY'];
    temporaryReceiveQuantity = json['ZTEMPREQTY'];
    storageQuantity = json['ZINSTOCKQTY'];
    numPage = json['ZNUMPAGE'];
    deliveryDate = json['EEIND'];
    checkQty = json['ZVERIFYQTY'];
    inspector = json['ZINSPECTOR'];
    checkDate = json['ZINSPECTDATE'];
  }

  String? deliveryNumber; //送货单号
  String? supplierName; //供应商
  String? deliveryOrderLineNumber; //送货单行号
  String? purchaseOrderNumber; //采购凭证号
  String? purchaseOrderLineNumber; //采购单行号
  String? deliveryAddress; //送货地点(厂区)
  String? materialCode; //物料编号
  String? materialDescription; //物料描述
  String? basicUnit; //基本单位
  double? baseQuantity; //基本数量
  double? coefficient; //系数
  String? commonUnits; //常用单位
  double? deliveryQty; //送货数量
  double? temporaryReceiveQuantity; //暂收数量
  double? storageQuantity; //入库数量
  int? numPage; //件数
  String? deliveryDate; //交货日期
  double? checkQty; //核查数量
  String? inspector; //核查人
  String? checkDate; //核查日期

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZDELINO'] = deliveryNumber;
    map['NAME1'] = supplierName;
    map['ZDELIISEQ'] = deliveryOrderLineNumber;
    map['ZEBELN'] = purchaseOrderNumber;
    map['ZEBELP'] = purchaseOrderLineNumber;
    map['ZDELIADDRESS'] = deliveryAddress;
    map['ZMATNR'] = materialCode;
    map['ZMAKTX'] = materialDescription;
    map['ZBASEUNIT'] = basicUnit;
    map['ZBASEQTY'] = baseQuantity;
    map['ZCOEFFICIENT'] = coefficient;
    map['ZCOMMUNIT'] = commonUnits;
    map['ZDELIQTY'] = deliveryQty;
    map['ZTEMPREQTY'] = temporaryReceiveQuantity;
    map['ZINSTOCKQTY'] = storageQuantity;
    map['ZNUMPAGE'] = numPage;
    map['EEIND'] = deliveryDate;
    map['ZVERIFYQTY'] = checkQty;
    map['ZINSPECTOR'] = inspector;
    map['ZINSPECTDATE'] = checkDate;
    return map;
  }
}

/// FactoryNumber : "1500"
/// StorageLocationNumber : "1801"
/// Name : "金臻拌料线边仓"

class LocationInfo {
  LocationInfo({
    this.factoryNumber,
    this.storageLocationNumber,
    this.name,
  });

  LocationInfo.fromJson(dynamic json) {
    factoryNumber = json['FactoryNumber'];
    storageLocationNumber = json['StorageLocationNumber'];
    name = json['Name'];
  }

  String? factoryNumber;
  String? storageLocationNumber;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryNumber'] = factoryNumber;
    map['StorageLocationNumber'] = storageLocationNumber;
    map['Name'] = name;
    return map;
  }

  @override
  String toString() {
    return name ?? '';
  }
}
