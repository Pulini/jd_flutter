class HandoverProductionProcessInfo {
  HandoverProductionProcessInfo({
    this.processFlowID,
    this.processFlowName,
  });

  HandoverProductionProcessInfo.fromJson(dynamic json) {
    processFlowID = json['ProcessFlowID'];
    processFlowName = json['ProcessFlowName'];
  }

  int? processFlowID; //制程ID
  String? processFlowName; //制程ID

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessFlowID'] = processFlowID;
    map['ProcessFlowName'] = processFlowName;
    return map;
  }
}
