import 'package:jd_flutter/utils/extension_util.dart';
// EmpCode : "013600"
// EmpID : 137035
// EmpName : "潘卓旭"
// EmpDepartID : 554911
// EmpDepartName : "软件开发课"
// EmpDuty : "程序员"
// EmpCreatTime : "2018-04-19 16:45"
// EmpOperateTime : "2023-08-07 15:24"
// EmpLeaveStatus : 1
// PicUrl : "https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2018/4/潘卓旭/013600.jpg"

class WorkerInfo {
  WorkerInfo({
      this.empCode, 
      this.empID, 
      this.empName, 
      this.empDepartID, 
      this.empDepartName, 
      this.empDuty, 
      this.empCreatTime, 
      this.empOperateTime, 
      this.empLeaveStatus, 
      this.picUrl,});

  WorkerInfo.fromJson(dynamic json) {
    empCode = JsonParse.str(json['EmpCode']);
    empID = JsonParse.toInt(json['EmpID']);
    empName = JsonParse.str(json['EmpName']);
    empDepartID = JsonParse.toInt(json['EmpDepartID']);
    empDepartName = JsonParse.str(json['EmpDepartName']);
    empDuty = JsonParse.str(json['EmpDuty']);
    empCreatTime = JsonParse.str(json['EmpCreatTime']);
    empOperateTime = JsonParse.str(json['EmpOperateTime']);
    empLeaveStatus = JsonParse.toInt(json['EmpLeaveStatus']);
    picUrl = JsonParse.str(json['PicUrl']);
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
  String? picUrl;

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
    map['PicUrl'] = picUrl;
    return map;
  }

  WorkerInfo deepCopy() {
    return WorkerInfo.fromJson(toJson());
  }
}