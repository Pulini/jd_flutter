import 'package:jd_flutter/utils/extension_util.dart';
// Photo : 2300
// TypeAdd : true

class VisitPhotoBean {
  VisitPhotoBean({
      this.photo,
      this.typeAdd,
      });

  VisitPhotoBean.fromJson(dynamic json) {
    photo = JsonParse.str(json['Photo']);
    typeAdd = JsonParse.str(json['TypeAdd']);

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