// Code : "10030100232"
// Name : "深蓝色-12尼龙拉头"
// Model : ""
// Color : ""
// Unit : "个"
// NeedQty : 1600.0

class WorkPlanMaterialInfo {
  WorkPlanMaterialInfo({
      this.code, 
      this.name, 
      this.model, 
      this.color, 
      this.unit, 
      this.needQty,});

  WorkPlanMaterialInfo.fromJson(dynamic json) {
    code = json['Code'];
    name = json['Name'];
    model = json['Model'];
    color = json['Color'];
    unit = json['Unit'];
    needQty = json['NeedQty'];
  }
  String? code;
  String? name;
  String? model;
  String? color;
  String? unit;
  double? needQty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Code'] = code;
    map['Name'] = name;
    map['Model'] = model;
    map['Color'] = color;
    map['Unit'] = unit;
    map['NeedQty'] = needQty;
    return map;
  }

}