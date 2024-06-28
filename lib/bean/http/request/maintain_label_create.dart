class MaintainLabelCreateMix {
  String interID;//id
  int barcodeQty;//贴标数量
  int userID;//用户id
  List<MaintainLabelCreateMixSub> sizeList;
  String labelTyp;

  MaintainLabelCreateMix({
    required this.interID,
    required this.barcodeQty,
    required this.userID,
    required this.sizeList,
    required this.labelTyp,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['BarcodeQty'] = barcodeQty;
    map['UserID'] = userID;
    map['SizeList'] = sizeList.map((v) => v.toJson()).toList();
    map['LabelTyp'] = labelTyp;
    return map;
  }
}

class MaintainLabelCreateMixSub {
  String size;
  String capacity;
  String mtoNo;


  MaintainLabelCreateMixSub({
    required this.size,
    required this.capacity,
    required this.mtoNo,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Capacity'] = capacity;
    map['MtoNo'] = mtoNo;
    return map;
  }
}

class MaintainLabelCreateCustom {
  String interID;//id
  int userID;//用户id
  List<MaintainLabelCreateCustomSub> sizeList;
  String labelTyp;

  MaintainLabelCreateCustom({
    required this.interID,
    required this.userID,
    required this.sizeList,
    required this.labelTyp,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['UserID'] = userID;
    map['SizeList'] = sizeList.map((v) => v.toJson()).toList();
    map['LabelTyp'] = labelTyp;
    return map;
  }
}

class MaintainLabelCreateCustomSub {
  String size;
  String capacity;
  String qty;


  MaintainLabelCreateCustomSub({
    required this.size,
    required this.capacity,
    required this.qty,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['Capacity'] = capacity;
    map['Qty'] = qty;
    return map;
  }
}
