import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/user_avatar_entity.g.dart';

@JsonSerializable()
class UserAvatarEntity {
  @JSONField(name: "ImageBase64")
  late String imageBase64;
  @JSONField(name: "EmpID")
  late int empID;
  @JSONField(name: "UserID")
  late int userID;

  UserAvatarEntity();

  factory UserAvatarEntity.fromJson(Map<String, dynamic> json) =>
      $UserAvatarEntityFromJson(json);

  Map<String, dynamic> toJson() => $UserAvatarEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
