class PartReportErrorInfo {
  PartReportErrorInfo({
    this.info,
    this.barcodes,
  });

  PartReportErrorInfo.fromJson(dynamic json) {
    info = json['Info'];
    barcodes = json['Barcodes'].cast<String>();
  }

  String? info;//报错信息
  List<String>? barcodes;//已使用过的条码

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['Info'] = info;
    data['Barcodes'] = barcodes;
    return data;
  }
}

