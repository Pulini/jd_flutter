class ContainerScanner {
  ContainerScanner({
    this.cabinetNumber, //柜号
    this.shouldRelease,  //应出
    this.isSued,  //已出
  });

  ContainerScanner.fromJson(dynamic json) {
    cabinetNumber = json['ZZKHXH1'];
    shouldRelease = json['ZZYCXS'];
    isSued = json['YFXS'];
  }

  String? cabinetNumber; //柜号
  int? shouldRelease; //应出
  int? isSued; //已出

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZZKHXH1'] = cabinetNumber;
    map['ZZYCXS'] = shouldRelease;
    map['YFXS'] = isSued;
    return map;
  }
}
