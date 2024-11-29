import 'package:collection/collection.dart';
import 'package:jd_flutter/utils/utils.dart';

/// {
///   "ZTYPE": "1",
///   "NOTICE_NO": "000000128279",
///   "DISPATCH_NO": "000000097386",
///   "ZVBELN_ORI": "",
///   "ZZGCXT": "",
///   "ZWOFNR": "",
///   "ZZPGJT": "BLZ",
///   "ERDAT": "2024-11-14",
///   "KTSCH": "BL",
///   "WERKS": "",
///   "LGORT": "1001",
///   "LGOBE": "金臻原材料仓",
///   "USNAM": "",
///   "EBELN": "",
///   "LIFNR": "",
///   "NAME1": ""
/// }
class SapPickingInfo {
  SapPickingInfo({
    this.orderType,
    this.noticeNo,
    this.dispatchNumber,
    this.instructionNo,
    this.typeBody,
    this.pickingOrderNo,
    this.machineNumber,
    this.orderDate,
    this.process,
    this.factoryNO,
    this.location,
    this.warehouse,
    this.picker,
    this.purchaseOrder,
    this.supplierID,
    this.supplierName,
  });

  bool select = false;

  String? orderType; //ZTYPE 单据类型
  String? noticeNo; //NOTICE_NO 通知单号
  String? dispatchNumber; //DISPATCH_NO 派工单号
  String? instructionNo; //ZVBELN_ORI 指令号
  String? typeBody; //ZZGCXT 型体
  String? pickingOrderNo; //ZWOFNR 单据号
  String? machineNumber; //ZZPGJT 机台号
  String? orderDate; //ERDAT 派工日期
  String? process; //KTSCH 制程
  String? factoryNO; //WERKS 工厂编号
  String? location; //LGORT 库存位置
  String? warehouse; //LGOBE 库存名
  String? picker; //USNAM 领料员
  String? purchaseOrder; //EBELN 采购订单
  String? supplierID; //LIFNR 供应商编号
  String? supplierName; //NAME1 供应商名称

  SapPickingInfo.fromJson(dynamic json) {
    orderType = json['ZTYPE'];
    noticeNo = json['NOTICE_NO'];
    dispatchNumber = json['DISPATCH_NO'];
    instructionNo = json['ZVBELN_ORI'];
    typeBody = json['ZZGCXT'];
    pickingOrderNo = json['ZWOFNR'];
    machineNumber = json['ZZPGJT'];
    orderDate = json['ERDAT'];
    process = json['KTSCH'];
    factoryNO = json['WERKS'];
    location = json['LGORT'];
    warehouse = json['LGOBE'];
    picker = json['USNAM'];
    purchaseOrder = json['EBELN'];
    supplierID = json['LIFNR'];
    supplierName = json['NAME1'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZTYPE'] = orderType;
    map['NOTICE_NO'] = noticeNo;
    map['DISPATCH_NO'] = dispatchNumber;
    map['ZVBELN_ORI'] = instructionNo;
    map['ZZGCXT'] = typeBody;
    map['ZWOFNR'] = pickingOrderNo;
    map['ZZPGJT'] = machineNumber;
    map['ERDAT'] = orderDate;
    map['KTSCH'] = process;
    map['WERKS'] = factoryNO;
    map['LGORT'] = location;
    map['LGOBE'] = warehouse;
    map['USNAM'] = picker;
    map['EBELN'] = purchaseOrder;
    map['LIFNR'] = supplierID;
    map['NAME1'] = supplierName;
    return map;
  }

  orderHint() {
    return dispatchNumber?.isEmpty == true ? '补料单号：' : '派工单号：';
  }

  orderNumber() {
    return dispatchNumber?.isEmpty == true ? pickingOrderNo : dispatchNumber;
  }
}

class SapPickingBarCodeInfo {
  SapPickingBarCodeInfo({
    this.barCode,
    this.materialNumber,
    this.materialName,
    this.qty,
    this.unitName,
  });

  bool scanned = false;
  String? barCode;
  String? materialNumber;
  String? materialName;
  double? qty;
  String? unitName;

  SapPickingBarCodeInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    qty = json['Qty'];
    unitName = json['UnitName'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['Qty'] = qty;
    map['UnitName'] = unitName;
    return map;
  }
}

class SapPickingDetailInfo {
  SapPickingDetailInfo({
    this.order,
    this.labels,
    this.dispatch,
  });

