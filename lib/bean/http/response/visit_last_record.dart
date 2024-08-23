class VisitLastRecord {
  VisitLastRecord({
    this.Name,
    this.Phone,
    this.IDCard,
    this.CarNo,
  });

  VisitLastRecord.fromJson(dynamic json) {
    Name = json['Name'];
    Phone = json['Phone'];
    IDCard = json['IDCard'];
    CarNo = json['CarNo'];
  }

  String? Name;
  String? Phone;
  String? IDCard;
  String? CarNo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Name'] = Name;
    map['Phone'] = Phone;
    map['IDCard'] = IDCard;
    map['CarNo'] = CarNo;
    return map;
  }
}
