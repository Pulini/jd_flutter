import 'package:jd_flutter/utils/extension_util.dart';
class ScanCode {
  ScanCode({
    this.palletNumber,
    this.code,});

  ScanCode.fromJson(dynamic json) {
    palletNumber = JsonParse.str(json['PalletNumber']);
    code = JsonParse.str(json['Code']);

  }
  String? palletNumber;
  String? code;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['PalletNumber'] = palletNumber;
    map['Code'] = code;
    return map;
  }

}