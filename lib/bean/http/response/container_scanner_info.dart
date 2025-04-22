class ContainerScanner {
  ContainerScanner({
    this.cabinetNumber, //柜号
    this.shouldRelease,  //应出
    this.issued,  //已出
  });

  ContainerScanner.fromJson(dynamic json) {
    cabinetNumber = json['ZZKHXH1'];
    shouldRelease = json['ZZYCXS'];
    issued = json['YFXS'];
  }

  String? cabinetNumber; //柜号
  String? shouldRelease; //应出
  String? issued; //已出

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZZKHXH1'] = cabinetNumber;
    map['ZZYCXS'] = shouldRelease;
    map['YFXS'] = issued;
    return map;
  }
}
