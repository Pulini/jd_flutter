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
