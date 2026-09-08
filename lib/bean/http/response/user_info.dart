import 'package:jd_flutter/utils/extension_util.dart';
// Token : '57alHQqkbdwgh29foLOqq5EQSto9mKjm'
// DepartmentID : 274797
// DutyID : 487
// EmpID : 137035
// Number : '013600'
// OrganizeID : 1
// Name : '潘卓旭'
// Sex : '男'
// UserID : 5047
// DepartmentName : '金臻_沿条课'
// Position : '程序员'
// Factory : '金帝'
// DefaultStockID : 4791
// DefaultStockName : '金帝底料仓'
// DefaultStockNumber : '1003'
// DiningRoomID : 286
// PicUrl : 'https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2018/4/潘卓旭/013600.jpg'
// PassWord : 'E10ADC3949BA59ABBE56E057F20F883E'
// EmpPassWord : '123456'
// QuickLoginType : 1
// IsAppAutoLock : 0
// SAPRole : '001'
// SAPLineNumber : 'YTCJ1'
// SAPFactory : '1000'
// JurisdictionList : [{'JID':'1050101'},{'JID':'1050102'},{'JID':'1050201'},{'JID':'1050301'},{'JID':'1050401'},{'JID':'1050501'},{'JID':'1050601'},{'JID':'1050701'},{'JID':'1050801'},{'JID':'1050901'},{'JID':'1051001'},{'JID':'1051101'},{'JID':'1051102'},{'JID':'1051103'},{'JID':'1051105'},{'JID':'1051106'},{'JID':'1051201'},{'JID':'1051301'},{'JID':'1051311'},{'JID':'105200304'},{'JID':'105200305'},{'JID':'105200401'},{'JID':'105200402'},{'JID':'105200403'},{'JID':'105200404'},{'JID':'105200405'},{'JID':'105200501'},{'JID':'105200502'},{'JID':'105200503'},{'JID':'105200504'},{'JID':'105200505'},{'JID':'105210101'},{'JID':'105210102'},{'JID':'105210103'},{'JID':'105210104'},{'JID':'105210105'},{'JID':'303100101'},{'JID':'303100102'},{'JID':'303100103'},{'JID':'401040304'},{'JID':'705080101'},{'JID':'705080113'}]
// ReportDeptmentID : 585369

class UserInfo {
  UserInfo({
    this.token,
    this.departmentID,
    this.dutyID,
    this.empID,
    this.number,
    this.organizeID,
    this.name,
    this.sex,
    this.userID,
    this.departmentName,
    this.position,
    this.factory,
    this.defaultStockID,
    this.defaultStockName,
    this.defaultStockNumber,
    this.diningRoomID,
    this.picUrl,
    this.passWord,
    this.empPassWord,
    this.quickLoginType,
    this.isAppAutoLock,
    this.sapRole,
    this.sapLineNumber,
    this.sapFactory,
    this.jurisdictionList,
    this.reportDeptmentID,
    this.useStorageLocation,
  });

  UserInfo.fromJson(dynamic json) {
    token = JsonParse.str(json['Token']);
    departmentID = JsonParse.toInt(json['DepartmentID']);
    dutyID = JsonParse.toInt(json['DutyID']);
    empID = JsonParse.toInt(json['EmpID']);
    number = JsonParse.str(json['Number']);
    organizeID = JsonParse.toInt(json['OrganizeID']);
    name = JsonParse.str(json['Name']);
    mustChangePassword = JsonParse.toInt(json['MustChangePassword']);
    sex = JsonParse.str(json['Sex']);
    userID = JsonParse.toInt(json['UserID']);
    departmentName = JsonParse.str(json['DepartmentName']);
    position = JsonParse.str(json['Position']);
    factory = JsonParse.str(json['Factory']);
    defaultStockID = JsonParse.toInt(json['DefaultStockID']);
    defaultStockName = JsonParse.str(json['DefaultStockName']);
    defaultStockNumber = JsonParse.str(json['DefaultStockNumber']);
    diningRoomID = JsonParse.toInt(json['DiningRoomID']);
    picUrl = JsonParse.str(json['PicUrl']);
    passWord = JsonParse.str(json['PassWord']);
    empPassWord = JsonParse.str(json['EmpPassWord']);
    quickLoginType = JsonParse.toInt(json['QuickLoginType']);
    isAppAutoLock = JsonParse.toInt(json['IsAppAutoLock']);
    sapRole = JsonParse.str(json['SAPRole']);
    sapLineNumber = JsonParse.str(json['SAPLineNumber']);
    sapFactory = JsonParse.str(json['SAPFactory']);
    useStorageLocation = JsonParse.toInt(json['UseStorageLocation']);
    jurisdictionList = JsonParse.list(json['JurisdictionList'], JurisdictionList.fromJson);
    roleList = [
      if (json['RoleList'] != null)
        for (var v in json['RoleList']) RoleList.fromJson(v)
    ];
    roleLevel = JsonParse.toInt(json['RoleLevel']);
    reportDeptmentID = JsonParse.toInt(json['ReportDeptmentID']);
  }

