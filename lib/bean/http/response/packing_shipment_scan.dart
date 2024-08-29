class PackingShipmentScan {
  PackingShipmentScan({
    required this.ZHGCCRQ,
    required this.ZZKHXH1,
  });

  PackingShipmentScan.fromJson(dynamic json) {
    ZHGCCRQ = json['ZHGCCRQ'];
    ZZKHXH1 = json['ZZKHXH1'];

  }
  String? ZHGCCRQ;
  String? ZZKHXH1;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ZHGCCRQ'] = ZHGCCRQ;
    map['ZZKHXH1'] = ZZKHXH1;
    return map;
  }
}
