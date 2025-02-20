// EmpID : 141661
// EmpNumber : "016483"
// EmpName : "刘文勇"
// ProcessCode : "XMB"
// ProcessName : "鞋面报"
// EmpFinishQty : 225.0
// ItemList : [{"MaterialName":"鞋面-DD182920-E7A","EmpFinishQty":225.0}]

class WorkerProductionInfo {
  WorkerProductionInfo({
      this.empID, 
      this.empNumber, 
      this.empName, 
      this.processCode, 
      this.processName, 
      this.empFinishQty, 
      this.itemList,});

  WorkerProductionInfo.fromJson(dynamic json) {
    empID = json['EmpID'];
    empNumber = json['EmpNumber'];
    empName = json['EmpName'];
    processCode = json['ProcessCode'];
    processName = json['ProcessName'];
    empFinishQty = json['EmpFinishQty'];
    if (json['ItemList'] != null) {
      itemList = [];
      json['ItemList'].forEach((v) {
        itemList?.add(ItemList.fromJson(v));
      });
    }
  }
  int? empID;
  String? empNumber;
  String? empName;
  String? processCode;
  String? processName;
  double? empFinishQty;
  List<ItemList>? itemList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['EmpID'] = empID;
    map['EmpNumber'] = empNumber;
    map['EmpName'] = empName;
    map['ProcessCode'] = processCode;
    map['ProcessName'] = processName;
    map['EmpFinishQty'] = empFinishQty;
    if (itemList != null) {
      map['ItemList'] = itemList?.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

// MaterialName : "鞋面-DD182920-E7A"
// EmpFinishQty : 225.0

class ItemList {
  ItemList({
      this.materialName, 
      this.empFinishQty,});

  ItemList.fromJson(dynamic json) {
    materialName = json['MaterialName'];
    empFinishQty = json['EmpFinishQty'];
  }
  String? materialName;
  double? empFinishQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaterialName'] = materialName;
    map['EmpFinishQty'] = empFinishQty;
    return map;
  }

}