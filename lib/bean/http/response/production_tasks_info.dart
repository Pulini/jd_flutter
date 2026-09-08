import 'package:decimal/decimal.dart';
import 'package:jd_flutter/utils/extension_util.dart';

//{
//   "DeptID": "1020110",
//   "WorkCardInterID": "213589",
//   "WorkCardNo": "P2049140",
//   "MapNumber": "",
//   "ClientOrderNumber": "2025010800001",
//   "MoID": "177580",
//   "MtoNo": "F2500001",
//   "ProductName": "D13677-22B M",
//   "Color": "",
//   "PriorityLevel": "1",
//   "IsClose": false,
//   "ItemImage": "http://geapptest.goldemperor.com:8083/金帝集团股份有限公司/型体/2022/1/D13677-22BM/D13677-22BM.jpg",
//   "ToDayPlanQty": 0.0,
//   "ToDayFinishQty": 0.0,
//   "FinishQtyTotal": 0.0,
//   "EntryFID": "556312",
//   "ScWorkCardSizeInfos": [
//     {
//       "Size": "36",
//       "Qty": 100.0,
//       "ProductScannedQty": 0.0,
//       "ManualScannedQty": 0.0,
//       "ScannedQty": 0.0,
//       "InstalledQty": 4.0,
//       "TodayScannedQty": 0.0
//     },
//   ],
//   "SizeRelations": [
//    {
// 	    "Size": "38",
//  	  "BarCode": "12023000070119"
//    }
//   ]
class ProductionTasksInfo {
  String? deptID; //部门ID
  double? toDayPlanQty; //今日任务数
  double? toDayFinishQty; //今日完成数
  double? toMonthPlanQty; //月任务数
  double? toMonthFinishQty; //月完成数
  List<ProductionTasksSubInfo>? subInfo;

  ProductionTasksInfo({
    this.deptID,
    this.toDayPlanQty,
    this.toDayFinishQty,
    this.toMonthPlanQty,
    this.toMonthFinishQty,
    this.subInfo,
  });

