import 'package:jd_flutter/utils/extension_util.dart';

import 'machine_dispatch_info.dart';

class MachineLabelInfo {
  MachineLabelInfo({
    this.labelID,
    this.dispatchNo,
    this.date,
    this.factory,
    this.number,
    this.item,
  });

  MachineLabelInfo.fromJson(dynamic json) {
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

  MachineLabelInfo.fromJsonWithState(
    dynamic json,
    List<Items> sizeList,
    List<String> barCodeList,
  ) {
    labelID = json['BQID'];
    dispatchNo = json['DISPATCH_NO'];
    date = json['AEDAT'];
    factory = json['WERKS'];
    number = json['ZPQYM'];
    type = json['ZBARCODE_TYPE'];
    specifications = json['ZZCJGG'];
    netWeight = json['NTGEW'];
    grossWeight = json['BRGEW'];
    if (json['ITEM'] != null) {
      item = [];
      json['ITEM'].forEach((v) {
        item?.add(Item.fromJsonWithState(
          v,
          number ?? '',
          type ?? '',
          specifications ?? '',
          netWeight.toString(),
          grossWeight.toString(),
          sizeList,
          barCodeList,
        ));
      });
    }
  }

  String? labelID;
  String? dispatchNo;
  String? date;
  String? factory;
  String? number;
  List<Item>? item;
  String? type;
  String? specifications;
  int? netWeight;
  int? grossWeight;

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
    map['ZBARCODE_TYPE'] = type;
    map['ZZCJGG'] = specifications;
    map['NTGEW'] = netWeight;
    map['BRGEW'] = grossWeight;
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
  });

  Item.fromJsonWithState(
    dynamic json,
    this.number,
    this.type,
    this.specifications,
    this.netWeight,
    this.grossWeight,
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
    englishName = json['ZDECLARATION'];
    englishUnit = json['MSEH3'];
  }

  String? subLabelID;
  double? qty;
  String? size;
  String? typeBody;
  String? unit;
  String? englishName;
  String? englishUnit;

  String number = '';
  bool isScanned = false;
  bool isLastLabel = false;
  String type = '';
  String specifications = '';
  String netWeight = '';
  String grossWeight = '';

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

class EnglishLabelInfo {
  double? outerBoxWeight; //外箱重量
  List<EnglishLabelItemInfo>? specificationsList; //规格

  EnglishLabelInfo({
    this.outerBoxWeight,
    this.specificationsList,
  });

  EnglishLabelInfo.fromJson(dynamic json) {
    outerBoxWeight = json['ZDHMNG'].toString().toDoubleTry();
    specificationsList = [
      if (json['LT_ZTBOX'] != null)
        for (var v in json['LT_ZTBOX']) EnglishLabelItemInfo.fromJson(v)
    ];
  }
}

class EnglishLabelItemInfo {
  String? specifications; //规格
  double? weight; //重量

  EnglishLabelItemInfo({
    this.specifications,
    this.weight,
  });

  EnglishLabelItemInfo.fromJson(dynamic json) {
    specifications = json['ZZCJGG'];
    weight = json['ZOUTBOXWGT'];
  }
}

class MachineDispatchReprintLabelInfo {
  bool isLastLabel;
  bool isEnglish;
  String number;
  String labelID;
  String processes;
  double qty;
  String size;
  String factoryType;
  String date;
  String materialName;
  String unit;
  String machine;
  String shift;
  String dispatchNumber;
  String decrementNumber;
  String specifications; //规格
  double netWeight; //毛重
  double grossWeight; //净重
  String englishName; //英文名称
  String englishUnit; //英文单位

  MachineDispatchReprintLabelInfo({
    required this.isLastLabel,
    required this.isEnglish,
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
    required this.specifications,
    required this.netWeight,
    required this.grossWeight,
    required this.englishName,
    required this.englishUnit,
  });
}
