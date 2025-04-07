class ProcessPlanInfo {
  ProcessPlanInfo({
    this.interID,
    this.decrementNumber,
    this.dispatchNumber,
    this.materialNumber,
    this.materialName,
    this.shift,
  });

  ProcessPlanInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    decrementNumber = json['DecrementNumber'];
    dispatchNumber = json['DispatchNumber'];
    materialNumber = json['MaterialNumber'];
    materialName = json['MaterialName'];
    shift = json['Shift'];
  }

  int? interID;
  String? decrementNumber;  //递减单号
  String? dispatchNumber;  //派工单号
  String? materialNumber;  //物料编码
  String? materialName;  //物料名称
  String? shift;  //物料名称

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['DecrementNumber'] = decrementNumber;
    map['DispatchNumber'] = dispatchNumber;
    map['MaterialNumber'] = materialNumber;
    map['MaterialName'] = materialName;
    map['Shift'] = shift;
    return map;
  }
}
