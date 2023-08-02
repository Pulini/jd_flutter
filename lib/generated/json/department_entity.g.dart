import 'package:jd_flutter/generated/json/base/json_convert_content.dart';
import 'package:jd_flutter/http/response/department_entity.dart';

DepartmentEntity $DepartmentEntityFromJson(Map<String, dynamic> json) {
	final DepartmentEntity departmentEntity = DepartmentEntity();
	final int? deptmentID = jsonConvert.convert<int>(json['DeptmentID']);
	if (deptmentID != null) {
		departmentEntity.deptmentID = deptmentID;
	}
	final String? deptmentName = jsonConvert.convert<String>(json['DeptmentName']);
	if (deptmentName != null) {
		departmentEntity.deptmentName = deptmentName;
	}
	return departmentEntity;
}

Map<String, dynamic> $DepartmentEntityToJson(DepartmentEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['DeptmentID'] = entity.deptmentID;
	data['DeptmentName'] = entity.deptmentName;
	return data;
}