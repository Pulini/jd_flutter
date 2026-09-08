import 'package:jd_flutter/utils/extension_util.dart';
class IssueCauseInfo {
  IssueCauseInfo({
    this.iD,
    this.issueCause,

  });

  IssueCauseInfo.fromJson(dynamic json) {
    iD = JsonParse.toInt(json['ID']);
    issueCause = JsonParse.str(json['IssueCause']);

  }

  int? iD;  //故障id
  String? issueCause;  //故障原因


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID'] = iD;
    map['IssueCause'] = issueCause;

    return map;
  }
}
