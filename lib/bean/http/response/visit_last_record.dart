class VisitLastRecord {
  VisitLastRecord({
    this.name,
    this.phone,
    this.idCard,
    this.carNo,
  });

  VisitLastRecord.fromJson(dynamic json) {
    name = json['Name'];
    phone = json['Phone'];
    idCard = json['IDCard'];
    carNo = json['CarNo'];
  }

  String? name;
  String? phone;
  String? idCard;
  String? carNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = name;
    map['Phone'] = phone;
    map['IDCard'] = idCard;
    map['CarNo'] = carNo;
    return map;
  }
}
