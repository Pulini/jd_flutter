
class LeaderInfo {
  LeaderInfo({
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

  LeaderInfo.fromJson(dynamic json) {
    deptName=json['DeptName'];
    departmentID=json['DepartmentID'];
    empCode=json['EmpCode'];
    empID=json['EmpID'];
    empName=json['EmpName'];
    liableEmpCode=json['LiableEmpCode'];
    liableEmpID=json['LiableEmpID'];
    liableEmpName=json['LiableEmpName'];
    liablePicturePath=json['LiablePicturePath'];
    orgName=json['OrgName'];
    picturePath=json['PicturePath'];
  }

  String? deptName;
  int? departmentID;
  String? empCode;
  int? empID;
  String? empName;
  String? liableEmpCode;
  int? liableEmpID;
  String? liableEmpName;
  String? liablePicturePath;
  String? orgName;
  String? picturePath;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DeptName']=deptName;
    map['DepartmentID']=departmentID;
    map['EmpCode']=empCode;
    map['EmpID']=empID;
    map['EmpName']=empName;
    map['LiableEmpCode']=liableEmpCode;
    map['LiableEmpID']=liableEmpID;
    map['LiableEmpName']=liableEmpName;
    map['LiablePicturePath']=liablePicturePath;
    map['OrgName']=orgName;
    map['PicturePath']=picturePath;
    return map;
  }

  @override
  String toString() {
    return liableEmpName ?? '';
  }
}
