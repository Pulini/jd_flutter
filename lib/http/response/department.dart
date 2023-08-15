class Department {
  Department({
    this.itemID,
    this.name,
  });

  Department.fromJson(dynamic json) {
    itemID = json['ItemID'];
    name = json['Name'];
  }

  int? itemID;
  String? name;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ItemID'] = itemID;
    map['Name'] = name;
    return map;
  }
}
