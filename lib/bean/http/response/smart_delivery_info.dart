import 'package:jd_flutter/utils/utils.dart';

/// rowNo : 10
/// workCardInterID : 169689
/// workCardNo : "P2005162"
/// salesOrderNo : "0010000741"
/// typeBody : "DN202682-1"
/// dispatchDate : "2020-03-17"
/// dispatchQty : 600.0
/// materialIssuanceStatus : "未发料"
/// depName : "针车1组"
class SmartDeliveryOrderInfo {
  SmartDeliveryOrderInfo({
    this.rowNo,
    this.workCardInterID,
    this.workCardNo,
    this.salesOrderNo,
    this.typeBody,
    this.dispatchDate,
    this.dispatchQty,
    this.materialIssuanceStatus,
    this.depName,
    this.departmentId,
    this.instructions,
  });

  SmartDeliveryOrderInfo.fromJson(dynamic json) {
    rowNo = json['rowNo'];
    workCardInterID = json['workCardInterID'];
    workCardNo = json['workCardNo'];
    salesOrderNo = json['salesOrderNo'];
    typeBody = json['typeBody'];
    dispatchDate = json['dispatchDate'];
    dispatchQty = json['dispatchQty'];
    materialIssuanceStatus = json['materialIssuanceStatus'];
    depName = json['depName'];
    departmentId = json['depID'];
    instructions = json['mtoNo'];
  }

  int? rowNo; //行号
  int? workCardInterID; //生产派工单ID
  String? workCardNo; //派工单号
  String? salesOrderNo; //销售订单z
  String? typeBody; //工厂型体
  String? dispatchDate; //派工日期
  double? dispatchQty; //派工总量
  String? materialIssuanceStatus; //发料情况
  String? depName; //课组名称
  int? departmentId; //课组ID
  String? instructions; //指令号


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['rowNo'] = rowNo;
    map['workCardInterID'] = workCardInterID;
    map['workCardNo'] = workCardNo;
    map['salesOrderNo'] = salesOrderNo;
    map['typeBody'] = typeBody;
    map['dispatchDate'] = dispatchDate;
    map['dispatchQty'] = dispatchQty;
    map['materialIssuanceStatus'] = materialIssuanceStatus;
    map['depName'] = depName;
    map['depID'] = departmentId;
    map['mtoNo'] = instructions;
    return map;
  }
}

/// ScWorkCardInterID : 213425
/// PartsID : 665
/// MaterialID : 452550
/// PartName : "后内外边排"
/// ItemNumber : "800605186"
/// ItemName : "深蓝色7泼水超纤复0.35mm厚灰色柔软布+2*3白色帆布"
/// RequireQty : 2.634
/// SendQty : 0.0

class SmartDeliveryMaterialInfo {
  SmartDeliveryMaterialInfo({
    this.scWorkCardInterID,
    this.partsID,
    this.materialID,
    this.partName,
    this.materialNumber,
    this.materialName,
    this.requireQty,
    this.sendQty,
  });

  SmartDeliveryMaterialInfo.fromJson(dynamic json) {
    scWorkCardInterID = json['ScWorkCardInterID'];
    partsID = json['PartsID'];
    materialID = json['MaterialID'];
    partName = json['PartName'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    requireQty = json['RequireQty'];
    sendQty = json['SendQty'];
  }

  int? scWorkCardInterID;

  int? partsID;
  int? materialID;
  String? partName;
  String? materialNumber;
  String? materialName;
  double? requireQty;
  double? sendQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ScWorkCardInterID'] = scWorkCardInterID;
    map['PartsID'] = partsID;
    map['MaterialID'] = materialID;
    map['PartName'] = partName;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['RequireQty'] = requireQty;
    map['SendQty'] = sendQty;
    return map;
  }
}

class SmartDeliveryShorTreeInfo {
  SmartDeliveryShorTreeInfo({
    this.shoeTreeNo,
    this.stockID,
    this.sizeList,
  });

  SmartDeliveryShorTreeInfo.fromJson(dynamic json) {
    shoeTreeNo = json['ShoeTreeNo'];
    stockID = json['StockID'];
    if (json['SizeList'] != null) {
      sizeList = [];
      json['SizeList'].forEach((v) {
        sizeList?.add(SizeInfo.fromJson(v));
      });
    }
  }

  String? shoeTreeNo;
  String? stockID;
  List<SizeInfo>? sizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ShoeTreeNo'] = shoeTreeNo;
    map['StockID'] = stockID;
    if (sizeList != null) {
      map['SizeList'] = sizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SizeInfo {
  SizeInfo({
    this.size,
    this.qty,
  });

  SizeInfo.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
  }

  String? size;
  int? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    return map;
  }
}

