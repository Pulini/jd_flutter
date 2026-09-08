import 'package:jd_flutter/utils/extension_util.dart';
// FInterID : 1
// FPlaceName : "一楼会客厅"
// FIfEnterOfficeBuilding : 0

class VisitPlaceBean {
  VisitPlaceBean({
      this.fInterID, 
      this.fPlaceName, 
      this.fIfEnterOfficeBuilding,});

  VisitPlaceBean.fromJson(dynamic json) {
    fInterID = JsonParse.toInt(json['FInterID']);
    fPlaceName = JsonParse.str(json['FPlaceName']);
    fIfEnterOfficeBuilding = JsonParse.toInt(json['FIfEnterOfficeBuilding']);
  }
  int? fInterID;
  String? fPlaceName;
  int? fIfEnterOfficeBuilding;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FInterID'] = fInterID;
    map['FPlaceName'] = fPlaceName;
    map['FIfEnterOfficeBuilding'] = fIfEnterOfficeBuilding;
    return map;
  }

}