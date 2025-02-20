import 'package:jd_flutter/utils/utils.dart';

// Size : "35"
// NetWeight : "5.000"
// GrossWeight : "6.000"
// Meas : "10x10x10"
// UnitName : "个"

class MaintainMaterialPropertiesInfo {
  MaintainMaterialPropertiesInfo({
      this.size,
      this.netWeight,
      this.grossWeight,
      this.meas,
      this.unitName,});

  MaintainMaterialPropertiesInfo.fromJson(dynamic json) {
    size = json['Size'];
    netWeight = json['NetWeight'];
    grossWeight = json['GrossWeight'];
    meas = json['Meas'];
    unitName = json['UnitName'];
  }
  String? size;
  String? netWeight;
  String? grossWeight;
  String? meas;
  String? unitName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['NetWeight'] = netWeight;
    map['GrossWeight'] = grossWeight;
    map['Meas'] = meas;
    map['UnitName'] = unitName;
    return map;
  }

  bool ifNull(){
    return netWeight.toDoubleTry()<=0||grossWeight.toDoubleTry()<=0;
  }
}

// ProcessFlowID : 2
// ItemID : 389742
// FactoryType : "D13677-22B M"
// Size : "35"
// Capacity : 2000.0

class MaintainMaterialCapacityInfo {
  MaintainMaterialCapacityInfo({
    this.processFlowID,
    this.itemID,
    this.factoryType,
    this.size,
    this.capacity,});

  MaintainMaterialCapacityInfo.fromJson(dynamic json) {
    processFlowID = json['ProcessFlowID'];
    itemID = json['ItemID'];
    factoryType = json['FactoryType'];
    size = json['Size'];
    capacity = json['Capacity'];
  }
  int? processFlowID;
  int? itemID;
  String? factoryType;
  String? size;
  double? capacity;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessFlowID'] = processFlowID;
    map['ItemID'] = itemID;
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['Capacity'] = capacity;
    return map;
  }

}
// LanguageID : 1001
// LanguageName : "中文简体"
// MaterialName : ""

class MaintainMaterialLanguagesInfo {
  MaintainMaterialLanguagesInfo({
    this.languageID,
    this.languageName,
    this.materialName,});

  MaintainMaterialLanguagesInfo.fromJson(dynamic json) {
    languageID = json['LanguageID'];
    languageName = json['LanguageName'];
    materialName = json['MaterialName'];
  }
  int? languageID;
  String? languageName;
  String? materialName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LanguageID'] = languageID;
    map['LanguageName'] = languageName;
    map['MaterialName'] = materialName;
    return map;
  }

}