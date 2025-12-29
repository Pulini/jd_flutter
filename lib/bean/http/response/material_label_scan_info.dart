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
