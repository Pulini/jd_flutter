import 'package:jd_flutter/utils/extension_util.dart';
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
    factory = JsonParse.str(json['factory']);
    departmentCode = JsonParse.str(json['departmentCode']);
    departmentName = JsonParse.str(json['departmentName']);
    totalEmployees = JsonParse.toInt(json['totalEmployees']);
    attendanceCount = JsonParse.toInt(json['attendanceCount']);
    absenceCount = JsonParse.toInt(json['absenceCount']);
    lateOrEarlyCount = JsonParse.toInt(json['lateOrEarlyCount']);
    publicHoliday = JsonParse.toDouble(json['publicHoliday']);
    legalHolidays = JsonParse.toDouble(json['legalHolidays']);
    yearRest = JsonParse.toDouble(json['yearRest']);
    absenceRate = JsonParse.str(json['absenceRate']);
    leaveTotal = JsonParse.toDouble(json['leaveTotal']);
    casualLeave = JsonParse.toDouble(json['casualLeave']);
    sickLeave = JsonParse.toDouble(json['sickLeave']);
    workInjury = JsonParse.toDouble(json['workInjury']);
    maternityLeave = JsonParse.toDouble(json['maternityLeave']);
    marriageLeave = JsonParse.toDouble(json['marriageLeave']);
    funeralLeave = JsonParse.toDouble(json['funeralLeave']);
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
    empNumber = JsonParse.str(json['empNumber']);
    empID = JsonParse.toInt(json['empID']);
    empName = JsonParse.str(json['empName']);
    beginHireDate = JsonParse.str(json['beginHireDate']);
    departmentID = JsonParse.toInt(json['departmentID']);
    deptNumber = JsonParse.str(json['deptNumber']);
    deptName = JsonParse.str(json['deptName']);
    dutyName = JsonParse.str(json['dutyName']);
    photo = JsonParse.str(json['photo']);
    phone = JsonParse.str(json['phone']);
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
