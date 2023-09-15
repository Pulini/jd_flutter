
/// Description : '检测到最新版本，请及时更新！'
/// Force : true
/// Url : 'http://geapp.goldemperor.com:8020/AndroidUpdate/GoldEmperor/GE1.0.apk'
/// VersionName : '1.0.0'
/// VersionCode : 1

class VersionInfo {
  VersionInfo({
    this.description,
    this.force,
    this.url,
    this.versionName,
    this.versionCode,
  });

  VersionInfo.fromJson(dynamic json) {
    description = json['Description'];
    force = json['Force'];
    url = json['Url'];
    versionName = json['VersionName'];
    versionCode = json['VersionCode'];
  }

  String? description;
  bool? force;
  String? url;
  String? versionName;
  num? versionCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Description'] = description;
    map['Force'] = force;
    map['Url'] = url;
    map['VersionName'] = versionName;
    map['VersionCode'] = versionCode;
    return map;
  }
}
