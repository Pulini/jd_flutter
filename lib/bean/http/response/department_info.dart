import 'package:jd_flutter/utils/extension_util.dart';
class Department {
  Department({
    this.itemID,
    this.name,
  });

  Department.fromJson(dynamic json) {
    itemID = JsonParse.toInt(json['ItemID']);
    name = JsonParse.str(json['Name']);
  }

  int? itemID;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemID'] = itemID;
    map['Name'] = name;
    return map;
  }
}
