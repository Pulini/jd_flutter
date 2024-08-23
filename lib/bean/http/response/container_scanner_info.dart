class ContainerScanner {
  ContainerScanner({
    this.ZZKHXH1, //柜号
    this.ZZYCXS,  //应出
    this.YFXS,  //已出
  });

  ContainerScanner.fromJson(dynamic json) {
    ZZKHXH1 = json['ZZKHXH1'];
    ZZYCXS = json['ZZYCXS'];
    YFXS = json['YFXS'];
  }

  String? ZZKHXH1;
  String? ZZYCXS;
  String? YFXS;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZZKHXH1'] = ZZKHXH1;
    map['ZZYCXS'] = ZZYCXS;
    map['YFXS'] = YFXS;
    return map;
  }
}
