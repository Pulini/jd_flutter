// FInterID : 1
// FPlaceName : "一楼会客厅"
// FIfEnterOfficeBuilding : 0

class VisitPlaceBean {
  VisitPlaceBean({
      this.fInterID, 
      this.fPlaceName, 
      this.fIfEnterOfficeBuilding,});

  VisitPlaceBean.fromJson(dynamic json) {
    fInterID = json['FInterID'];
    fPlaceName = json['FPlaceName'];
    fIfEnterOfficeBuilding = json['FIfEnterOfficeBuilding'];
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