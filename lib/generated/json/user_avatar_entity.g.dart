import 'package:jd_flutter/generated/json/base/json_convert_content.dart';
import 'package:jd_flutter/http/request/user_avatar_entity.dart';

UserAvatarEntity $UserAvatarEntityFromJson(Map<String, dynamic> json) {
  final UserAvatarEntity userAvatarEntity = UserAvatarEntity();
  final String? imageBase64 = jsonConvert.convert<String>(json['ImageBase64']);
  if (imageBase64 != null) {
    userAvatarEntity.imageBase64 = imageBase64;
  }
  final int? empID = jsonConvert.convert<int>(json['EmpID']);
  if (empID != null) {
    userAvatarEntity.empID = empID;
  }
  final int? userID = jsonConvert.convert<int>(json['UserID']);
  if (userID != null) {
    userAvatarEntity.userID = userID;
  }
  return userAvatarEntity;
}

Map<String, dynamic> $UserAvatarEntityToJson(UserAvatarEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['ImageBase64'] = entity.imageBase64;
  data['EmpID'] = entity.empID;
  data['UserID'] = entity.userID;
  return data;
}
