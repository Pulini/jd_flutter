class HandoverDetailInfo {
  HandoverDetailInfo({
    this.factoryType,
    this.upPartName,
    this.downPartName,
    this.upProcessName,
    this.downProcessName,
    this.upDeptName,
    this.downDeptName,
    this.items,
    this.summary,
  });

  HandoverDetailInfo.fromJson(dynamic json) {
    factoryType = json['FactoryType'];
    upPartName = json['UpPartName'];
    downPartName = json['DownPartName'];
    upProcessName = json['UpProcessName'];
    downProcessName = json['DownProcessName'];
    upDeptName = json['UpDeptName'];
    downDeptName = json['DownDeptName'];
    if (json['Items'] != null) {
      items = [];
      json['Items'].forEach((v) {
        items?.add(Item.fromJson(v));
      });
    }
    if (json['Summary'] != null) {
      summary = [];
      json['Summary'].forEach((v) {
        summary?.add(SummaryList.fromJson(v));
      });
    }
  }


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryType'] = factoryType;
    map['UpPartName'] = upPartName;
    map['DownPartName'] = downPartName;
    map['UpProcessName'] = upProcessName;
    map['DownProcessName'] = downProcessName;
    map['UpDeptName'] = upDeptName;
    map['DownDeptName'] = downDeptName;
    if (items != null) {
      map['Items'] = items?.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      map['Summary'] = summary?.map((v) => v.toJson()).toList();
    }
    return map;
  }

  String? factoryType; //型体
  String? upPartName;  //上游部件
  String? downPartName;  //下游部件
  String? upProcessName; //上游工序
  String? downProcessName; //下游工序
  String? upDeptName; //上游部门
  String? downDeptName; //下游部门
  List<Item>? items;
  List<SummaryList>? summary;
}

class Item {
  Item({
    this.barCode,
    this.size,
    this.qty,
    this.mtono,

  });

  Item.fromJson(dynamic json) {
    barCode = json['BarCode'];
    size = json['Size'];
    qty = json['Qty'];
    mtono = json['Mtono'];

  }

  String? barCode;
  String? size;
  double? qty;
  String? mtono;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Size'] = size;
    map['Qty'] = qty;
    map['Mtono'] = mtono;
    return map;
  }
}

class SummaryList {
  SummaryList({
    this.type,
    this.partName, //部件名
    this.factoryType, //型体
    this.size,
    this.qty,  //数量
    this.mtonoQty,  //指令数量
    this.mtono,  //指令

  });

  SummaryList.fromJson(dynamic json) {
    type = json['Type'];
    partName = json['PartName'];
    factoryType = json['FactoryType'];
    size = json['Size'];
    qty = json['Qty'];
    mtonoQty = json['MtonoQty'];
    mtono = json['Mtono'];

  }

  int? type;
  String? partName;
  String? factoryType;
  String? size;
  double? qty;
  double? mtonoQty;
  String? mtono;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Type'] = type;
    map['PartName'] = partName;
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['Qty'] = qty;
    map['MtonoQty'] = mtonoQty;
    map['Mtono'] = mtono;
    return map;
  }
}
