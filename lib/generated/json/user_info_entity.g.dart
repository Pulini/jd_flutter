

import 'package:jd_flutter/login/user_info_entity.dart';
import 'base/json_convert_content.dart';

UserInfoEntity $UserInfoEntityFromJson(Map<String, dynamic> json) {
	final UserInfoEntity userInfoEntity = UserInfoEntity();
	final String? token = jsonConvert.convert<String>(json['Token']);
	if (token != null) {
		userInfoEntity.token = token;
	}
	final int? departmentID = jsonConvert.convert<int>(json['DepartmentID']);
	if (departmentID != null) {
		userInfoEntity.departmentID = departmentID;
	}
	final int? dutyID = jsonConvert.convert<int>(json['DutyID']);
	if (dutyID != null) {
		userInfoEntity.dutyID = dutyID;
	}
	final int? empID = jsonConvert.convert<int>(json['EmpID']);
	if (empID != null) {
		userInfoEntity.empID = empID;
	}
	final String? number = jsonConvert.convert<String>(json['Number']);
	if (number != null) {
		userInfoEntity.number = number;
	}
	final int? organizeID = jsonConvert.convert<int>(json['OrganizeID']);
	if (organizeID != null) {
		userInfoEntity.organizeID = organizeID;
	}
	final String? name = jsonConvert.convert<String>(json['Name']);
	if (name != null) {
		userInfoEntity.name = name;
	}
	final String? sex = jsonConvert.convert<String>(json['Sex']);
	if (sex != null) {
		userInfoEntity.sex = sex;
	}
	final int? userID = jsonConvert.convert<int>(json['UserID']);
	if (userID != null) {
		userInfoEntity.userID = userID;
	}
	final String? departmentName = jsonConvert.convert<String>(json['DepartmentName']);
	if (departmentName != null) {
		userInfoEntity.departmentName = departmentName;
	}
	final String? position = jsonConvert.convert<String>(json['Position']);
	if (position != null) {
		userInfoEntity.position = position;
	}
	final String? xFactory = jsonConvert.convert<String>(json['Factory']);
	if (xFactory != null) {
		userInfoEntity.xFactory = xFactory;
	}
	final int? defaultStockID = jsonConvert.convert<int>(json['DefaultStockID']);
	if (defaultStockID != null) {
		userInfoEntity.defaultStockID = defaultStockID;
	}
	final String? defaultStockName = jsonConvert.convert<String>(json['DefaultStockName']);
	if (defaultStockName != null) {
		userInfoEntity.defaultStockName = defaultStockName;
	}
	final String? defaultStockNumber = jsonConvert.convert<String>(json['DefaultStockNumber']);
	if (defaultStockNumber != null) {
		userInfoEntity.defaultStockNumber = defaultStockNumber;
	}
	final int? diningRoomID = jsonConvert.convert<int>(json['DiningRoomID']);
	if (diningRoomID != null) {
		userInfoEntity.diningRoomID = diningRoomID;
	}
	final String? picUrl = jsonConvert.convert<String>(json['PicUrl']);
	if (picUrl != null) {
		userInfoEntity.picUrl = picUrl;
	}
	final String? passWord = jsonConvert.convert<String>(json['PassWord']);
	if (passWord != null) {
		userInfoEntity.passWord = passWord;
	}
	final String? empPassWord = jsonConvert.convert<String>(json['EmpPassWord']);
	if (empPassWord != null) {
		userInfoEntity.empPassWord = empPassWord;
	}
	final int? quickLoginType = jsonConvert.convert<int>(json['QuickLoginType']);
	if (quickLoginType != null) {
		userInfoEntity.quickLoginType = quickLoginType;
	}
	final int? isAppAutoLock = jsonConvert.convert<int>(json['IsAppAutoLock']);
	if (isAppAutoLock != null) {
		userInfoEntity.isAppAutoLock = isAppAutoLock;
	}
	final String? sAPRole = jsonConvert.convert<String>(json['SAPRole']);
	if (sAPRole != null) {
		userInfoEntity.sAPRole = sAPRole;
	}
	final String? sAPLineNumber = jsonConvert.convert<String>(json['SAPLineNumber']);
	if (sAPLineNumber != null) {
		userInfoEntity.sAPLineNumber = sAPLineNumber;
	}
	final String? sAPFactory = jsonConvert.convert<String>(json['SAPFactory']);
	if (sAPFactory != null) {
		userInfoEntity.sAPFactory = sAPFactory;
	}
	final List<UserInfoJurisdictionList>? jurisdictionList = jsonConvert.convertListNotNull<UserInfoJurisdictionList>(json['JurisdictionList']);
	if (jurisdictionList != null) {
		userInfoEntity.jurisdictionList = jurisdictionList;
	}
	final int? reportDeptmentID = jsonConvert.convert<int>(json['ReportDeptmentID']);
	if (reportDeptmentID != null) {
		userInfoEntity.reportDeptmentID = reportDeptmentID;
	}
	return userInfoEntity;
}

Map<String, dynamic> $UserInfoEntityToJson(UserInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['Token'] = entity.token;
	data['DepartmentID'] = entity.departmentID;
	data['DutyID'] = entity.dutyID;
	data['EmpID'] = entity.empID;
	data['Number'] = entity.number;
	data['OrganizeID'] = entity.organizeID;
	data['Name'] = entity.name;
	data['Sex'] = entity.sex;
	data['UserID'] = entity.userID;
	data['DepartmentName'] = entity.departmentName;
	data['Position'] = entity.position;
	data['Factory'] = entity.xFactory;
	data['DefaultStockID'] = entity.defaultStockID;
	data['DefaultStockName'] = entity.defaultStockName;
	data['DefaultStockNumber'] = entity.defaultStockNumber;
	data['DiningRoomID'] = entity.diningRoomID;
	data['PicUrl'] = entity.picUrl;
	data['PassWord'] = entity.passWord;
	data['EmpPassWord'] = entity.empPassWord;
	data['QuickLoginType'] = entity.quickLoginType;
	data['IsAppAutoLock'] = entity.isAppAutoLock;
	data['SAPRole'] = entity.sAPRole;
	data['SAPLineNumber'] = entity.sAPLineNumber;
	data['SAPFactory'] = entity.sAPFactory;
	data['JurisdictionList'] =  entity.jurisdictionList.map((v) => v.toJson()).toList();
	data['ReportDeptmentID'] = entity.reportDeptmentID;
	return data;
}

UserInfoJurisdictionList $UserInfoJurisdictionListFromJson(Map<String, dynamic> json) {
	final UserInfoJurisdictionList userInfoJurisdictionList = UserInfoJurisdictionList();
	final String? jID = jsonConvert.convert<String>(json['JID']);
	if (jID != null) {
		userInfoJurisdictionList.jID = jID;
	}
	return userInfoJurisdictionList;
}

Map<String, dynamic> $UserInfoJurisdictionListToJson(UserInfoJurisdictionList entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['JID'] = entity.jID;
	return data;
}