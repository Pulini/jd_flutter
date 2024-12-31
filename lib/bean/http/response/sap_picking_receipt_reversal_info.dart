class PickingReceiptReversalInfo {
  PickingReceiptReversalHeadInfo? head; //工单头  HEAD
  List<PickingReceiptReversalItemInfo>? item; //工单明细  ITEM

  PickingReceiptReversalInfo({
    this.head,
    this.item,
  });

  PickingReceiptReversalInfo.fromJson(dynamic json) {
    head = json['HEAD'] != null
        ? PickingReceiptReversalHeadInfo.fromJson(json['HEAD'])
        : null;
    if (json['ITEM'] != null) {
      item = [];
      json['ITEM'].forEach((v) {
        item?.add(PickingReceiptReversalItemInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (head != null) {
      map['HEAD'] = head?.toJson();
    }
    if (item != null) {
      map['ITEM'] = item?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PickingReceiptReversalHeadInfo {
  String? type; //冲销类型 ZTYPE
  String? yearWriteOff; //年度冲销凭证 MJAHR
  String? date; //日期 DATE
  String? materialVoucherNo; //物料凭证编号  MBLNR

  PickingReceiptReversalHeadInfo({
    this.type,
    this.yearWriteOff,
    this.date,
    this.materialVoucherNo,
  });

  PickingReceiptReversalHeadInfo.fromJson(dynamic json) {
    type = json['ZTYPE'];
    yearWriteOff = json['MJAHR'];
    date = json['DATE'];
    materialVoucherNo = json['MBLNR'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZTYPE'] = type;
    map['MJAHR'] = yearWriteOff;
    map['DATE'] = date;
    map['MBLNR'] = materialVoucherNo;
    return map;
  }
}

class PickingReceiptReversalItemInfo {
  String? order; //派工单号  DISPATCH_NO
  List<PickingReceiptReversalSubItemInfo>? subItem; //子项 ITEM

  PickingReceiptReversalItemInfo({
    this.order,
    this.subItem,
  });

  PickingReceiptReversalItemInfo.fromJson(dynamic json) {
    order = json['DISPATCH_NO'];
    if (json['ITEM'] != null) {
      subItem = [];
      json['ITEM'].forEach((v) {
        subItem?.add(PickingReceiptReversalSubItemInfo.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['DISPATCH_NO'] = order;
    if (subItem != null) {
      map['ITEM'] = subItem?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PickingReceiptReversalSubItemInfo {
  String? name; //物料名称 MAKTX
  String? unit; //单位 MEINS
  String? factory; //工厂  WERKS
  String? location; //存储位置id LGORT
  String? locationName; //存储位置 LGOBE
  double? quantity; //数量 MENGE
  String? warehouseLocation; //库位  ZLOCAL
  double? quantity2; //数量  MENGE_L
  String? materialName; //物料 MATNR
  String? palletNo; //托盘号  ZFTRAYNO

  PickingReceiptReversalSubItemInfo({
    this.name,
    this.unit,
    this.factory,
    this.location,
    this.locationName,
    this.quantity,
    this.warehouseLocation,
    this.quantity2,
    this.materialName,
    this.palletNo,
  });

  PickingReceiptReversalSubItemInfo.fromJson(dynamic json) {
    name = json['MAKTX'];
    unit = json['MEINS'];
    factory = json['WERKS'];
    location = json['LGORT'];
    locationName = json['LGOBE'];
    quantity = json['MENGE'];
    warehouseLocation = json['ZLOCAL'];
    quantity2 = json['MENGE_L'];
    materialName = json['MATNR'];
    palletNo = json['ZFTRAYNO'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MAKTX'] = name;
    map['MEINS'] = unit;
    map['WERKS'] = factory;
    map['LGORT'] = location;
    map['LGOBE'] = locationName;
    map['MENGE'] = quantity;
    map['ZLOCAL'] = warehouseLocation;
    map['MENGE_L'] = quantity2;
    map['MATNR'] = materialName;
    map['ZFTRAYNO'] = palletNo;
    return map;
  }
}
