class PartReportErrorInfo {
  PartReportErrorInfo({
    this.info,
    this.barcodes,
  });

  PartReportErrorInfo.fromJson(dynamic json) {
    info = json['Info'];
    if (json['Barcodes'] != null) {
      barcodes = [];
      json['Barcodes'].forEach((v) {
        barcodes?.add(v);
      });
    }
  }

  String? info; //报错信息
  List<String>? barcodes;  //已使用过的条码

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Info'] = info;
    if (barcodes != null) {
      map['Barcodes'] = barcodes?.toList();
    }
    return map;
  }
}

