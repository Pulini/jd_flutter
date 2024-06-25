/// SalesAndDistributionVoucherNumber : "J2403600"
/// MaterialCode : "01202844"
/// MaterialName : "1.0mm*1.35m黑色弹力压花擦焦PU"

class OrderColorList {
  OrderColorList({
      this.vNumber,
      this.materialCode, 
      this.materialName,});

  OrderColorList.fromJson(dynamic json) {
    vNumber = json['SalesAndDistributionVoucherNumber'];
    materialCode = json['MaterialCode'];
    materialName = json['MaterialName'];
  }
  String? vNumber;
  String? materialCode;
  String? materialName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['SalesAndDistributionVoucherNumber'] = vNumber;
    map['MaterialCode'] = materialCode;
    map['MaterialName'] = materialName;
    return map;
  }

}