  List<SapProductionPickingDetailOrderInfo>? order;
  List<SapPickingDetailLabelInfo>? labels;
  List<SapProductionPickingDetailDispatchInfo>? dispatch;

  SapPickingDetailInfo.fromJson(dynamic json) {
    if (json['ORDER'] != null) {
      order = [];
      json['ORDER'].forEach((v) {
        order?.add(SapProductionPickingDetailOrderInfo.fromJson(v));
      });
    }
    if (json['PICK'] != null) {
      labels = [];
      json['PICK'].forEach((v) {
        labels?.add(SapPickingDetailLabelInfo.fromJson(v));
      });
    }
    if (json['DISPATCH'] != null) {
      dispatch = [];
      json['DISPATCH'].forEach((v) {
        dispatch?.add(SapProductionPickingDetailDispatchInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ORDER'] = order?.map((e) => e.toJson()).toList();
    map['PICK'] = labels?.map((e) => e.toJson()).toList();
    map['DISPATCH'] = dispatch?.map((e) => e.toJson()).toList();
    return map;
  }
}

///  {
///    "ZTYPE": "1",
///    "NOTICE_NO": "000000128279",
///    "NOTICE_ITEM": "00001",
///    "DISPATCH_NO": "000000097386",
///    "DISPATCH_ITEM": "00050",
///    "DISPATCH_DATE": "2024-11-14",
///    "AUFNR": "002011269235",
///    "ZZPGJT": "BLZ",
///    "WERKS": "1500",
///    "LGORT": "1001",
///    "LGOBE": "金臻原材料仓",
///    "KTSCH": "BL",
///    "ZZXTNO": "",
///    "SATNR": "460200181",
///    "MAKTX_S": "TPU-3698AYL-1",
///    "ZCM": "",
///    "MATNR": "460200181",
///    "MAKTX": "TPU-3698AYL-1",
///    "ZSFDL": "",
///    "BDMNG": 29.921,
///    "ENMNG": 0.0,
///    "LABST": 0.0,
///    "MEINS": "千克",
///    "AUSME": "",
///    "ZCOEFFICIENT": 0.0,
///    "ZVBELN_ORI": "",
///    "ZPOSNR_ORI": "000000",
///    "ITEM": [],
///    "EBELN": "",
///    "EBELP": "00000"
///  }

class SapProductionPickingDetailOrderInfo {
  SapProductionPickingDetailOrderInfo({
    this.orderType,
    this.noticeNo,
    this.noticeLineNo,
    this.dispatchNumber,
    this.dispatchLineNumber,
    this.dispatchDate,
    this.productionOrderNumber,
    this.machineNumber,
    this.factoryNumber,
    this.location,
    this.warehouse,
    this.process,
    this.typeBody,
    this.materialNumber,
    this.materialName,
    this.size,
    this.sizeMaterialNumber,
    this.sizeMaterialName,
    this.beyondFlag,
    this.demandQty,
    this.deliveryQty,
    this.lineStock,
    this.basicUnit,
    this.commonUnit,
    this.coefficient,
    this.instructionsNo,
    this.productionOrderItemNumber,
    this.recommend,
    this.purchaseOrder,
    this.purchaseOrderLine,
  });

  bool select = true;

  String? orderType; //单据类型  ZTYPE
  String? noticeNo; //通知单号  NOTICE_NO
  String? noticeLineNo; //通知单行  NOTICE_ITEM
  String? dispatchNumber; //派工单号  DISPATCH_NO
  String? dispatchLineNumber; //派工单行号  DISPATCH_ITEM
  String? dispatchDate; //派工日期  DISPATCH_DATE
  String? productionOrderNumber; //生产订单号  AUFNR
  String? machineNumber; //派工机台  ZZPGJT
  String? factoryNumber; //工厂编号  WERKS
  String? location; //库存位置  LGORT
  String? warehouse; //库存名  LGOBE
  String? process; //制程  KTSCH
  String? typeBody; //型体  ZZXTNO
  String? materialNumber; //物料编号  SATNR
  String? materialName; //物料描述  MAKTX_S
  String? size; //尺码  ZCM
  String? sizeMaterialNumber; //尺码物料编号  MATNR
  String? sizeMaterialName; //尺码物料描述  MAKTX
  String? beyondFlag; //多领  ZSFDL
  double? demandQty; //需求量  BDMNG
  double? deliveryQty; //已发货数量  ENMNG
  double? lineStock; //线边仓库存  LABST
  String? basicUnit; //基本单位  MEINS
  String? commonUnit; //常用单位  AUSME
  double? coefficient; //系数  ZCOEFFICIENT
  String? instructionsNo; //指令号  ZVBELN_ORI
  String? productionOrderItemNumber; //生产订单项目号  ZPOSNR_ORI
  List<RecommendedPositionInfo>? recommend; //推荐库位  ITEM
  String? purchaseOrder; //采购订单号  EBELN
  String? purchaseOrderLine; //代购订单行号  EBELP

  SapProductionPickingDetailOrderInfo.fromJson(dynamic json) {
    orderType = json['ZTYPE'];
    noticeNo = json['NOTICE_NO'];
    noticeLineNo = json['NOTICE_ITEM'];
    dispatchNumber = json['DISPATCH_NO'];
    dispatchLineNumber = json['DISPATCH_ITEM'];
    dispatchDate = json['DISPATCH_DATE'];
    productionOrderNumber = json['AUFNR'];
    machineNumber = json['ZZPGJT'];
    factoryNumber = json['WERKS'];
    location = json['LGORT'];
    warehouse = json['LGOBE'];
    process = json['KTSCH'];
    typeBody = json['ZZXTNO'];
    materialNumber = json['SATNR'];
    materialName = json['MAKTX_S'];
    size = json['ZCM'];
    sizeMaterialNumber = json['MATNR'];
    sizeMaterialName = json['MAKTX'];
    beyondFlag = json['ZSFDL'];
    demandQty = json['BDMNG'];
    deliveryQty = json['ENMNG'];
    lineStock = json['LABST'];
    basicUnit = json['MEINS'];
    commonUnit = json['AUSME'];
    coefficient = json['ZCOEFFICIENT'];
    instructionsNo = json['ZVBELN_ORI'];
    productionOrderItemNumber = json['ZPOSNR_ORI'];
    if (json['ITEM'] != null) {
      recommend = [];
      json['ITEM'].forEach((v) {
        recommend?.add(RecommendedPositionInfo.fromJson(v));
      });
    }
    purchaseOrder = json['EBELN'];
    purchaseOrderLine = json['EBELP'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZTYPE'] = orderType;
    map['NOTICE_NO'] = noticeNo;
    map['NOTICE_ITEM'] = noticeLineNo;
    map['DISPATCH_NO'] = dispatchNumber;
    map['DISPATCH_ITEM'] = dispatchLineNumber;
    map['DISPATCH_DATE'] = dispatchDate;
    map['AUFNR'] = productionOrderNumber;
    map['ZZPGJT'] = machineNumber;
    map['WERKS'] = factoryNumber;
    map['LGORT'] = location;
    map['LGOBE'] = warehouse;
    map['KTSCH'] = process;
    map['ZZXTNO'] = typeBody;
    map['SATNR'] = materialNumber;
    map['MAKTX_S'] = materialName;
    map['ZCM'] = size;
    map['MATNR'] = sizeMaterialNumber;
    map['MAKTX'] = sizeMaterialName;
    map['ZSFDL'] = beyondFlag;
    map['BDMNG'] = demandQty;
    map['ENMNG'] = deliveryQty;
    map['LABST'] = lineStock;
    map['MEINS'] = basicUnit;
    map['AUSME'] = commonUnit;
    map['ZCOEFFICIENT'] = coefficient;
    map['ZVBELN_ORI'] = instructionsNo;
    map['ZPOSNR_ORI'] = productionOrderItemNumber;
    if (recommend != null) {
      map['ITEM'] = recommend?.map((v) => v.toJson()).toList();
    }
    map['EBELN'] = purchaseOrder;
    map['EBELP'] = purchaseOrderLine;
    return map;
  }

  double getRemainder() => demandQty.sub(deliveryQty ?? 0);
}

class RecommendedPositionInfo {
  RecommendedPositionInfo({
    this.warehouse,
    this.warehouseLocation,
    this.palletNo,
    this.qty,
  });

  RecommendedPositionInfo.fromJson(dynamic json) {
    warehouse = json['ZWH'];
    warehouseLocation = json['ZLOCAL'];
    palletNo = json['ZFTRAYNO'];
    qty = json['ZBASEQTY'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZWH'] = warehouse;
    map['ZLOCAL'] = warehouseLocation;
    map['ZFTRAYNO'] = palletNo;
    map['ZBASEQTY'] = qty;
    return map;
  }

  String? warehouse; //仓库  ZWH
  String? warehouseLocation; //库位  ZLOCAL
  String? palletNo; //托盘号  ZFTRAYNO
  String? qty; //数量  ZBASEQTY
}

class SapProductionPickingDetailDispatchInfo {
  SapProductionPickingDetailDispatchInfo({
    this.instructionNo,
    this.orderNumber,
    this.dispatchLineNumber,
    this.dispatchDate,
    this.productionOrderNo,
    this.machineNumber,
    this.purchaseOrderNumber,
    this.purchaseOrderLineNumber,
  });

  String? instructionNo; //指令号 ZVBELN_ORI
  String? orderNumber; //派工单号  DISPATCH_NO
  String? dispatchLineNumber; //派工单行号  DISPATCH_ITEM
  String? dispatchDate; //派工日期 DISPATCH_DATE
  String? productionOrderNo; //生产订单号 AUFNR
  String? machineNumber; //机台号 ZZPGJT
  String? purchaseOrderNumber; //合同编号  EBELN
  String? purchaseOrderLineNumber; //合同行号  EBELP

  SapProductionPickingDetailDispatchInfo.fromJson(dynamic json) {
    instructionNo = json['ZVBELN_ORI'];
    orderNumber = json['DISPATCH_NO'];
    dispatchLineNumber = json['DISPATCH_ITEM'];
    dispatchDate = json['DISPATCH_DATE'];
    productionOrderNo = json['AUFNR'];
    machineNumber = json['ZZPGJT'];
    purchaseOrderNumber = json['EBELN'];
    purchaseOrderLineNumber = json['EBELP'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZVBELN_ORI'] = instructionNo;
    map['DISPATCH_NO'] = orderNumber;
    map['DISPATCH_ITEM'] = dispatchLineNumber;
    map['DISPATCH_DATE'] = dispatchDate;
    map['AUFNR'] = productionOrderNo;
    map['ZZPGJT'] = machineNumber;
    map['EBELN'] = purchaseOrderNumber;
    map['EBELP'] = purchaseOrderLineNumber;
    return map;
  }
}

class SapPickingDetailLabelInfo {
  SapPickingDetailLabelInfo({
    this.pickingType,
    this.unit,
    this.quantity,
    this.size,
    this.typeBody,
    this.instructionsNo,
    this.salesOrderLineItem,
    this.salesOrderNo,
    this.batchNumber,
    this.materialCode,
    this.materialName,
    this.sizeMaterialCode,
    this.warehouseLocation,
    this.location,
    this.labelCode,
    this.palletNumber,
  });

  List<DistributableInfo> distribution = []; //分配数据

  String? factory; //WERKS  工厂
  String? palletNumber; //ZFTRAYNO 托盘号
  String? labelCode; //BQID  贴标号
  String? location; //LGORT 存储位置
  String? warehouseLocation; //ZLOCAL  库位
  String? sizeMaterialCode; //MATNR 尺码物料编号
  String? materialName; //MAKTX_S 一般物料描述
  String? materialCode; //SATNR 一般物料编号
  String? batchNumber; //CHARG  批号
  String? salesOrderNo; //KDAUF 销售订单号
  String? salesOrderLineItem; //KDPOS 销售订单行项
  String? instructionsNo; //ZZVBELN 指令
  String? typeBody; //ZZXTNO 型体
  String? size; //SIZE1 尺码
  double? quantity; //MENGE 数量
  String? unit; //MEINS 单位
  String? pickingType; //ZBQLY  领料类型 B0、整箱领料 B1、拆箱领料 B2、不领料

  SapPickingDetailLabelInfo.fromJson(dynamic json) {
    factory = json['WERKS'];
    palletNumber = json['ZFTRAYNO'];
    labelCode = json['BQID'];
    location = json['LGORT'];
    warehouseLocation = json['ZLOCAL'];
    sizeMaterialCode = json['MATNR'];
    materialName = json['MAKTX_S'];
    materialCode = json['SATNR'];
    batchNumber = json['CHARG'];
    salesOrderNo = json['KDAUF'];
    salesOrderLineItem = json['KDPOS'];
    instructionsNo = json['ZZVBELN'];
    typeBody = json['ZZXTNO'];
    size = json['SIZE1'];
    quantity = json['MENGE'];
    unit = json['MEINS'];
    pickingType = json['ZBQLY'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WERKS'] = factory;
    map['ZFTRAYNO'] = palletNumber;
    map['BQID'] = labelCode;
    map['LGORT'] = location;
    map['ZLOCAL'] = warehouseLocation;
    map['MATNR'] = sizeMaterialCode;
    map['MAKTX_S'] = materialName;
    map['SATNR'] = materialCode;
    map['CHARG'] = batchNumber;
    map['KDAUF'] = salesOrderNo;
    map['KDPOS'] = salesOrderLineItem;
    map['ZZVBELN'] = instructionsNo;
    map['ZZXTNO'] = typeBody;
    map['SIZE1'] = size;
    map['MENGE'] = quantity;
    map['MEINS'] = unit;
    map['ZBQLY'] = pickingType;
    return map;
  }

  double getPickQty() => distribution.isEmpty
      ? 0
      : distribution.map((v) => v.qty).reduce((a, b) => a.add(b));
}

class PalletInfo {
  List<PalletItem1Info>? item1;
  List<PalletItem2Info>? item2;

  PalletInfo({this.item1, this.item2});

  PalletInfo.fromJson(dynamic json) {
    if (json['item1'] != null) {
      item1 = [];
      json['item1'].forEach((v) {
        item1?.add(PalletItem1Info.fromJson(v));
      });
    }
    if (json['item2'] != null) {
      item2 = [];
      json['item2'].forEach((v) {
        item2?.add(PalletItem2Info.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (item1 != null) {
      map['item1'] = item1?.map((v) => v.toJson()).toList();
    }
    if (item2 != null) {
      map['item2'] = item2?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PalletItem1Info {
  bool select=false;

  String? factoryNumber; //工厂  WERKS
  String? warehouseNumber; //仓库  LGORT
  String? warehouseName; //仓库名 LGOBE
  String? location; //库位 ZLOCAL
  String? palletNumber; //托盘号  ZFTRAYNO
  String? labelNumber; //标签ID  BQID
  String? materialNumber; //一般物料编码 SATNR
  String? materialName; //一般物料名称 MAKTX1
  String? sizeMaterialNumber; //尺码物料编码 MATNR
  String? sizeMaterialName; //尺码物料名称 MAKTX
  String? typeBody; //型体 ZZXTNO
  String? size; //尺码 SIZE1
  String? instructionNo; //指令号 ZVBELN_ORI
  String? salesOrderNo; //销售订单号  KDAUF
  String? salesOrderLineItem; //销售订单行项目  KDPOS
  String? batch; //批次  CHARG
  double? quantity; //数量 MENGE
  String? unit; //单位 MEINS

  PalletItem1Info({
    this.factoryNumber,
    this.warehouseNumber,
    this.warehouseName,
    this.location,
    this.palletNumber,
    this.labelNumber,
    this.materialNumber,
    this.materialName,
    this.sizeMaterialNumber,
    this.sizeMaterialName,
    this.typeBody,
    this.size,
    this.instructionNo,
    this.salesOrderNo,
    this.salesOrderLineItem,
    this.batch,
    this.quantity,
    this.unit,
  });

  PalletItem1Info.fromJson(dynamic json) {
    factoryNumber = json['WERKS'];
    warehouseNumber = json['LGORT'];
    warehouseName = json['LGOBE'];
    location = json['ZLOCAL'];
    palletNumber = json['ZFTRAYNO'];
    labelNumber = json['BQID'];
    materialNumber = json['SATNR'];
    materialName = json['MAKTX1'];
    sizeMaterialNumber = json['MATNR'];
    sizeMaterialName = json['MAKTX'];
    typeBody = json['ZZXTNO'];
    size = json['SIZE1'];
    instructionNo = json['ZVBELN_ORI'];
    salesOrderNo = json['KDAUF'];
    salesOrderLineItem = json['KDPOS'];
    batch = json['CHARG'];
    quantity = json['MENGE'];
    unit = json['MEINS'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WERKS'] = factoryNumber;
    map['LGORT'] = warehouseNumber;
    map['LGOBE'] = warehouseName;
    map['ZLOCAL'] = location;
    map['ZFTRAYNO'] = palletNumber;
    map['BQID'] = labelNumber;
    map['SATNR'] = materialNumber;
    map['MAKTX1'] = materialName;
    map['MAKTX'] = sizeMaterialName;
    map['MATNR'] = sizeMaterialNumber;
    map['ZZXTNO'] = typeBody;
    map['SIZE1'] = size;
    map['ZVBELN_ORI'] = instructionNo;
    map['KDAUF'] = salesOrderNo;
    map['KDPOS'] = salesOrderLineItem;
    map['CHARG'] = batch;
    map['MENGE'] = quantity;
    map['MEINS'] = unit;
    return map;
  }
}

class PalletItem2Info {
  var factoryNumber; //工厂  WERKS
  var warehouseNumber; //仓库  LGORT
  var location; //库位 ZLOCAL
  var palletNumber; //托盘号  ZFTRAYNO
  var palletExistence; //托盘是否存在  空 托盘不存在、 X 托盘存在 ZTRAY_CFMRT1
  var palletState; //托盘状态  空 托盘无货、 X 当前条件下有货、Y 托盘有货但不在当前查询条件下  ZTRAY_CFMRT2

  PalletItem2Info({
    this.factoryNumber,
    this.warehouseNumber,
    this.location,
    this.palletNumber,
    this.palletExistence,
    this.palletState,
  });

  PalletItem2Info.fromJson(dynamic json) {
    factoryNumber = json['WERKS'];
    warehouseNumber = json['LGORT'];
    location = json['ZLOCAL'];
    palletNumber = json['ZFTRAYNO'];
    palletExistence = json['ZTRAY_CFMRT1'];
    palletState = json['ZTRAY_CFMRT2'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WERKS'] = factoryNumber;
    map['LGORT'] = warehouseNumber;
    map['ZLOCAL'] = location;
    map['ZFTRAYNO'] = palletNumber;
    map['ZTRAY_CFMRT1'] = palletExistence;
    map['ZTRAY_CFMRT2'] = palletState;
    return map;
  }
}

class DistributableInfo {
  int ascriptionId = -1; //归属ID
  double qty = 0.0;

  DistributableInfo(this.ascriptionId, this.qty); //分配数
}

class PickingOrderMaterialInfo {
  bool select = true;
  String dispatchNumber = '';
  String machineNumber = '';
  String material = '';
  String process = '';
  String dispatchDate = '';
  List<SapProductionPickingDetailOrderInfo> materialList = [];
  List<double> remainderList = [];
  List<double> pickQtyList = [];

  bool canPicking(int index) =>
      (materialList[index].lineStock ?? 0) > 0 || pickQtyList[index] > 0;

  PickingOrderMaterialInfo.fromData(
    List<SapProductionPickingDetailOrderInfo> data,
    bool isSelect,
  ) {
    dispatchNumber = data[0].dispatchNumber ?? '';
    machineNumber = data[0].machineNumber ?? '';
    process = data[0].process ?? '';
    dispatchDate = data[0].dispatchDate ?? '';
    groupBy(data, (v) => v.materialNumber).forEach((k, v) {
      var pickQty = 0.0;
      var remainder = 0.0;
      for (var it in v) {
        remainder = remainder.add(it.demandQty.sub(it.deliveryQty ?? 0));
        pickQty = pickQty.add(
            (it.demandQty.sub(it.deliveryQty ?? 0)).sub(it.lineStock ?? 0));
      }
      var material = SapProductionPickingDetailOrderInfo(
        orderType: v[0].orderType,
        process: v[0].process,
        dispatchNumber: v[0].dispatchNumber,
        dispatchLineNumber: v[0].dispatchLineNumber,
        location: v[0].location,
        beyondFlag: v[0].beyondFlag,
        basicUnit: v[0].basicUnit,
        materialNumber: v[0].materialNumber,
        materialName: v[0].materialName,
        typeBody: v[0].typeBody,
        commonUnit: v[0].commonUnit,
        lineStock: v[0].lineStock,
      )..select = !isSelect;
      materialList.add(material);
      remainderList.add(remainder);
      pickQtyList.add(isSelect ? 0 : pickQty);
    });
    select = !isSelect;
  }
}

class PrintPickingDetailInfo {
  int dataId = -1; //数据ID
  bool select = true;
  double pickQty = 0;
  SapProductionPickingDetailOrderInfo order;

  PrintPickingDetailInfo.fromData(this.order) {
    pickQty = order.location == '1001'
        ? order.demandQty.sub(order.deliveryQty ?? 0)
        : 0;
  }

  bool canPicking() => (order.lineStock ?? 0) > 0 || pickQty > 0;
}
// class PrintPickingDispatchInfo{
//  String instructionNo;
//  String orderNumber;
//  String dispatchLineNumber;
//  String dispatchDate;
//  String productionOrderNo;
//  String machineNumber;
//  String purchaseOrderNumber;
//  String purchaseOrderLineNumber;
// }
