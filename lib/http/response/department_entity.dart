import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/department_entity.g.dart';

@JsonSerializable()
class DepartmentEntity {
  @JSONField(name: "DeptmentID")
  late int deptmentID = 0;
  @JSONField(name: "DeptmentName")
  late String deptmentName = '';

  DepartmentEntity();

  factory DepartmentEntity.fromJson(Map<String, dynamic> json) =>
      $DepartmentEntityFromJson(json);

  Map<String, dynamic> toJson() => $DepartmentEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
