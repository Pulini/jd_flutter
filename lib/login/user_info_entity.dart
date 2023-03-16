
import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/user_info_entity.g.dart';

@JsonSerializable()
class UserInfoEntity {

	@JSONField(name: "Token")
	late String token;
	@JSONField(name: "DepartmentID")
	late int departmentID;
	@JSONField(name: "DutyID")
	late int dutyID;
	@JSONField(name: "EmpID")
	late int empID;
	@JSONField(name: "Number")
	late String number;
	@JSONField(name: "OrganizeID")
	late int organizeID;
	@JSONField(name: "Name")
	late String name;
	@JSONField(name: "Sex")
	late String sex;
	@JSONField(name: "UserID")
	late int userID;
	@JSONField(name: "DepartmentName")
	late String departmentName;
	@JSONField(name: "Position")
	late String position;
	@JSONField(name: "Factory")
	late String xFactory;
	@JSONField(name: "DefaultStockID")
	late int defaultStockID;
	@JSONField(name: "DefaultStockName")
	late String defaultStockName;
	@JSONField(name: "DefaultStockNumber")
	late String defaultStockNumber;
	@JSONField(name: "DiningRoomID")
	late int diningRoomID;
	@JSONField(name: "PicUrl")
	late String picUrl;
	@JSONField(name: "PassWord")
	late String passWord;
	@JSONField(name: "EmpPassWord")
	late String empPassWord;
	@JSONField(name: "QuickLoginType")
	late int quickLoginType;
	@JSONField(name: "IsAppAutoLock")
	late int isAppAutoLock;
	@JSONField(name: "SAPRole")
	late String sAPRole;
	@JSONField(name: "SAPLineNumber")
	late String sAPLineNumber;
	@JSONField(name: "SAPFactory")
	late String sAPFactory;
	@JSONField(name: "JurisdictionList")
	late List<UserInfoJurisdictionList> jurisdictionList;
	@JSONField(name: "ReportDeptmentID")
	late int reportDeptmentID;
  
  UserInfoEntity();

  factory UserInfoEntity.fromJson(Map<String, dynamic> json) => $UserInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserInfoEntityToJson(this);

  UserInfoEntity copyWith({String? token, int? departmentID, int? dutyID, int? empID, String? number, int? organizeID, String? name, String? sex, int? userID, String? departmentName, String? position, String? xFactory, int? defaultStockID, String? defaultStockName, String? defaultStockNumber, int? diningRoomID, String? picUrl, String? passWord, String? empPassWord, int? quickLoginType, int? isAppAutoLock, String? sAPRole, String? sAPLineNumber, String? sAPFactory, List<UserInfoJurisdictionList>? jurisdictionList, int? reportDeptmentID}) {
      return UserInfoEntity()..token= token ?? this.token
			..departmentID= departmentID ?? this.departmentID
			..dutyID= dutyID ?? this.dutyID
			..empID= empID ?? this.empID
			..number= number ?? this.number
			..organizeID= organizeID ?? this.organizeID
			..name= name ?? this.name
			..sex= sex ?? this.sex
			..userID= userID ?? this.userID
			..departmentName= departmentName ?? this.departmentName
			..position= position ?? this.position
			..xFactory= xFactory ?? this.xFactory
			..defaultStockID= defaultStockID ?? this.defaultStockID
			..defaultStockName= defaultStockName ?? this.defaultStockName
			..defaultStockNumber= defaultStockNumber ?? this.defaultStockNumber
			..diningRoomID= diningRoomID ?? this.diningRoomID
			..picUrl= picUrl ?? this.picUrl
			..passWord= passWord ?? this.passWord
			..empPassWord= empPassWord ?? this.empPassWord
			..quickLoginType= quickLoginType ?? this.quickLoginType
			..isAppAutoLock= isAppAutoLock ?? this.isAppAutoLock
			..sAPRole= sAPRole ?? this.sAPRole
			..sAPLineNumber= sAPLineNumber ?? this.sAPLineNumber
			..sAPFactory= sAPFactory ?? this.sAPFactory
			..jurisdictionList= jurisdictionList ?? this.jurisdictionList
			..reportDeptmentID= reportDeptmentID ?? this.reportDeptmentID;
  }
    
  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class UserInfoJurisdictionList {

	@JSONField(name: "JID")
	late String jID;
  
  UserInfoJurisdictionList();

  factory UserInfoJurisdictionList.fromJson(Map<String, dynamic> json) => $UserInfoJurisdictionListFromJson(json);

  Map<String, dynamic> toJson() => $UserInfoJurisdictionListToJson(this);

  UserInfoJurisdictionList copyWith({String? jID}) {
      return UserInfoJurisdictionList()..jID= jID ?? this.jID;
  }
    
  @override
  String toString() {
    return jsonEncode(this);
  }
}