  ProductionTasksInfo.fromJson(dynamic json) {
    deptID = JsonParse.str(json['DeptID']);
    toDayPlanQty = JsonParse.toDouble(json['ToDayPlanQty']);
    toDayFinishQty = JsonParse.toDouble(json['ToDayFinishQty']);
    toMonthPlanQty = JsonParse.toDouble(json['ToMonthPlanQty']);
    toMonthFinishQty = JsonParse.toDouble(json['ToMonthFinishQty']);
    subInfo = JsonParse.list(json['ScWorkCardInfos'], ProductionTasksSubInfo.fromJson);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptID'] = deptID;
    map['ToDayPlanQty'] = toDayPlanQty;
    map['ToDayFinishQty'] = toDayFinishQty;
    map['ToMonthPlanQty'] = toMonthPlanQty;
    map['ToMonthFinishQty'] = toMonthFinishQty;
    if (subInfo != null) {
      map['ScWorkCardInfos'] = subInfo!.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

class ProductionTasksSubInfo {
  String? workCardInterID; //生产派工单ID
  String? workCardNo; //生产派工单号
  String? mapNumber; //客户货号
  String? clientOrderNumber; //客户订单号
  String? moID; //指令ID
  String? mtoNo; //指令号
  String? productName; //型体名称
  String? color; //型体颜色
  String? shoeStyle; //鞋款
  String? priorityLevel; //派工单优先级
  bool? isClose;
  String? itemImage; //型体图片
  double? finishQtyTotal; //累计完成数
  double? shouldPackQty; //应装箱数
  double? packagedQty; //装箱数
  bool? existOutBoxBarCode; //外箱标扫码状态
  List<String>? packetWay; //装箱方式
  List<String>? specificRequirements; //客人需求
  String? entryFID;
  List<WorkCardSizeInfos>? workCardSizeInfo;

  ProductionTasksSubInfo({
    this.workCardInterID,
    this.workCardNo,
    this.mapNumber,
    this.clientOrderNumber,
    this.moID,
    this.mtoNo,
    this.productName,
    this.color,
    this.shoeStyle,
    this.priorityLevel,
    this.isClose,
    this.itemImage,
    this.finishQtyTotal,
    this.shouldPackQty,
    this.packagedQty,
    this.packetWay,
    this.specificRequirements,
    this.entryFID,
    this.workCardSizeInfo,
  });

  ProductionTasksSubInfo.fromJson(dynamic json) {
    workCardInterID = JsonParse.str(json['WorkCardInterID']);
    workCardNo = JsonParse.str(json['WorkCardNo']);
    mapNumber = JsonParse.str(json['MapNumber']);
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    moID = JsonParse.str(json['MoID']);
    mtoNo = JsonParse.str(json['MtoNo']);
    productName = JsonParse.str(json['ProductName']);
    color = JsonParse.str(json['Color']);
    shoeStyle = JsonParse.str(json['ShoeStyle']);
    priorityLevel = JsonParse.str(json['PriorityLevel']);
    isClose = JsonParse.toBool(json['IsClose']);
    itemImage = JsonParse.str(json['ItemImage']);
    finishQtyTotal = JsonParse.toDouble(json['FinishQtyTotal']);
    shouldPackQty = JsonParse.toDouble(json['NPTotal']);
    existOutBoxBarCode = JsonParse.toBool(json['ExistOutBoxBarCode']);
    packagedQty = JsonParse.toDouble(json['HasInstall']);
    if (json['PacketWay'] != null) {
      packetWay = [];
      json['PacketWay'].forEach((v) {
        packetWay!.add(v);
      });
    }
    if (json['SpecificRequirements'] != null) {
      specificRequirements = [];
      json['SpecificRequirements'].forEach((v) {
        specificRequirements!.add(v);
      });
    }
    entryFID = JsonParse.str(json['EntryFID']);
    workCardSizeInfo = JsonParse.list(json['ScWorkCardSizeInfos'], WorkCardSizeInfos.fromJson);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkCardInterID'] = workCardInterID;
    map['WorkCardNo'] = workCardNo;
    map['MapNumber'] = mapNumber;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['MoID'] = moID;
    map['MtoNo'] = mtoNo;
    map['ProductName'] = productName;
    map['Color'] = color;
    map['ShoeStyle'] = shoeStyle;
    map['PriorityLevel'] = priorityLevel;
    map['IsClose'] = isClose;
    map['ItemImage'] = itemImage;
    map['FinishQtyTotal'] = finishQtyTotal;
    map['NPTotal'] = shouldPackQty;
    map['HasInstall'] = packagedQty;
    map['PacketWay'] = packetWay;
    map['SpecificRequirements'] = specificRequirements;
    map['EntryFID'] = entryFID;
    if (workCardSizeInfo != null) {
      map['ScWorkCardSizeInfos'] =
          workCardSizeInfo!.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

// Size : "38"
// Qty : 100.0000000000
// ScannedQty : 0.0

class WorkCardSizeInfos {
  WorkCardSizeInfos({
    this.size,
    this.qty,
    this.productScannedQty,
    this.manualScannedQty,
    this.totalQty,
    this.scanTotalQty,
    this.noFullInstalledQty,
  });

  WorkCardSizeInfos.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    productScannedQty = JsonParse.toDouble(json['ProductScannedQty']);
    manualScannedQty = JsonParse.toDouble(json['ManualScannedQty']);
    totalQty = JsonParse.toDouble(json['ScannedQty']);
    scanTotalQty = JsonParse.toDouble(json['InstalledQty']);
    noFullInstalledQty = JsonParse.toDouble(json['NoFullInstalledQty']);
  }

  String? size; //尺码
  double? qty; //派工数量
  double? productScannedQty; //产线扫描数量
  double? manualScannedQty; //手动扫描数
  double? totalQty; //累计双数
  double? scanTotalQty; //扫箱累计双输
  double? noFullInstalledQty; //不满箱双数

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['ProductScannedQty'] = productScannedQty;
    map['ManualScannedQty'] = manualScannedQty;
    map['ScannedQty'] = totalQty;
    map['InstalledQty'] = scanTotalQty;
    map['NoFullInstalledQty'] = noFullInstalledQty;
    return map;
  }

  double getProductionOwe() => qty!.sub(productScannedQty ?? 0).sub(manualScannedQty ?? 0);
  double getPackOwe() => qty!.sub(totalQty?? 0);

  String getCompletionRate() =>
      '${Decimal.parse(((1 - getPackOwe() / qty!) * 100).toStringAsFixed(2))}%';

  double scannedNotInstalled() => totalQty.sub(scanTotalQty ?? 0);

  void addProductScannedQty(double qty) {
    productScannedQty = productScannedQty.add(qty);
    totalQty = totalQty.add(qty);
  }

  void addManualScannedQty(double qty) {
    manualScannedQty = manualScannedQty.add(qty);
    totalQty = totalQty.add(qty);
  }

  void addInstalledQty(double qty) {
    scanTotalQty = scanTotalQty.add(qty);
  }
}

//{
// 	"BillNo": "JZ2400002",
// 	"ClientOrderNumber": "202301040002",
// 	"Total": 100.0,
// 	"HasInstall": 0.0,
// 	"ScheduleInfos": [{
// 			"Size": "35",
// 			"Qty": 300.0,
// 			"ProductScannedQty": 0.0,
// 			"ManualScannedQty": 0.0,
// 			"ScannedQty": 0.0,
// 			"InstalledQty": 0.0
// 		}
// 	]
// }
class ProductionTasksDetailInfo {
  String? billNo;
  String? clientOrderNumber;
  double? total;
  double? hasInstall;
  List<String>? packetWay; //装箱方式
  List<String>? specificRequirements; //客人需求
  List<ProductionTasksDetailItemInfo>? scheduleInfos;

  ProductionTasksDetailInfo({
    this.billNo,
    this.clientOrderNumber,
    this.total,
    this.hasInstall,
    this.packetWay,
    this.specificRequirements,
    this.scheduleInfos,
  });

  ProductionTasksDetailInfo.fromJson(dynamic json) {
    billNo = JsonParse.str(json['BillNo']);
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    total = JsonParse.toDouble(json['Total']);
    hasInstall = JsonParse.toDouble(json['HasInstall']);
    if (json['PacketWay'] != null) {
      packetWay = [];
      json['PacketWay'].forEach((v) {
        packetWay!.add(v);
      });
    }
    if (json['SpecificRequirements'] != null) {
      specificRequirements = [];
      json['SpecificRequirements'].forEach((v) {
        specificRequirements!.add(v);
      });
    }
    scheduleInfos = JsonParse.list(json['ScheduleInfos'], ProductionTasksDetailItemInfo.fromJson);
  }
}

class ProductionTasksDetailItemInfo {
  String? size;
  double? qty;
  double? productScannedQty;
  double? manualScannedQty;
  double? scannedQty;
  double? installedQty;

  ProductionTasksDetailItemInfo({
    this.size,
    this.qty,
    this.productScannedQty,
    this.manualScannedQty,
    this.scannedQty,
    this.installedQty,
  });

  ProductionTasksDetailItemInfo.fromJson(dynamic json) {
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    productScannedQty = JsonParse.toDouble(json['ProductScannedQty']);
    manualScannedQty = JsonParse.toDouble(json['ManualScannedQty']);
    scannedQty = JsonParse.toDouble(json['ScannedQty']);
    installedQty = JsonParse.toDouble(json['InstalledQty']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['ProductScannedQty'] = productScannedQty;
    map['ManualScannedQty'] = manualScannedQty;
    map['ScannedQty'] = scannedQty;
    map['InstalledQty'] = installedQty;
    return map;
  }

  double getOwe() => qty! - scannedQty!;

  String getCompletionRate() =>
      '${Decimal.parse(((1 - getOwe() / qty!) * 100).toStringAsFixed(2))}%';

  double scannedNotInstalled() => scannedQty.sub(installedQty ?? 0);
}

class ProductionTasksPackMaterialInfo {
  String? customerPo; //ZZKHPO1  客户PO
  String? purchaseType; //ZZCGFL 采购分类
  String? customerGoodsNo; //ZZKHHH 客人货号
  String? materialCode; //MATNR  物料编码
  String? materialName; //MAKTX  物料描述
  String? unit; //MEINS  单位
  double? demandQty; //ZZXQSL 需求用量
  double? inventoryQty; //WEMNG  入库数量
  double? receivedQty; //ZZSJLL 已领数量

  ProductionTasksPackMaterialInfo({
    this.customerPo,
    this.purchaseType,
    this.customerGoodsNo,
    this.materialCode,
    this.materialName,
    this.unit,
    this.demandQty,
    this.inventoryQty,
    this.receivedQty,
  });
  ProductionTasksPackMaterialInfo.fromJson(dynamic json) {
    customerPo = JsonParse.str(json['ZZKHPO1']);
    purchaseType = JsonParse.str(json['ZZCGFL']);
    customerGoodsNo = JsonParse.str(json['ZZKHHH']);
    materialCode = JsonParse.str(json['MATNR']);
    materialName = JsonParse.str(json['MAKTX']);
    unit = JsonParse.str(json['MEINS']);
    demandQty = JsonParse.toDouble(json['ZZXQSL']);
    inventoryQty = JsonParse.toDouble(json['WEMNG']);
    receivedQty = JsonParse.toDouble(json['ZZSJLL']);
  }
}

//{
// 	"Number": "20250214110250694001",
// 	"MoID": "381952",
// 	"WorkCardID": "854437",
// 	"ClientOrderNumber": "4801162355",
// 	"Size": "12",
// 	"BarCode": "4065449966627",
// 	"ScanTime": "2025-02-11T16:37:59",
// 	"ScannerName": "",
// 	"ScannerIP": "",
// 	"ScanTypeID": "1",
// 	"DeptmentID": "492312",
// 	"Sid": "F368FF08-8FC3-49A9-85D0-0000007F081B"
// }
class MqttMsgInfo {
  String? number; //序号
  String? moID; //指令ID
  String? workCardID; //生产派工单ID
  String? clientOrderNumber; //客户订单号
  String? size; //尺码
  double? qty; //数量
  String? scanTypeID; //扫码枪类型 1扫码枪，2井松、3山腾

  MqttMsgInfo({
    this.number,
    this.moID,
    this.workCardID,
    this.clientOrderNumber,
    this.size,
    this.qty,
    this.scanTypeID,
  });

  MqttMsgInfo.fromJson(dynamic json) {
    number = JsonParse.str(json['Number']);
    moID = JsonParse.str(json['MoID']);
    workCardID = JsonParse.str(json['WorkCardID']);
    clientOrderNumber = JsonParse.str(json['ClientOrderNumber']);
    size = JsonParse.str(json['Size']);
    qty = JsonParse.toDouble(json['Qty']);
    scanTypeID = JsonParse.str(json['ScanTypeID']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Number'] = number;
    map['MoID'] = moID;
    map['WorkCardID'] = workCardID;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['Size'] = size;
    map['Qty'] = qty;
    map['ScanTypeID'] = scanTypeID;
    return map;
  }
}
