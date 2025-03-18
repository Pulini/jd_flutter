class ScanPickingMaterialReportInfo {
  List<ScanPickingMaterialReportSub1Info>? list1;
  List<ScanPickingMaterialReportSub2Info>? list2;

  ScanPickingMaterialReportInfo({this.list1, this.list2});

  ScanPickingMaterialReportInfo.fromJson(Map<String, dynamic> json) {
    if (json['List'] != null) {
      list1 = [
        for (var json in json['List'])
          ScanPickingMaterialReportSub1Info.fromJson(json)
      ];
    }
    if(json['List2'] != null){
      list2 = [
        for (var json in json['List2'])
          ScanPickingMaterialReportSub2Info.fromJson(json)
      ];
    }
  }
}

class ScanPickingMaterialReportSub1Info {
  String? barCode;
  String? name;

  ScanPickingMaterialReportSub1Info({this.barCode, this.name});

  ScanPickingMaterialReportSub1Info.fromJson(Map<String, dynamic> json) {
    barCode = json['barCode'];
    name = json['name'];
  }
}

class ScanPickingMaterialReportSub2Info {
  String? barCode;

  ScanPickingMaterialReportSub2Info(this.barCode);

  ScanPickingMaterialReportSub2Info.fromJson(Map<String, dynamic> json) {
    barCode = json['barCode'];
  }
}
