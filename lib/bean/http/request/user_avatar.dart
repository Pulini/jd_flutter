class UserAvatar {
  UserAvatar({
    this.imageBase64,
    this.empID,
    this.userID,
  });

  UserAvatar.fromJson(dynamic json) {
    imageBase64 = json['ImageBase64'];
    empID = json['EmpID'];
    userID = json['UserID'];
  }

  String? imageBase64;
  int? empID;
  int? userID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ImageBase64'] = imageBase64;
    map['EmpID'] = empID;
    map['UserID'] = userID;
    return map;
  }
}
