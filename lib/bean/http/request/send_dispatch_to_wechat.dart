class SendDispatchToWechat {
  int empID;
  String workOrderType;
  String workOrderContent;

  SendDispatchToWechat({
    required this.empID,
    required this.workOrderType,
    required this.workOrderContent,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EmpID'] = empID;
    map['WorkOrderType'] = workOrderType;
    map['WorkOrderContent'] = workOrderContent;
    return map;
  }
}
