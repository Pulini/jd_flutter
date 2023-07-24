import 'package:jd_flutter/generated/json/base/json_convert_content.dart';
import 'package:jd_flutter/http/response/group_entity.dart';

GroupEntity $GroupEntityFromJson(Map<String, dynamic> json) {
  final GroupEntity groupEntity = GroupEntity();
  final String? itemID = jsonConvert.convert<String>(json['ItemID']);
  if (itemID != null) {
    groupEntity.itemID = itemID;
  }
  final String? name = jsonConvert.convert<String>(json['Name']);
  if (name != null) {
    groupEntity.name = name;
  }
  return groupEntity;
}

Map<String, dynamic> $GroupEntityToJson(GroupEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['ItemID'] = entity.itemID;
  data['Name'] = entity.name;
  return data;
}
