// FactoryType : "PDS23394160-1"
// Size : "3.5"
// MonoNum : 145
// ReportNum : 72
// TotalNum : 72
// UnderNum : 73

class FormingMonoDetailInfo {
  FormingMonoDetailInfo({
      this.factoryType, 
      this.size, 
      this.monoNum, 
      this.reportNum, 
      this.totalNum, 
      this.underNum,});

  FormingMonoDetailInfo.fromJson(dynamic json) {
    factoryType = json['FactoryType'];
    size = json['Size'];
    monoNum = json['MonoNum'];
    reportNum = json['ReportNum'];
    totalNum = json['TotalNum'];
    underNum = json['UnderNum'];
  }
  String? factoryType;
  String? size;
  int? monoNum;
  int? reportNum;
  int? totalNum;
  int? underNum;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FactoryType'] = factoryType;
    map['Size'] = size;
    map['MonoNum'] = monoNum;
    map['ReportNum'] = reportNum;
    map['TotalNum'] = totalNum;
    map['UnderNum'] = underNum;
    return map;
  }

}