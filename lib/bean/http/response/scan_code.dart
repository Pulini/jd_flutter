class ScanCode {
  ScanCode({
    this.palletNumber,
    this.code,});

  ScanCode.fromJson(dynamic json) {
    palletNumber = json['PalletNumber'];
    code = json['Code'];

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