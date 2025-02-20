// exNumber : "SCPZYCD240000009"
// empName : "叶明杰"
// empNumber : "019766"
// FQty : 1.0
// FExceptionID : 14
// exceptionName : "刷胶不均匀"
// FExceptionLevel : 0
// FReCheck : ""

class AddEntryDetailInfo {
  AddEntryDetailInfo({
      this.exNumber, 
      this.empName, 
      this.billDate,
      this.empID,
      this.empNumber,
      this.qty,
      this.exceptionID,
      this.exceptionName, 
      this.exceptionLevel,
      this.reCheck,});

  AddEntryDetailInfo.fromJson(dynamic json) {
    exNumber = json['exNumber'];
    billDate = json['billDate'];
    empID = json['empID'];
    empName = json['empName'];
    empNumber = json['empNumber'];
    qty = json['qty'];
    exceptionID = json['exceptionID'];
    exceptionName = json['exceptionName'];
    exceptionLevel = json['exceptionLevel'];
    reCheck = json['reCheck'];
  }
  String? exNumber;
  String? billDate;
  int? empID;
  String? empName;
  String? empNumber;
  double? qty;
  int? exceptionID;
  String? exceptionName;
  String? exceptionLevel;
  String? reCheck;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exNumber'] = exNumber;
    map['empID'] = empID;
    map['billDate'] = billDate;
    map['empName'] = empName;
    map['empNumber'] = empNumber;
    map['qty'] = qty;
    map['exceptionID'] = exceptionID;
    map['exceptionName'] = exceptionName;
    map['exceptionLevel'] = exceptionLevel;
    map['reCheck'] = reCheck;
    return map;
  }

}