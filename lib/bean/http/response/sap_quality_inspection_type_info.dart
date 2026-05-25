class SapQualityInspectionTypeInfo {
  String? number; //编号
  String? name; //名称


  SapQualityInspectionTypeInfo({
    this.number,
    this.name,

  });

  SapQualityInspectionTypeInfo.fromJson(dynamic json) {
    number = json['DOMVALUE_L'];
    name = json['DDTEXT'];

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['DOMVALUE_L'] = number;
    map['DDTEXT'] = name;

    return map;
  }
}

