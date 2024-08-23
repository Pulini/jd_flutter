class PackingScanTime {
  PackingScanTime({
    required this.ZHGCCRQ,
  });

  PackingScanTime.fromJson(dynamic json) {
    ZHGCCRQ = json['ZHGCCRQ'];

  }
  String? ZHGCCRQ;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZHGCCRQ'] = ZHGCCRQ;
    return map;
  }
}
