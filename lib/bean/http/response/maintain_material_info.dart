import 'package:jd_flutter/utils.dart';

/// Size : "35"
/// NetWeight : "5.000"
/// GrossWeight : "6.000"
/// Meas : "10x10x10"
/// UnitName : "个"

class MaintainMaterialInfo {
  MaintainMaterialInfo({
      this.size, 
      this.netWeight, 
      this.grossWeight, 
      this.meas, 
      this.unitName,});

  MaintainMaterialInfo.fromJson(dynamic json) {
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