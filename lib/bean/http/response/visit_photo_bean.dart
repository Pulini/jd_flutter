// Photo : 2300
// TypeAdd : true

class VisitPhotoBean {
  VisitPhotoBean({
      this.photo,
      this.typeAdd,
      });

  VisitPhotoBean.fromJson(dynamic json) {
    photo = json['Photo'];
    typeAdd = json['TypeAdd'];

  }
  String? photo;
  String? typeAdd;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Photo'] = photo;
    map['TypeAdd'] = typeAdd;
    return map;
  }

}