/// TypeBody : "D13677-22B MB"
/// SrcICMOInterID : "156640"
/// SeOrders : "JZ2400056"
/// MapNumber : ""
/// ClientOrderNumber : ""
/// PartName : "头排"
/// MaterialName : "深蓝色1泼水超纤复0.35mm厚灰色柔软布+2*3白色帆布+0.6mm白色定型"
/// MaterialNumber : "800605185"
/// PartsSizeList : [{"Size":"36","Qty":20,"ShoeTreeQty":0},{"Size":"38","Qty":20,"ShoeTreeQty":0},{"Size":"39","Qty":20,"ShoeTreeQty":0},{"Size":"40","Qty":20,"ShoeTreeQty":0}]
/// WorkData : [{"Round":"1","SendType":0,"TaskID":"","SendSizeList":[{"Size":"39","Qty":5},{"Size":"40","Qty":5}]},{"Round":"2","SendType":0,"TaskID":"","SendSizeList":[{"Size":"37","Qty":6},{"Size":"38","Qty":6}]}]

class DeliveryDetailInfo {
  DeliveryDetailInfo({
    this.newWorkCardInterID,
    this.partsID,
    this.typeBody,
    this.seOrders,
    this.mapNumber,
    this.srcICMOInterID,
    this.clientOrderNumber,
    this.partName,
    this.materialID,
    this.materialName,
    this.materialNumber,
    this.partsSizeList,
    this.workData,
  });

  DeliveryDetailInfo.fromJson(dynamic json) {
    newWorkCardInterID = json['NewWorkCardInterID'];
    partsID = json['PartsID'];
    typeBody = json['TypeBody'];
    seOrders = json['SeOrders'];
    mapNumber = json['MapNumber'];
    srcICMOInterID = json['SrcICMOInterID'];
    clientOrderNumber = json['ClientOrderNumber'];
    partName = json['PartName'];
    materialName = json['MaterialName'];
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    if (json['PartsSizeList'] != null) {
      partsSizeList = [];
      json['PartsSizeList'].forEach((v) {
        partsSizeList?.add(PartsSizeList.fromJson(v));
      });
    }
    if (json['WorkData'] != null) {
      workData = [];
      json['WorkData'].forEach((v) {
        workData?.add(WorkData.fromJson(v));
      });
    }
  }

  String? newWorkCardInterID;
  String? partsID;
  String? typeBody;
  String? seOrders;
  String? mapNumber;
  String? srcICMOInterID;
  String? clientOrderNumber;
  String? partName;
  String? materialID;
  String? materialName;
  String? materialNumber;
  List<PartsSizeList>? partsSizeList;
  List<WorkData>? workData;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['NewWorkCardInterID'] = newWorkCardInterID;
    map['PartsID'] = partsID;
    map['TypeBody'] = typeBody;
    map['SeOrders'] = seOrders;
    map['MapNumber'] = mapNumber;
    map['SrcICMOInterID'] = srcICMOInterID;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['PartName'] = partName;
    map['MaterialID'] = materialID;
    map['MaterialName'] = materialName;
    map['MaterialNumber'] = materialNumber;
    if (partsSizeList != null) {
      map['PartsSizeList'] = partsSizeList?.map((v) => v.toJson()).toList();
    }
    if (workData != null) {
      map['WorkData'] = workData?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  bool hasDelivered() =>
      workData?.isNullOrEmpty() ? false : workData!.any((v) => v.sendType == 1);

  double getMaxRound() => partsSizeList == null
      ? 0
      : partsSizeList!.map((v) => v.getRound()).reduce((a, b) => a > b ? a : b);

  int getShoeTreeTotal() => partsSizeList == null
      ? 0
      : partsSizeList!
          .map((e) => e.shoeTreeQty ?? 0)
          .reduce((v1, v2) => v1 + v2);

  int getShoeTreeReserveTotal() => partsSizeList == null
      ? 0
      : partsSizeList!
          .map((e) => (e.shoeTreeQty ?? 0) - e.reserveShoeTreeQty)
          .reduce((v1, v2) => v1 + v2);

  int getMinShoeTreeQty() => partsSizeList == null
      ? 0
      : partsSizeList!
          .map((v) => v.shoeTreeQty ?? 0)
          .reduce((a, b) => a < b ? a : b);

  int getOrderTotal() => partsSizeList == null
      ? 0
      : partsSizeList!.map((e) => e.qty ?? 0).reduce((v1, v2) => v1 + v2);

  int getOrderMin() => partsSizeList == null
      ? 0
      : partsSizeList!.map((v) => v.qty ?? 0).reduce((a, b) => a < b ? a : b);
}

/// Round : "1"
/// SendType : 0
/// TaskID : ""
/// SendSizeList : [{"Size":"39","Qty":5},{"Size":"40","Qty":5}]

class WorkData {
  WorkData({
    this.round,
    this.sendType,
    this.taskID,
    this.sendSizeList,
  });

