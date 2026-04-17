class AttendanceDashboardInfo {
  AttendanceDashboardInfo({
    this.factory,
    this.departmentCode,
    this.departmentName,
    this.totalEmployees,
    this.attendanceCount,
    this.absenceCount,
    this.lateOrEarlyCount,
    this.publicHoliday,
    this.legalHolidays,
    this.yearRest,
    this.absenceRate,
    this.leaveTotal,
    this.casualLeave,
    this.sickLeave,
    this.workInjury,
    this.maternityLeave,
    this.marriageLeave,
    this.funeralLeave,
  });

  AttendanceDashboardInfo.fromJson(dynamic json) {
    factory = json['factory'];
    departmentCode = json['departmentCode'];
    departmentName = json['departmentName'];
    totalEmployees = json['totalEmployees'];
    attendanceCount = json['attendanceCount'];
    absenceCount = json['absenceCount'];
    lateOrEarlyCount = json['lateOrEarlyCount'];
    publicHoliday = json['publicHoliday'];
    legalHolidays = json['legalHolidays'];
    yearRest = json['yearRest'];
    absenceRate = json['absenceRate'];
    leaveTotal = json['leaveTotal'];
    casualLeave = json['casualLeave'];
    sickLeave = json['sickLeave'];
    workInjury = json['workInjury'];
    maternityLeave = json['maternityLeave'];
    marriageLeave = json['marriageLeave'];
    funeralLeave = json['funeralLeave'];
  }

  /// 工厂名称
  String? factory;

  /// 部门代码
  String? departmentCode;

  /// 部门名称
  String? departmentName;

  /// 总员工数
  int? totalEmployees;

  /// 出勤人数
  int? attendanceCount;

  /// 缺勤人数
  int? absenceCount;

  /// 迟到或早退人数
  int? lateOrEarlyCount;

  /// 公假
  double? publicHoliday;

  /// 法定假日
  double? legalHolidays;

  /// 年休
  double? yearRest;

  /// 缺勤率
  String? absenceRate;

  /// 请假总计
  double? leaveTotal;

  /// 事假
  double? casualLeave;

  /// 病假
  double? sickLeave;

  /// 工伤
  double? workInjury;

  /// 产假
  double? maternityLeave;

  /// 婚假
  double? marriageLeave;

  /// 丧假
  double? funeralLeave;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['factory'] = factory;
    map['departmentCode'] = departmentCode;
    map['departmentName'] = departmentName;
    map['totalEmployees'] = totalEmployees;
    map['attendanceCount'] = attendanceCount;
    map['absenceCount'] = absenceCount;
    map['lateOrEarlyCount'] = lateOrEarlyCount;
    map['publicHoliday'] = publicHoliday;
    map['legalHolidays'] = legalHolidays;
    map['yearRest'] = yearRest;
    map['absenceRate'] = absenceRate;
    map['leaveTotal'] = leaveTotal;
    map['casualLeave'] = casualLeave;
    map['sickLeave'] = sickLeave;
    map['workInjury'] = workInjury;
    map['maternityLeave'] = maternityLeave;
    map['marriageLeave'] = marriageLeave;
    map['funeralLeave'] = funeralLeave;
    return map;
  }
}

//             "empNumber": "019956",
//             "empID": 152731,
//             "empName": "程胜宣",
//             "beginHireDate": "2020-08-14",
//             "departmentID": 554911,
//             "deptNumber": "01.09.02",
//             "deptName": "软件开发课",
//             "dutyName": "程序员",
//             "photo": "https://geapp.goldemperor.com:8084/金帝集团总部/员工/2020/8/程胜宣/019956.jpg",
//             "phone": "15932940245"
class TeamMemberInfo {

  String? empNumber;
  int? empID;
  String? empName;
  String? beginHireDate;
  int? departmentID;
  String? deptNumber;
  String? deptName;
  String? dutyName;
  String? photo;
  String? phone;

  TeamMemberInfo.fromJson(dynamic json) {
    empNumber = json['empNumber'];
    empID = json['empID'];
    empName = json['empName'];
    beginHireDate = json['beginHireDate'];
    departmentID = json['departmentID'];
    deptNumber = json['deptNumber'];
    deptName = json['deptName'];
    dutyName = json['dutyName'];
    photo = json['photo'];
    phone = json['phone'];
  }

  TeamMemberInfo({
    this.empNumber,
    this.empID,
    this.empName,
    this.beginHireDate,
    this.departmentID,
    this.deptNumber,
    this.deptName,
    this.dutyName,
    this.photo,
    this.phone,
  });
}
