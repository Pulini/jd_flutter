import 'package:jd_flutter/utils/extension_util.dart';
// PalletNumber : "F101-33"
// CreationDate : "0000-00-00"
// UsedNum : 0.0

class SapPalletInfo {
  SapPalletInfo({
      this.palletNumber, 
      this.creationDate, 
      this.usedNum,});

  SapPalletInfo.fromJson(dynamic json) {
    palletNumber = JsonParse.str(json['PalletNumber']);
    creationDate = JsonParse.str(json['CreationDate']);
    usedNum = JsonParse.toDouble(json['UsedNum']);
  }
  String? palletNumber;
  String? creationDate;
  double? usedNum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PalletNumber'] = palletNumber;
    map['CreationDate'] = creationDate;
    map['UsedNum'] = usedNum;
    return map;
  }

}