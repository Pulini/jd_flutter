import 'package:decimal/decimal.dart';
import 'package:jd_flutter/utils/utils.dart';
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
class ProductionTasksInfo{
  String? deptID;//部门ID
  double? toDayPlanQty;//今日任务数
  double? toDayFinishQty;//今日完成数
  double? toMonthFinishQty;//月完成数
  List<ProductionTasksSubInfo>? subInfo;

  ProductionTasksInfo({
    this.deptID,
    this.toDayPlanQty,
    this.toDayFinishQty,
    this.toMonthFinishQty,
    this.subInfo,
  });

  ProductionTasksInfo.fromJson(dynamic json) {
    deptID = json['DeptID'];
    toDayPlanQty = json['ToDayPlanQty'];
    toDayFinishQty = json['ToDayFinishQty'];
    toMonthFinishQty = json['FinishQtyTotal'];
    if (json['ScWorkCardInfos'] != null) {
      subInfo = [];
      json['ScWorkCardInfos'].forEach((v) {
        subInfo!.add(ProductionTasksSubInfo.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptID'] = deptID;
    map['ToDayPlanQty'] = toDayPlanQty;
    map['ToDayFinishQty'] = toDayFinishQty;
    map['FinishQtyTotal'] = toMonthFinishQty;
    if (subInfo != null) {
      map['ScWorkCardInfos'] = subInfo!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class ProductionTasksSubInfo {
  String? workCardInterID;//生产派工单ID
  String? workCardNo;//生产派工单号
  String? mapNumber;//客户货号
  String? clientOrderNumber;//客户订单号
  String? moID;//指令ID
  String? mtoNo;//指令号
  String? productName;//型体名称
  String? color;//型体颜色
  String? priorityLevel;//派工单优先级
  bool? isClose;
  String? itemImage;//型体图片
  double? finishQtyTotal;//累计完成数
  double? shouldPackQty;//应装箱数
  double? packagedQty;//应装箱数
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
    this.priorityLevel,
    this.isClose,
    this.itemImage,
    this.finishQtyTotal,
    this.shouldPackQty,
    this.packagedQty,
    this.entryFID,
    this.workCardSizeInfo,
  });

  ProductionTasksSubInfo.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    workCardNo = json['WorkCardNo'];
    mapNumber = json['MapNumber'];
    clientOrderNumber = json['ClientOrderNumber'];
    moID = json['MoID'];
    mtoNo = json['MtoNo'];
    productName = json['ProductName'];
    color = json['Color'];
    priorityLevel = json['PriorityLevel'];
    isClose = json['IsClose'];
    itemImage = json['ItemImage'];
    finishQtyTotal = json['FinishQtyTotal'];
    shouldPackQty = json['NPTotal'];
    packagedQty = json['HasInstall'];
    entryFID = json['EntryFID'];
    if (json['ScWorkCardSizeInfos'] != null) {
      workCardSizeInfo = [];
      json['ScWorkCardSizeInfos'].forEach((v) {
        workCardSizeInfo!.add(WorkCardSizeInfos.fromJson(v));
      });
    }

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
    map['PriorityLevel'] = priorityLevel;
    map['IsClose'] = isClose;
    map['ItemImage'] = itemImage;
    map['FinishQtyTotal'] = finishQtyTotal;
    map['NPTotal'] = shouldPackQty;
    map['HasInstall'] = packagedQty;
    map['EntryFID'] = entryFID;
    if (workCardSizeInfo != null) {
      map['ScWorkCardSizeInfos'] =
          workCardSizeInfo!.map((v) => v.toJson()).toList();
    }

    return map;
  }
}

/// Size : "38"
/// Qty : 100.0000000000
/// ScannedQty : 0.0

class WorkCardSizeInfos {
  WorkCardSizeInfos({
    this.size,
    this.qty,
    this.productScannedQty,
    this.manualScannedQty,
    this.scannedQty,
    this.installedQty,
  });

  WorkCardSizeInfos.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    productScannedQty = json['ProductScannedQty'];
    manualScannedQty = json['ManualScannedQty'];
    scannedQty = json['ScannedQty'];
    installedQty = json['InstalledQty'];
  }

  String? size; //尺码
  double? qty; //派工数量
  double? productScannedQty; //产线扫描数量
  double? manualScannedQty; //手动扫描数
  double? scannedQty; //已扫数量
  double? installedQty; //已装数量

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

  double getOwe() =>qty! - scannedQty!;

  String getCompletionRate() =>'${Decimal.parse(((1 - getOwe() / qty!) * 100).toStringAsFixed(2))}%';

  double scannedNotInstalled()=>scannedQty.sub(installedQty??0);
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
class ProductionTasksDetailInfo{
  String? billNo;
  String? clientOrderNumber;
  double? total;
  double? hasInstall;
  List<ProductionTasksDetailItemInfo>? scheduleInfos;

  ProductionTasksDetailInfo({
    this.billNo,
    this.clientOrderNumber,
    this.total,
    this.hasInstall,
    this.scheduleInfos,
  });

  ProductionTasksDetailInfo.fromJson(dynamic json) {
    billNo = json['BillNo'];
    clientOrderNumber = json['ClientOrderNumber'];
    total = json['Total'];
    hasInstall = json['HasInstall'];
    if (json['ScheduleInfos'] != null) {
      scheduleInfos = [];
      json['ScheduleInfos'].forEach((v) {
        scheduleInfos!.add(ProductionTasksDetailItemInfo.fromJson(v));
      });
    }
  }

}
class ProductionTasksDetailItemInfo{
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
    size = json['Size'];
    qty = json['Qty'];
    productScannedQty = json['ProductScannedQty'];
    manualScannedQty = json['ManualScannedQty'];
    scannedQty = json['ScannedQty'];
    installedQty = json['InstalledQty'];
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

  double getOwe() =>qty! - scannedQty!;

  String getCompletionRate() =>'${Decimal.parse(((1 - getOwe() / qty!) * 100).toStringAsFixed(2))}%';

  double scannedNotInstalled()=>scannedQty.sub(installedQty??0);
}
