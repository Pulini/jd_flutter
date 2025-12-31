class MaterialLabelScanInfo {
  MaterialLabelScanInfo({
    this.interID,
    this.workCardNo,
    this.materialID,
    this.materialNumber,
    this.materialName,
    this.mtoNo,
    this.noticeDate,
    this.dispatchQty,
    this.matReqStatus,

  });

  MaterialLabelScanInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    workCardNo = json['WorkCardNo'];
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    mtoNo = json['MtoNo'];
    noticeDate = json['NoticeDate'];
    dispatchQty = json['DispatchQty'];
    matReqStatus = json['MatReqStatus'];

  }

  int? interID;
  String? workCardNo;
  int? materialID;
  String? materialNumber;
  String? materialName;
  String? mtoNo;
  String? noticeDate;
  double? dispatchQty;
  int? matReqStatus;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['WorkCardNo'] = workCardNo;
    map['MaterialID'] = materialID;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['MtoNo'] = mtoNo;
    map['NoticeDate'] = noticeDate;
    map['DispatchQty'] = dispatchQty;
    map['MatReqStatus'] = matReqStatus;

    return map;
  }
}

class MaterialLabelScanDetailInfo {
  MaterialLabelScanDetailInfo({
    this.interID,
    this.materialID,
    this.materialNumber,
    this.materialName,
    this.srcICMOInterID,
    this.mtoNo,
    this.size,
    this.orderQty,
    this.qtyReceived,
    this.unclaimedQty,
    this.productName,
    this.workCardNo,
    this.unitName,
  });

  MaterialLabelScanDetailInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    srcICMOInterID = json['SrcICMOInterID'];
    mtoNo = json['MtoNo'];
    size = json['Size'];
    orderQty = json['OrderQty'];
    qtyReceived = json['QtyReceived'];
    unclaimedQty = json['UnclaimedQty'];
    productName = json['ProductName'];
    workCardNo = json['WorkCardNo'];
    unitName = json['UnitName'];
  }

  int? interID;
  String? workCardNo;
  int? materialID;
  String? productName;
  String? materialNumber;
  String? materialName;
  int? srcICMOInterID;
  String? mtoNo;
  String? size;
  double? orderQty;  //订单数量
  double? qtyReceived; //已领
  double? unclaimedQty; //未领
  double? thisTime=0.0; //本次
  String? unitName;
  bool isScan = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['MaterialID'] = materialID;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['MtoNo'] = mtoNo;
    map['Size'] = size;
    map['OrderQty'] = orderQty;
    map['QtyReceived'] = qtyReceived;
    map['UnclaimedQty'] = unclaimedQty;
    map['ProductName'] = productName;
    map['WorkCardNo'] = workCardNo;
    map['UnitName'] = unitName;

    return map;
  }
}

class MaterialLabelScanBarCodeInfo {
  MaterialLabelScanBarCodeInfo({
    this.materialID,
    this.materialNumber,
    this.materialName,
    this.srcICMOInterID,
    this.size,
    this.barCodeQty,

  });

  MaterialLabelScanBarCodeInfo.fromJson(dynamic json) {
    materialID = json['MaterialID'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    srcICMOInterID = json['SrcICMOInterID'];
    size = json['Size'];
    barCodeQty = json['BarCodeQty'];

  }

  int? srcICMOInterID;
  int? materialID;
  String? productName;
  String? materialNumber;
  String? materialName;
  String? size;
  double? barCodeQty;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SrcICMOInterID'] = srcICMOInterID;
    map['MaterialID'] = materialID;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['Size'] = size;
    map['BarCodeQty'] = barCodeQty;


    return map;
  }
}

