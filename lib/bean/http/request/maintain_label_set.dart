class MaintainLabelSetProperties{
  int userID;
  String interID;
  String materialCode;
  List<MaintainLabelSetPropertiesSub> items;

  MaintainLabelSetProperties({
    required this.userID,
    required this.interID,
    required this.materialCode,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserID'] = userID;
    map['InterID'] = interID;
    map['MaterialCode'] = materialCode;
    map['Items'] = items.map((v) => v.toJson()).toList();
    return map;
  }
}
class MaintainLabelSetPropertiesSub{
  String size;
  String netWeight;
  String grossWeight;
  String meas;
  String unitName;

  MaintainLabelSetPropertiesSub({
    required this.size,
    required this.netWeight,
    required this.grossWeight,
    required this.meas,
    required this.unitName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Size'] = size;
    map['NetWeight'] = netWeight;
    map['GrossWeight'] = grossWeight;
    map['Meas'] = meas;
    map['UnitName'] = unitName;

    return map;
  }
}
class MaintainLabelSetCapacity{
  int userID;
  List<MaintainLabelSetCapacitySub> items;

  MaintainLabelSetCapacity({
    required this.userID,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['UserID'] = userID;
    map['Items'] = items.map((v) => v.toJson()).toList();
    return map;
  }
}
class MaintainLabelSetCapacitySub{
  int itemID;
  String factoryType;
  String size;
  String capacity;
  String processFlowID;

  MaintainLabelSetCapacitySub({
    required this.itemID,
    required this.factoryType,
    required this.size,
    required this.capacity,
    required this.processFlowID,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemID'] = itemID;
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['Capacity'] = capacity;
    map['ProcessFlowID'] = processFlowID;
    return map;
  }
}
class MaintainLabelSetLanguage{
  String materialCode;
  int userID;
  List<MaintainLabelSetLanguageSub> items;

  MaintainLabelSetLanguage({
    required this.materialCode,
    required this.userID,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['MaterialCode'] = materialCode;
    map['UserID'] = userID;
    map['Items'] = items.map((v) => v.toJson()).toList();
    return map;
  }
}
class MaintainLabelSetLanguageSub{
  String languageID;
  String languageName;
  String materialName;

  MaintainLabelSetLanguageSub({
    required this.languageID,
    required this.languageName,
    required this.materialName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['LanguageID'] = languageID;
    map['LanguageName'] = languageName;
    map['MaterialName'] = materialName;
    return map;
  }
}
