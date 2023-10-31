class MoldingScanBulletinSort {
  MoldingScanBulletinSort({
    required this.workCardInterID,
    required this.clientOrderNumber,
    required this.priority,
  });

  MoldingScanBulletinSort.fromJson(dynamic json) {
    workCardInterID = json['WorkCardInterID'];
    clientOrderNumber = json['ClientOrderNumber'];
    priority = json['Priority'];
  }

  int? workCardInterID;
  String? clientOrderNumber;
  int? priority;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['WorkCardInterID'] = workCardInterID;
    map['ClientOrderNumber'] = clientOrderNumber;
    map['Priority'] = priority;
    return map;
  }
}
