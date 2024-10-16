/// exNumber : "SCPZYCD200000094"
/// billDate : "2020/7/7 16:38:00"
/// empID : 139697
/// qty : "22"
/// exceptionID : 16
/// exceptionName : "鞋面组合歪斜、移位"
/// exceptionLevel : "轻微"
/// reCheck : "复检合格"

class Entry {
  Entry({
      this.exNumber, 
      this.billDate, 
      this.empID, 
      this.qty, 
      this.exceptionID, 
      this.exceptionName, 
      this.exceptionLevel, 
      this.reCheck,});

  Entry.fromJson(dynamic json) {
    exNumber = json['exNumber'];
    billDate = json['billDate'];
    empID = json['empID'];
    qty = json['qty'];
    exceptionID = json['exceptionID'];
    exceptionName = json['exceptionName'];
    exceptionLevel = json['exceptionLevel'];
    reCheck = json['reCheck'];
  }
  String? exNumber;
  String? billDate;
  int? empID;
  String? qty;
  int? exceptionID;
  String? exceptionName;
  String? exceptionLevel;
  String? reCheck;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exNumber'] = exNumber;
    map['billDate'] = billDate;
    map['empID'] = empID;
    map['qty'] = qty;
    map['exceptionID'] = exceptionID;
    map['exceptionName'] = exceptionName;
    map['exceptionLevel'] = exceptionLevel;
    map['reCheck'] = reCheck;
    return map;
  }

}