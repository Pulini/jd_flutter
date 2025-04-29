class HandoverProcessInfo {
  HandoverProcessInfo({
    this.processFlowID,
    this.name,
    this.processNames,
  });

  HandoverProcessInfo.fromJson(dynamic json) {
    processFlowID = json['ProcessFlowID'];
    name = json['Name'];
    if (json['ProcessNames'] != null) {
      processNames = [];
      json['ProcessNames'].forEach((v) {
        processNames?.add(ProcessNameList.fromJson(v));
      });
    }
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
    processName = json['ProcessName'];
    flag = json['Flag'];

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
