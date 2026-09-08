import 'package:jd_flutter/utils/extension_util.dart';
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
    billDate = JsonParse.str(json['BillDate']);
    biller = JsonParse.str(json['Biller']);
    custodian = JsonParse.str(json['Custodian']);
    deviceName = JsonParse.str(json['DeviceName']);
    deviceNo = JsonParse.str(json['DeviceNo']);
    interID = JsonParse.toInt(json['InterID']);
    number = JsonParse.str(json['Number']);
    repairUnit = JsonParse.str(json['RepairUnit']);
    voidDate = JsonParse.str(json['VoidDate']);
    voider = JsonParse.str(json['Voider']);
    voidReason = JsonParse.str(json['VoidReason']);

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







