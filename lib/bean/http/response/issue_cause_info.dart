class IssueCauseInfo {
  IssueCauseInfo({
    this.iD,
    this.issueCause,

  });

  IssueCauseInfo.fromJson(dynamic json) {
    iD = json['ID'];
    issueCause = json['IssueCause'];

  }

  int? iD;  //故障id
  String? issueCause;  //故障原因


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ID'] = iD;
    map['IssueCause'] = issueCause;

    return map;
  }
}
