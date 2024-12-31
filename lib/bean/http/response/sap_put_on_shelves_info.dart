class RecommendLocationInfo {
  String? factory; //工厂  WERKS
  String? warehouseNumber; //仓库  LGORT
  String? location; //库位  ZLOCAL
  String? palletNumber; //托盘号  ZFTRAYNO
  int? distance;//距离  DISTZ

  RecommendLocationInfo({
    this.factory,
    this.warehouseNumber,
    this.location,
    this.palletNumber,
    this.distance,
  });
  RecommendLocationInfo.fromJson(dynamic json){
    factory = json['WERKS'];
    warehouseNumber = json['LGORT'];
    location = json['ZLOCAL'];
    palletNumber = json['ZFTRAYNO'];
    distance = json['DISTZ'];
  }
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WERKS'] = factory;
    map['LGORT'] = warehouseNumber;
    map['ZLOCAL'] = location;
    map['ZFTRAYNO'] = palletNumber;
    map['DISTZ'] = distance;
    return map;
  }
}
