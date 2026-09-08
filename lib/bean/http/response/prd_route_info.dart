import 'package:jd_flutter/utils/extension_util.dart';
// ProcessNumber : "ZC01"
// ProcessName : "测试"

class PrdRouteInfo {
  PrdRouteInfo({
      this.processNumber, 
      this.processName,});

  PrdRouteInfo.fromJson(dynamic json) {
    processNumber = JsonParse.str(json['ProcessNumber']);
    processName = JsonParse.str(json['ProcessName']);
  }
  String? processNumber;
  String? processName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessNumber'] = processNumber;
    map['ProcessName'] = processName;
    return map;
  }

}