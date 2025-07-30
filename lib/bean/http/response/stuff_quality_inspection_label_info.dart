
class StuffQualityInspectionLabelInfo {
  bool select = false;

  String? barCode; //条码  BQID
  String? number; //标签项目号  BQITEM
  String? deliveryNum; //送货单号  ZDELINO
  String? label; //件号-标签  ZPIECE_NO
  String? materialCode; //物料编号  MATNR
  String? materialName; //物料名称  ZMAKTX
  double? boxQty; //装箱数量  ZXNUM
  String? unit; //单位  MEINS
  String? size; //尺码  SIZE1
  double? volume; //体积  LADEVOL
  double? grossWeight; //毛重  BRGEW
  double? netWeight; //净重  NTGEW
  double? unqualified=0.0; //不合格
  double? short=0.0; //短码


  StuffQualityInspectionLabelInfo({
    this.barCode,
    this.number,
    this.deliveryNum,
    this.label,
    this.materialCode,
    this.materialName,
    this.boxQty,
    this.unit,
    this.volume,
    this.grossWeight,
    this.netWeight,
    this.unqualified,
    this.short,
    this.size,

  });

  StuffQualityInspectionLabelInfo.fromJson(dynamic json) {
    barCode = json['BQID'];
    number = json['BQITEM'];
    deliveryNum = json['ZDELINO'];
    label = json['ZPIECE_NO'];
    materialCode = json['MATNR'];
    materialName = json['ZMAKTX'];
    boxQty = json['ZXNUM'];
    unit = json['MEINS'];
    volume = json['LADEVOL'];
    grossWeight = json['BRGEW'];
    netWeight = json['NTGEW'];
    size = json['SIZE1'];

  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['BQID'] = barCode;
    map['BQITEM'] = number;
    map['ZDELINO'] = deliveryNum;
    map['ZPIECE_NO'] = label;
    map['MATNR'] = materialCode;
    map['ZMAKTX'] = materialName;
    map['ZXNUM'] = boxQty;
    map['MEINS'] = unit;
    map['LADEVOL'] = volume;
    map['BRGEW'] = grossWeight;
    map['NTGEW'] = netWeight;
    map['SIZE1'] = size;

    return map;
  }
}
