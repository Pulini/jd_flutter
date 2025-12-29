class MaterialLabelScanInfo {
  MaterialLabelScanInfo({
    this.interID,

  });

  MaterialLabelScanInfo.fromJson(dynamic json) {
    interID = json['InterID'];

  }

  String? interID;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;

    return map;
  }
}
