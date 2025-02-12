class DeviceMaintenanceListInfo {
  DeviceMaintenanceListInfo({
    this.billDate,
    this.biller,
    this.custodian,
    this.deviceName,
    this.deviceNo,
    this.interID,
    this.number,
    this.repairUnit,
    this.voidDate,
    this.voider,
    this.voidReason,
  });

  DeviceMaintenanceListInfo.fromJson(dynamic json) {
    billDate = json['BillDate'];
    biller = json['Biller'];
    custodian = json['Custodian'];
    deviceName = json['DeviceName'];
    deviceNo = json['DeviceNo'];
    interID = json['InterID'];
    number = json['Number'];
    repairUnit = json['RepairUnit'];
    voidDate = json['VoidDate'];
    voider = json['Voider'];
    voidReason = json['VoidReason'];

  }

  String? billDate; //制单时间
  String? biller; //制单人
  String? custodian; //保管人
  String? deviceName; //设备名称
  String? deviceNo; //设备编号
  int? interID; //设备编号
  String? number; //设备编号
  String? repairUnit; //维修单位
  String? voidDate; //作废时间
  String? voider; //作废人
  String? voidReason; //作废原因


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BillDate'] = billDate;
    map['Biller'] = biller;
    map['Custodian'] = custodian;
    map['DeviceName'] = deviceName;
    map['DeviceNo'] = deviceNo;
    map['InterID'] = interID;
    map['Number'] = number;
    map['RepairUnit'] = repairUnit;
    map['VoidDate'] = voidDate;
    map['Voider'] = voider;
    map['VoidReason'] = voidReason;
    return map;
  }
}







