// FileInterID : 5709
// Name : "DD201937-11"
// TypeName : "SOP"
// FileName : "DD201937-11.pdf"
// FullName : "https://geapp.goldemperor.com:1226/Mui/pdfjs/web/viewer.html?code=%u0030%u0031%u0033%u0036%u0030%u0030%u0020%u6F58%u5353%u65ED&url=%u0068%u0074%u0074%u0070%u0073%u003A%u002F%u002F%u0067%u0065%u0061%u0070%u0070%u002E%u0067%u006F%u006C%u0064%u0065%u006D%u0070%u0065%u0072%u006F%u0072%u002E%u0063%u006F%u006D%u003A%u0038%u0030%u0038%u0034%u002F%u91D1%u5E1D%u96C6%u56E2%u80A1%u4EFD%u6709%u9650%u516C%u53F8%u002F%u5236%u9020%u8BF4%u660E%u4E66%u002F%u0032%u0030%u0032%u0033%u002F%u0039%u002F%u005A%u005A%u0053%u004D%u0053%u0032%u0033%u0030%u0030%u0030%u0037%u0031%u0032%u002F%u0044%u0044%u0032%u0030%u0031%u0039%u0033%u0037%u002D%u0031%u0031%u002E%u0070%u0064%u0066"
// ItemID : 1561037.0

class ProcessSpecificationInfo {
  ProcessSpecificationInfo({
      this.fileInterID, 
      this.name, 
      this.typeName, 
      this.fileName, 
      this.fullName, 
      this.itemID,});

  ProcessSpecificationInfo.fromJson(dynamic json) {
    fileInterID = json['FileInterID'];
    name = json['Name'];
    typeName = json['TypeName'];
    fileName = json['FileName'];
    fullName = json['FullName'];
    itemID = json['ItemID'];
  }
  int? fileInterID;
  String? name;
  String? typeName;
  String? fileName;
  String? fullName;
  double? itemID;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['FileInterID'] = fileInterID;
    map['Name'] = name;
    map['TypeName'] = typeName;
    map['FileName'] = fileName;
    map['FullName'] = fullName;
    map['ItemID'] = itemID;
    return map;
  }

}