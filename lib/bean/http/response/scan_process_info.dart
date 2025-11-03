class ScanProcessInfo {
  List<ScanProcessReportSub1Info>? list1;
  List<ScanProcessReportSub2Info>? list2;

  ScanProcessInfo({this.list1, this.list2});

  ScanProcessInfo.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list1 = [
        for (var json in json['List'])
          ScanProcessReportSub1Info.fromJson(json)
      ];
    }
    if(json['List2'] != null){
      list2 = [
        for (var json in json['List2'])
          ScanProcessReportSub2Info.fromJson(json)
      ];
    }
  }
}

class ScanProcessReportSub1Info {
  String? barCode;
  String? name;

  ScanProcessReportSub1Info({this.barCode, this.name});

  ScanProcessReportSub1Info.fromJson(Map<String, dynamic> json) {
    barCode = json['BarCode'];
    name = json['Name'];
  }
}

class ScanProcessReportSub2Info {
  String? barCode;

  ScanProcessReportSub2Info(this.barCode);

  ScanProcessReportSub2Info.fromJson(Map<String, dynamic> json) {
    barCode = json['BarCode'];
  }
}
