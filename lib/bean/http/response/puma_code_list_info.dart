import 'package:jd_flutter/utils/extension_util.dart';
class PumaCodeListInfo {
  PumaCodeListInfo({
     this.fID,
     this.fBarCode,

  });

  PumaCodeListInfo.fromJson(dynamic json) {
    fID = JsonParse.toInt(json['FID']);
    fBarCode = JsonParse.str(json['FBarCode']);


  }
  int? fID;
  String? fBarCode;
  bool use = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FID'] = fID;
    map['FBarCode'] = fBarCode;
    return map;
  }
}
