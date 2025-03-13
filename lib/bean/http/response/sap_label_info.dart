import 'machine_dispatch_info.dart';

class SapLabelInfo {
  SapLabelInfo({
    this.labelID,
    this.dispatchNo,
    this.date,
    this.factory,
    this.number,
    this.item,
  });

  SapLabelInfo.fromJson(dynamic json) {
    labelID = json['BQID'];
    dispatchNo = json['DISPATCH_NO'];
    date = json['AEDAT'];
    factory = json['WERKS'];
    number = json['ZPQYM'];
    if (json['ITEM'] != null) {
      item = [];
      json['ITEM'].forEach((v) {
        item?.add(Item.fromJson(v));
      });
    }
  }

  SapLabelInfo.fromJsonWithState(
    dynamic json,
    List<Items> sizeList,
    List<String> barCodeList,
  ) {
    labelID = json['BQID'];
    dispatchNo = json['DISPATCH_NO'];
    date = json['AEDAT'];
    factory = json['WERKS'];
    number = json['ZPQYM'];
    if (json['ITEM'] != null) {
      item = [];
      json['ITEM'].forEach((v) {
        item?.add(
            Item.fromJsonWithState(v, number ?? '', sizeList, barCodeList));
      });
    }
  }

  String? labelID;
  String? dispatchNo;
  String? date;
  String? factory;
  String? number;
  List<Item>? item;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BQID'] = labelID;
    map['DISPATCH_NO'] = dispatchNo;
    map['AEDAT'] = date;
    map['WERKS'] = factory;
    map['ZPQYM'] = number;
    if (item != null) {
      map['ITEM'] = item?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Item {
  Item({
    this.subLabelID,
    this.qty,
    this.size,
    this.typeBody,
    this.unit,
    this.number,
  });

  Item.fromJsonWithState(
    dynamic json,
    String this.number,
    List<Items> sizeList,
    List<String> barCodeList,
  ) {
    subLabelID = json['BQID'];
    qty = json['MENGE'];
    size = json['SIZE1_ATINN'];
    typeBody = json['ZZXTNO'];
    unit = json['MEINS'];
    isScanned = barCodeList.contains(subLabelID);
    isLastLabel = sizeList.any((v) => v.size == size && v.capacity != qty);
  }

  Item.fromJson(dynamic json) {
    subLabelID = json['BQID'];
    qty = json['MENGE'];
    size = json['SIZE1_ATINN'];
    typeBody = json['ZZXTNO'];
    unit = json['MEINS'];
  }

  String? subLabelID;
  double? qty;
  String? size;
  String? typeBody;
  String? unit;

  String? number;
  bool isScanned = false;
  bool isLastLabel = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BQID'] = subLabelID;
    map['MENGE'] = qty;
    map['SIZE1_ATINN'] = size;
    map['ZZXTNO'] = typeBody;
    map['MEINS'] = unit;
    return map;
  }
}

class ReprintLabelInfo {
  String number = '';
  String labelID = '';
  String processes = '';
  double qty = 0;
  String size = '';
  String factoryType = '';
  String date = '';
  String materialName = '';
  String unit = '';
  String machine = '';
  String shift = '';
  String dispatchNumber = '';
  String decrementNumber = '';

  ReprintLabelInfo({
    required this.number,
    required this.labelID,
    required this.processes,
    required this.qty,
    required this.size,
    required this.factoryType,
    required this.date,
    required this.materialName,
    required this.unit,
    required this.machine,
    required this.shift,
    required this.dispatchNumber,
    required this.decrementNumber,
  });
}
