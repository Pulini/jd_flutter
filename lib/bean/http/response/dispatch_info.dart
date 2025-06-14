// CardNo : "GXPG25196000/1"
// // EmpID : 213708
// // EmpNumber : "035783"
// // EmpName : "李含雷"
// // Qty : 2111.000

class DispatchInfo {
  DispatchInfo({
      this.cardNo, 
      this.empID, 
      this.empNumber, 
      this.empName, 
      this.qty,});

  DispatchInfo.fromJson(dynamic json) {
    cardNo = json['CardNo'];
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
    qty = json['Qty'];
  }
  String? cardNo;
  int? empID;
  String? empNumber;
  String? empName;
  double? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['CardNo'] = cardNo;
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    map['Qty'] = qty;
    return map;
  }

}