class PhotoBean {
  PhotoBean({this.photo});

  PhotoBean.fromJson(dynamic json) {
    photo = json['Photo'];
  }

  String? photo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Photo'] = photo;
    return map;
  }
}
