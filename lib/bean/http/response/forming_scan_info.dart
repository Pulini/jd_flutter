// InterID : 951915
// FactoryType : "PNW25402597-04"
// CommandNumber : "JZ2502238"
// IsClose : "未关闭"
// BillDate : "2025/6/18 9:28:59"
// LastActivationTime : "2025/6/20 16:49:20"

class FormingScanInfo {
  FormingScanInfo({
      this.interID, 
      this.factoryType, 
      this.commandNumber, 
      this.isClose, 
      this.billDate, 
      this.lastActivationTime,});

  FormingScanInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    factoryType = json['FactoryType'];
    commandNumber = json['CommandNumber'];
    isClose = json['IsClose'];
    billDate = json['BillDate'];
    lastActivationTime = json['LastActivationTime'];
  }
  int? interID;
  String? factoryType;
  String? commandNumber;
  String? isClose;
  String? billDate;
  String? lastActivationTime;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['FactoryType'] = factoryType;
    map['CommandNumber'] = commandNumber;
    map['IsClose'] = isClose;
    map['BillDate'] = billDate;
    map['LastActivationTime'] = lastActivationTime;
    return map;
  }

}