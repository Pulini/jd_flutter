// EmpCode : "005384"
// EmpID : 94256
// EmpName : "陆定隆"
// EmpDepartID : 554697
// EmpDepartName : "金帝_裁断2组"
// EmpDuty : "落料"
// EmpCreatTime : "2013-05-17 10:50"
// EmpOperateTime : "2023-10-04 13:57"
// EmpLeaveStatus : 1

class SearchPeopleInfo {
  SearchPeopleInfo({
      this.empCode, 
      this.empID, 
      this.empName, 
      this.empDepartID, 
      this.empDepartName, 
      this.empDuty, 
      this.empCreatTime, 
      this.empOperateTime, 
      this.empLeaveStatus,});

  SearchPeopleInfo.fromJson(dynamic json) {
    empCode = json['EmpCode'];
    empID = json['EmpID'];
    empName = json['EmpName'];
    empDepartID = json['EmpDepartID'];
    empDepartName = json['EmpDepartName'];
    empDuty = json['EmpDuty'];
    empCreatTime = json['EmpCreatTime'];
    empOperateTime = json['EmpOperateTime'];
    empLeaveStatus = json['EmpLeaveStatus'];
  }
  String? empCode;
  int? empID;
  String? empName;
  int? empDepartID;
  String? empDepartName;
  String? empDuty;
  String? empCreatTime;
  String? empOperateTime;
  int? empLeaveStatus;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EmpCode'] = empCode;
    map['EmpID'] = empID;
    map['EmpName'] = empName;
    map['EmpDepartID'] = empDepartID;
    map['EmpDepartName'] = empDepartName;
    map['EmpDuty'] = empDuty;
    map['EmpCreatTime'] = empCreatTime;
    map['EmpOperateTime'] = empOperateTime;
    map['EmpLeaveStatus'] = empLeaveStatus;
    return map;
  }

}