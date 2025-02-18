class PumaCodeListInfo {
  PumaCodeListInfo({
     this.fID,
     this.fBarCode,
     this.use = false,
  });

  PumaCodeListInfo.fromJson(dynamic json) {
    fID = json['FID'];
    fBarCode = json['FBarCode'];
    use = json['Use'];

  }
  String? fID;
  String? fBarCode;
  bool use = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FID'] = fID;
    map['FBarCode'] = fBarCode;
    map['Use'] = use;
    return map;
  }
}
