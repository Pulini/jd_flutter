import 'package:jd_flutter/utils/extension_util.dart';
class PeopleMessageInfo {
  PeopleMessageInfo({
    this.deptName,
    this.departmentID,
    this.empCode,
    this.empID,
    this.empName,
    this.liableEmpCode,
    this.liableEmpID,
    this.liableEmpName,
    this.liablePicturePath,
    this.orgName,
    this.picturePath,
  });

  PeopleMessageInfo.fromJson(dynamic json) {
    deptName = JsonParse.str(json['DeptName']);
    departmentID = JsonParse.toInt(json['DepartmentID']);
    empCode = JsonParse.str(json['EmpCode']);
    empID = JsonParse.toInt(json['EmpID']);
    empName = JsonParse.str(json['EmpName']);
    liableEmpCode = JsonParse.str(json['LiableEmpCode']);
    liableEmpID = JsonParse.toInt(json['LiableEmpID']);
    liableEmpName = JsonParse.str(json['LiableEmpName']);
    liablePicturePath = JsonParse.str(json['LiablePicturePath']);
    orgName = JsonParse.str(json['OrgName']);
    picturePath = JsonParse.str(json['PicturePath']);
  }

  String? deptName;  //部门名称
  int? departmentID; //部门id
  String? empCode; //员工id
  int? empID; //员工工号
  String? empName; //员工名字
  String? liableEmpCode;
  int? liableEmpID;
  String? liableEmpName;
  String? liablePicturePath;
  String? orgName;//组织名称
  String? picturePath;//照片地址

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptName'] = deptName;
    map['DepartmentID'] = departmentID;
    map['EmpCode'] = empCode;
    map['EmpID'] = empID;
    map['EmpName'] = empName;
    map['LiableEmpCode'] = liableEmpCode;
    map['LiableEmpID'] = liableEmpID;
    map['LiableEmpName'] = liableEmpName;
    map['LiablePicturePath'] = liablePicturePath;
    map['OrgName'] = orgName;
    map['PicturePath'] = picturePath;
    return map;
  }
}
