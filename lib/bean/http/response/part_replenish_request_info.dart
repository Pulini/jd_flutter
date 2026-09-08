import 'package:get/get.dart';
import 'package:jd_flutter/utils/extension_util.dart';

class PartInfo {
  PartInfo({this.partNumber, this.partName, this.sizeList});

  PartInfo.fromJson(dynamic json) {
    partNumber = JsonParse.str(json['partNumber']);
    partName = JsonParse.str(json['partName']);
    partPicture = JsonParse.str(json['partPicture']);
    sizeList = [
      if (json['sizeList'] != null)
        for (final item in json['sizeList']) PartSizeInfo.fromJson(item)
    ];
  }

  bool hasSelect() => (sizeList ?? []).any((v) => v.replenishRequest.value > 0);

  String? partNumber;
  String? partName;
  String? partPicture;
  List<PartSizeInfo>? sizeList;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['partNumber'] = partNumber;
    map['partName'] = partName;
    map['partPicture'] = partPicture;
    if (sizeList != null) {
      map['sizeList'] = sizeList!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class PartSizeInfo {
  PartSizeInfo({this.size, this.qty});

  PartSizeInfo.fromJson(dynamic json) {
    size = JsonParse.str(json['size']);
    qty = json['qty']?.toDouble();
  }

  RxDouble replenishRequest = 0.0.obs;
  String? size;
  double? qty;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['size'] = size;
    map['qty'] = qty;
    return map;
  }
}
