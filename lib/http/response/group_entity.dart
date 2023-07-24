import 'dart:convert';

import 'package:jd_flutter/generated/json/base/json_field.dart';
import 'package:jd_flutter/generated/json/group_entity.g.dart';

@JsonSerializable()
class GroupEntity {
  @JSONField(name: "ItemID")
  late String itemID = '';
  @JSONField(name: "Name")
  late String name = '';

  GroupEntity();

  factory GroupEntity.fromJson(Map<String, dynamic> json) =>
      $GroupEntityFromJson(json);

  Map<String, dynamic> toJson() => $GroupEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
