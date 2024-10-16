
/// Entry : [{"exNumber":"SCPZYCD200000108","billDate":"2020/7/9 16:35:01","empID":139697,"qty":"28","exceptionID":34,"exceptionName":"鞋口高低、不平顺","exceptionLevel":"轻微","reCheck":"复检合格"}]
/// interID : 190109
/// entryID : 2
/// orderNumber : "P2025615"
/// deptName : "针车17组."
/// processFlowID : 2
/// productName : "针车17组."
/// qty : "834.0000000000"

class AbnormalQualityInfo {
  AbnormalQualityInfo({
    this.entry,
    this.interID,
    this.entryID,
    this.orderNumber,
    this.deptName,
    this.processFlowID,
    this.productName,
    this.qty,
  });

  AbnormalQualityInfo.fromJson(dynamic json) {
    if (json['Entry'] != null) {
      entry = [];
      json['Entry'].forEach((v) {
        entry?.add(Entry.fromJson(v));
      });
    }
    interID = json['interID'];
    entryID = json['entryID'];
    orderNumber = json['orderNumber'];
    deptName = json['deptName'];
    processFlowID = json['processFlowID'];
    productName = json['productName'];
    qty = json['qty'];
  }

  List<Entry>? entry;
  int? interID;
  int? entryID;
  String? orderNumber;
  String? deptName;
  int? processFlowID;
  String? productName;
  double? qty;
  bool select= false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (entry != null) {
      map['Entry'] = entry?.map((v) => v.toJson()).toList();
    }
    map['interID'] = interID;
    map['entryID'] = entryID;
    map['orderNumber'] = orderNumber;
    map['deptName'] = deptName;
    map['processFlowID'] = processFlowID;
    map['productName'] = productName;
    map['qty'] = qty;
    return map;
  }
}

/// exNumber : "SCPZYCD200000108"
/// billDate : "2020/7/9 16:35:01"
/// empID : 139697
/// qty : "28"
/// exceptionID : 34
/// exceptionName : "鞋口高低、不平顺"
/// exceptionLevel : "轻微"
/// reCheck : "复检合格"

class Entry {
  Entry({
    this.exNumber,
    this.billDate,
    this.empID,
    this.empName,
    this.empNumber,
    this.qty,
    this.exceptionID,
    this.exceptionName,
    this.exceptionLevel,
    this.reCheck,
  });

  Entry.fromJson(dynamic json) {
    exNumber = json['exNumber'];
    billDate = json['billDate'];
    empNumber = json['empNumber'];
    empName = json['empName'];
    empID = json['empID'];
    qty = json['qty'];
    exceptionID = json['exceptionID'];
    exceptionName = json['exceptionName'];
    exceptionLevel = json['exceptionLevel'];
    reCheck = json['reCheck'];
  }

  String? empName;
  String? empNumber;
  String? exNumber;
  String? billDate;
  int? empID;
  double? qty;
  int? exceptionID;
  String? exceptionName;
  String? exceptionLevel;
  String? reCheck;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['exNumber'] = exNumber;
    map['empName'] = empName;
    map['empNumber'] = empNumber;
    map['billDate'] = billDate;
    map['empID'] = empID;
    map['qty'] = qty;
    map['exceptionID'] = exceptionID;
    map['exceptionName'] = exceptionName;
    map['exceptionLevel'] = exceptionLevel;
    map['reCheck'] = reCheck;
    return map;
  }
}
