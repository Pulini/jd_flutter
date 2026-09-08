import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/utils/extension_util.dart';

// Description : '检测到最新版本，请及时更新！'
// Force : true
// Url : 'http://geapp.goldemperor.com:8020/AndroidUpdate/GoldEmperor/GE1.0.apk'
// VersionName : '1.0.0'
// VersionCode : 1

class VersionInfo {
  VersionInfo({
    this.description,
    this.force,
    this.url,
    this.versionName,
    this.versionCode,
  });

  VersionInfo.fromJson(dynamic json) {
    // 统一归一化：兼容 Data 节点为对象 / 数组 / JSON 字符串三种情况
    // （直接对 String/List 用 json['Key'] 取索引会抛
    //  "type 'String' is not a subtype of type 'int' of 'index'"）
    final data = JsonParse.map(json);
    description = JsonParse.str(data['Description']);
    force = JsonParse.toBool(data['Force']);
    url = JsonParse.str(data['Url']);
    versionName = JsonParse.str(data['VersionName']);
    versionCode = JsonParse.toInt(data['VersionCode']);
  }

  String? description;
  bool? force;
  String? url;
  String? versionName;
  int? versionCode;

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
