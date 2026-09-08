import 'package:jd_flutter/utils/extension_util.dart';
class LeaderConfigInfo {
  LeaderConfigInfo({
    this.isEnableFaceRecognition,
    this.leaderList,
  });

  LeaderConfigInfo.fromJson(dynamic json) {
    isEnableFaceRecognition = JsonParse.toBool(json['IsEnableFaceRecognition']);
    leaderList = json['leaderlist']
        ?.map<LeaderInfo>((e) => LeaderInfo.fromJson(e))
        .toList();
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['IsEnableFaceRecognition'] = isEnableFaceRecognition;
    if (leaderList != null) {
      map['leaderlist'] = leaderList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  bool? isEnableFaceRecognition;
  List<LeaderInfo>? leaderList;
}

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

  @override
  String toString() {
    return liableEmpName ?? '';
  }
}
