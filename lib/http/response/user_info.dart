/// Token : "57alHQqkbdwgh29foLOqq5EQSto9mKjm"
/// DepartmentID : 274797
/// DutyID : 487
/// EmpID : 137035
/// Number : "013600"
/// OrganizeID : 1
/// Name : "潘卓旭"
/// Sex : "男"
/// UserID : 5047
/// DepartmentName : "金臻_沿条课"
/// Position : "程序员"
/// Factory : "金帝"
/// DefaultStockID : 4791
/// DefaultStockName : "金帝底料仓"
/// DefaultStockNumber : "1003"
/// DiningRoomID : 286
/// PicUrl : "https://geapp.goldemperor.com:8084/金帝集团股份有限公司/员工/2018/4/潘卓旭/013600.jpg"
/// PassWord : "E10ADC3949BA59ABBE56E057F20F883E"
/// EmpPassWord : "123456"
/// QuickLoginType : 1
/// IsAppAutoLock : 0
/// SAPRole : "001"
/// SAPLineNumber : "YTCJ1"
/// SAPFactory : "1000"
/// JurisdictionList : [{"JID":"1050101"},{"JID":"1050102"},{"JID":"1050201"},{"JID":"1050301"},{"JID":"1050401"},{"JID":"1050501"},{"JID":"1050601"},{"JID":"1050701"},{"JID":"1050801"},{"JID":"1050901"},{"JID":"1051001"},{"JID":"1051101"},{"JID":"1051102"},{"JID":"1051103"},{"JID":"1051105"},{"JID":"1051106"},{"JID":"1051201"},{"JID":"1051301"},{"JID":"1051311"},{"JID":"105200304"},{"JID":"105200305"},{"JID":"105200401"},{"JID":"105200402"},{"JID":"105200403"},{"JID":"105200404"},{"JID":"105200405"},{"JID":"105200501"},{"JID":"105200502"},{"JID":"105200503"},{"JID":"105200504"},{"JID":"105200505"},{"JID":"105210101"},{"JID":"105210102"},{"JID":"105210103"},{"JID":"105210104"},{"JID":"105210105"},{"JID":"303100101"},{"JID":"303100102"},{"JID":"303100103"},{"JID":"401040304"},{"JID":"705080101"},{"JID":"705080113"}]
/// ReportDeptmentID : 585369

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

/// JID : "1050101"

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