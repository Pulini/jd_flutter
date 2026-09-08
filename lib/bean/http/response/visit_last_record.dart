import 'package:jd_flutter/utils/extension_util.dart';
class VisitLastRecord {
  VisitLastRecord({
    this.name,
    this.phone,
    this.idCard,
    this.carNo,
  });

  VisitLastRecord.fromJson(dynamic json) {
    name = JsonParse.str(json['Name']);
    phone = JsonParse.str(json['Phone']);
    idCard = JsonParse.str(json['IDCard']);
    carNo = JsonParse.str(json['CarNo']);
  }

  String? name;
  String? phone;
  String? idCard;
  String? carNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['Phone'] = phone;
    map['IDCard'] = idCard;
    map['CarNo'] = carNo;
    return map;
  }
}