  WorkData.fromJson(dynamic json) {
    round = json['Round'];
    sendType = json['SendType'];
    taskID = json['TaskID'];
    if (json['SendSizeList'] != null) {
      sendSizeList = [];
      json['SendSizeList'].forEach((v) {
        sendSizeList?.add(SizeInfo.fromJson(v));
      });
    }
  }

  bool isSelected = false;

  String? round;
  int? sendType;
  String? taskID;
  List<SizeInfo>? sendSizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Round'] = round;
    map['SendType'] = sendType;
    map['TaskID'] = taskID;
    if (sendSizeList != null) {
      map['SendSizeList'] = sendSizeList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  int getTotalQty() => sendSizeList == null
      ? 0
      : sendSizeList!.map((v) => v.qty ?? 0).reduce((v1, v2) => v1 + v2);
}

/// Size : "36"
/// Qty : 20
/// ShoeTreeQty : 0

class PartsSizeList {
  PartsSizeList({
    this.size,
    this.qty,
    this.shoeTreeQty,
  });

  PartsSizeList.fromJson(dynamic json) {
    size = json['Size'];
    qty = json['Qty'];
    shoeTreeQty = json['ShoeTreeQty'];
  }

  String? size;
  int? qty;
  int? shoeTreeQty;
  int reserveShoeTreeQty = 0;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Qty'] = qty;
    map['ShoeTreeQty'] = shoeTreeQty;
    return map;
  }

  double getOrderProportion(double orderTotal) {
    if (qty == null || qty == 0) {
      return 0;
    } else {
      return qty!.toDouble().div(orderTotal);
    }
  }

  double getRound() => shoeTreeQty == 0
      ? 0
      : ((qty ?? 0) / ((shoeTreeQty ?? 0) - reserveShoeTreeQty));

  int roundDelivery() => (shoeTreeQty ?? 0) - reserveShoeTreeQty;
}

/// StartPoint : [{"PositionCode":"F1","PositionName":"工作区"},{"PositionCode":"F2","PositionName":"工作区"}]
/// EndPoint : [{"PositionCode":"F3","PositionName":"工作区"},{"PositionCode":"F4","PositionName":"工作区"},{"PositionCode":"F5","PositionName":"工作区"},{"PositionCode":"F6","PositionName":"工作区"},{"PositionCode":"F7","PositionName":"工作区"},{"PositionCode":"F8","PositionName":"工作区"},{"PositionCode":"F9","PositionName":"工作区"},{"PositionCode":"F10","PositionName":"工作区"},{"PositionCode":"F11","PositionName":"工作区"},{"PositionCode":"F12","PositionName":"工作区"},{"PositionCode":"F13","PositionName":"工作区"},{"PositionCode":"F14","PositionName":"工作区"}]

class PatchRouteInfo {
  PatchRouteInfo({
    this.startPoint,
    this.endPoint,
  });

  PatchRouteInfo.fromJson(dynamic json) {
    if (json['StartPoint'] != null) {
      startPoint = [];
      json['StartPoint'].forEach((v) {
        startPoint?.add(StartPoint.fromJson(v));
      });
    }
    if (json['EndPoint'] != null) {
      endPoint = [];
      json['EndPoint'].forEach((v) {
        endPoint?.add(EndPoint.fromJson(v));
      });
    }
  }

  List<StartPoint>? startPoint;
  List<EndPoint>? endPoint;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (startPoint != null) {
      map['StartPoint'] = startPoint?.map((v) => v.toJson()).toList();
    }
    if (endPoint != null) {
      map['EndPoint'] = endPoint?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// PositionCode : "F3"
/// PositionName : "工作区"

class EndPoint {
  EndPoint({
    this.positionCode,
    this.positionName,
  });

  EndPoint.fromJson(dynamic json) {
    positionCode = json['PositionCode'];
    positionName = json['PositionName'];
  }

  String? positionCode;
  String? positionName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PositionCode'] = positionCode;
    map['PositionName'] = positionName;
    return map;
  }
}

/// PositionCode : "F1"
/// PositionName : "工作区"

class StartPoint {
  StartPoint({
    this.positionCode,
    this.positionName,
  });

  StartPoint.fromJson(dynamic json) {
    positionCode = json['PositionCode'];
    positionName = json['PositionName'];
  }

  String? positionCode;
  String? positionName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PositionCode'] = positionCode;
    map['PositionName'] = positionName;
    return map;
  }
}

/// TaskType : "F01"
/// TaskTypName : "成型自动化5楼"

class AgvTaskInfo {
  AgvTaskInfo({
    this.taskType,
    this.taskTypeName,
  });

  AgvTaskInfo.fromJson(dynamic json) {
    taskType = json['TaskType'];
    taskTypeName = json['TaskTypeName'];
  }

  String? taskType;
  String? taskTypeName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['TaskType'] = taskType;
    map['TaskTypeName'] = taskTypeName;
    return map;
  }
}
