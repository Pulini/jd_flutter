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
    deptName = json['DeptName'];
    departmentID = json['DepartmentID'];
    empCode = json['EmpCode'];
    empID = json['EmpID'];
    empName = json['EmpName'];
    liableEmpCode = json['LiableEmpCode'];
    liableEmpID = json['LiableEmpID'];
    liableEmpName = json['LiableEmpName'];
    liablePicturePath = json['LiablePicturePath'];
    orgName = json['OrgName'];
    picturePath = json['PicturePath'];
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
