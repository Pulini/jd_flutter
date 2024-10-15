/// exNumber : "SCPZYCD240000009"
/// empName : "叶明杰"
/// empNumber : "019766"
/// FQty : 1.0
/// FExceptionID : 14
/// exceptionName : "刷胶不均匀"
/// FExceptionLevel : 0
/// FReCheck : ""

class AddEntryDetailInfo {
  AddEntryDetailInfo({
      this.exNumber, 
      this.empName, 
      this.billDate,
      this.empID,
      this.empNumber,
      this.fQty, 
      this.fExceptionID, 
      this.exceptionName, 
      this.fExceptionLevel, 
      this.fReCheck,});

  AddEntryDetailInfo.fromJson(dynamic json) {
    exNumber = json['exNumber'];
    billDate = json['billDate'];
    empID = json['empID'];
    empName = json['empName'];
    empNumber = json['empNumber'];
    fQty = json['FQty'];
    fExceptionID = json['FExceptionID'];
    exceptionName = json['exceptionName'];
    fExceptionLevel = json['FExceptionLevel'];
    fReCheck = json['FReCheck'];
  }
  String? exNumber;
  String? billDate;
  int? empID;
  String? empName;
  String? empNumber;
  double? fQty;
  int? fExceptionID;
  String? exceptionName;
  int? fExceptionLevel;
  String? fReCheck;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exNumber'] = exNumber;
    map['empID'] = empID;
    map['billDate'] = billDate;
    map['empName'] = empName;
    map['empNumber'] = empNumber;
    map['FQty'] = fQty;
    map['FExceptionID'] = fExceptionID;
    map['exceptionName'] = exceptionName;
    map['FExceptionLevel'] = fExceptionLevel;
    map['FReCheck'] = fReCheck;
    return map;
  }

}