  String? token;
  int? departmentID;
  int? dutyID;
  int? empID;
  String? number;
  int? organizeID;
  String? name;
  int? mustChangePassword;
  String? sex;
  int? userID;
  String? departmentName;
  String? position;
  String? factory;
  int? defaultStockID;
  String? defaultStockName;
  String? defaultStockNumber;
  int? diningRoomID;
  String? picUrl;
  String? passWord;
  String? empPassWord;
  int? quickLoginType;
  int? isAppAutoLock;
  String? sapRole;
  String? sapLineNumber;
  String? sapFactory;
  int? useStorageLocation; //是否启用库位管理
  List<JurisdictionList>? jurisdictionList;
  List<RoleList>? roleList; // 角色列表
  int? roleLevel;
  int? reportDeptmentID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Token'] = token;
    map['DepartmentID'] = departmentID;
    map['DutyID'] = dutyID;
    map['EmpID'] = empID;
    map['Number'] = number;
    map['OrganizeID'] = organizeID;
    map['Name'] = name;
    map['MustChangePassword'] = mustChangePassword;
    map['Sex'] = sex;
    map['UserID'] = userID;
    map['DepartmentName'] = departmentName;
    map['Position'] = position;
    map['Factory'] = factory;
    map['DefaultStockID'] = defaultStockID;
    map['DefaultStockName'] = defaultStockName;
    map['DefaultStockNumber'] = defaultStockNumber;
    map['DiningRoomID'] = diningRoomID;
    map['PicUrl'] = picUrl;
    map['PassWord'] = passWord;
    map['EmpPassWord'] = empPassWord;
    map['QuickLoginType'] = quickLoginType;
    map['IsAppAutoLock'] = isAppAutoLock;
    map['SAPRole'] = sapRole;
    map['SAPLineNumber'] = sapLineNumber;
    map['UseStorageLocation'] = useStorageLocation;
    map['SAPFactory'] = sapFactory;
    if (jurisdictionList != null) {
      map['JurisdictionList'] =
          jurisdictionList?.map((v) => v.toJson()).toList();
    }
    map['RoleList'] = roleList?.map((v) => v.toJson()).toList();
    map['RoleLevel'] = roleLevel;
    map['ReportDeptmentID'] = reportDeptmentID;
    return map;
  }
}

// JID : '1050101'

class JurisdictionList {
  JurisdictionList({
    this.jid,
  });

  JurisdictionList.fromJson(dynamic json) {
    jid = JsonParse.str(json['JID']);
  }

  String? jid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['JID'] = jid;
    return map;
  }
}

// {
//   "RoleID": 15,
//   "RoleName": "董事长",
//   "Level": 6
// }
class RoleList {
  int? roleID;
  String? roleName;
  int? level;

  RoleList({
    this.roleID,
    this.roleName,
    this.level,
  });

  RoleList.fromJson(dynamic json) {
    roleID = JsonParse.toInt(json['RoleID']);
    roleName = JsonParse.str(json['RoleName']);
    level = JsonParse.toInt(json['Level']);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['RoleID'] = roleID;
    map['RoleName'] = roleName;
    map['Level'] = level;
    return map;
  }
}
