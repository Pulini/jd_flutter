import 'package:jd_flutter/utils/extension_util.dart';
class HandoverProcessInfo {
  HandoverProcessInfo({
    this.processFlowID,
    this.name,
    this.processNames,
  });

  HandoverProcessInfo.fromJson(dynamic json) {
    processFlowID = JsonParse.str(json['ProcessFlowID']);
    name = JsonParse.str(json['Name']);
    processNames = JsonParse.list(json['ProcessNames'], ProcessNameList.fromJson);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessFlowID'] = processFlowID;
    map['Name'] = name;
    if (processNames != null) {
      map['ProcessNames'] = processNames?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String? processFlowID;
  String? name;
  List<ProcessNameList>? processNames;
}

class ProcessNameList {
  ProcessNameList({
    this.processName,
    this.flag,

  });

  ProcessNameList.fromJson(dynamic json) {
    processName = JsonParse.str(json['ProcessName']);
    flag = JsonParse.toBool(json['Flag']);

  }

  String? processName;
  bool? flag;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessName'] = processName;
    map['Flag'] = flag;
    return map;
  }
}
