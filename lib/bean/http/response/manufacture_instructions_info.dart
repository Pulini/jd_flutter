// InterID : 297197
// Name : "D13677-22BM总工艺书082958.pdf"
// Url : "https://geapptest.goldemperor.com:1224/Mui/pdfjs/web/viewer.html?code=%u0030%u0031%u0033%u0036%u0030%u0030%u0020%u6F58%u5353%u65ED&url=%u0068%u0074%u0074%u0070%u0073%u003A%u002F%u002F%u0067%u0065%u0061%u0070%u0070%u002E%u0067%u006F%u006C%u0064%u0065%u006D%u0070%u0065%u0072%u006F%u0072%u002E%u0063%u006F%u006D%u003A%u0038%u0030%u0038%u0034%u002F%u91D1%u5E1D%u96C6%u56E2%u6709%u9650%u516C%u53F8%u0028%u6D4B%u8BD5%u5E93%u0029%u002F%u5236%u9020%u8BF4%u660E%u4E66%u002F%u0032%u0030%u0032%u0031%u002F%u0035%u002F%u005A%u005A%u0053%u004D%u0053%u0032%u0030%u0030%u0030%u0030%u0036%u0038%u0031%u002F%u0044%u0031%u0033%u0036%u0037%u0037%u002D%u0032%u0032%u0042%u004D%u603B%u5DE5%u827A%u4E66%u0030%u0038%u0032%u0039%u0035%u0038%u002E%u0070%u0064%u0066"

class ManufactureInstructionsInfo {
  ManufactureInstructionsInfo({
      this.interID, 
      this.name, 
      this.url,});

  ManufactureInstructionsInfo.fromJson(dynamic json) {
    interID = json['InterID'];
    name = json['Name'];
    url = json['Url'];
  }
  int? interID;
  String? name;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['InterID'] = interID;
    map['Name'] = name;
    map['Url'] = url;
    return map;
  }

}