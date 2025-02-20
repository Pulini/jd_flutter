class UsedBarCodeInfo {
  UsedBarCodeInfo({
    this.barCode,
    this.name,

  });

  UsedBarCodeInfo.fromJson(dynamic json) {
    barCode = json['BarCode'];
    name = json['Name'];

  }

  String? barCode;
  String? name;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['BarCode'] = barCode;
    map['Name'] = name;

    return map;
  }
}
