// ProcessNumber : "ZC01"
// ProcessName : "测试"

class PrdRouteInfo {
  PrdRouteInfo({
      this.processNumber, 
      this.processName,});

  PrdRouteInfo.fromJson(dynamic json) {
    processNumber = json['ProcessNumber'];
    processName = json['ProcessName'];
  }
  String? processNumber;
  String? processName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ProcessNumber'] = processNumber;
    map['ProcessName'] = processName;
    return map;
  }

}