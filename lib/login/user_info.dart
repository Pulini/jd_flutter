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
      this.sAPRole, 
      this.sAPLineNumber, 
      this.sAPFactory, 
      this.jurisdictionList, 
      this.reportDeptmentID,});

  UserInfo.fromJson(dynamic json) {
    token = json['Token'];
    departmentID = json['DepartmentID'];
    dutyID = json['DutyID'];
    empID = json['EmpID'];
    number = json['Number'];
    organizeID = json['OrganizeID'];
    name = json['Name'];
    sex = json['Sex'];
    userID = json['UserID'];
    departmentName = json['DepartmentName'];
    position = json['Position'];
    factory = json['Factory'];
    defaultStockID = json['DefaultStockID'];
    defaultStockName = json['DefaultStockName'];
    defaultStockNumber = json['DefaultStockNumber'];
    diningRoomID = json['DiningRoomID'];
    picUrl = json['PicUrl'];
    passWord = json['PassWord'];
    empPassWord = json['EmpPassWord'];
    quickLoginType = json['QuickLoginType'];
    isAppAutoLock = json['IsAppAutoLock'];
    sAPRole = json['SAPRole'];
    sAPLineNumber = json['SAPLineNumber'];
    sAPFactory = json['SAPFactory'];
    if (json['JurisdictionList'] != null) {
      jurisdictionList = [];
      json['JurisdictionList'].forEach((v) {
        jurisdictionList?.add(JurisdictionList.fromJson(v));
      });
    }
    reportDeptmentID = json['ReportDeptmentID'];
  }
  String? token;
  int? departmentID;
  int? dutyID;
  int? empID;
  String? number;
  int? organizeID;
  String? name;
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
  String? sAPRole;
  String? sAPLineNumber;
  String? sAPFactory;
  List<JurisdictionList>? jurisdictionList;
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
    map['SAPRole'] = sAPRole;
    map['SAPLineNumber'] = sAPLineNumber;
    map['SAPFactory'] = sAPFactory;
    if (jurisdictionList != null) {
      map['JurisdictionList'] = jurisdictionList?.map((v) => v.toJson()).toList();
    }
    map['ReportDeptmentID'] = reportDeptmentID;
    return map;
  }

}

class JurisdictionList {
  JurisdictionList({
      this.jid,});

  JurisdictionList.fromJson(dynamic json) {
    jid = json['JID'];
  }
  String? jid;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['JID'] = jid;
    return map;
  }

}