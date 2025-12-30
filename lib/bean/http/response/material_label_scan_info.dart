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

  }

  int? interID;
  int? materialID;
  String? materialNumber;
  String? materialName;
  int? srcICMOInterID;
  String? mtoNo;
  String? size;
  double? orderQty;
  double? qtyReceived;
  double? unclaimedQty;


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

    return map;
  }
}

