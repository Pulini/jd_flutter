import 'package:jd_flutter/message_center/message_info.dart';
import 'package:jd_flutter/utils/web_api.dart';

enum JPushDoType {
  upGrade('UpGrade'),
  reLogin('ReLogin');

  final String value;

  const JPushDoType(this.value);

  static JPushDoType? fromString(String? value) {
    if (value == null) return null;

    for (final type in JPushDoType.values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

class JPushNotification {
  dynamic data;
  JPushDoType? doType;

  JPushNotification({this.data, this.doType});

  JPushNotification.fromJson(Map<String, dynamic> json) {
    var extra = json['extras']['cn.jpush.android.EXTRA'];
    data = extra['message'];
    doType = JPushDoType.fromString(extra['doType'].toString());
    MessageInfo(message: json['alert'], doType: doType).save(
      callback: (v) => logger.f('------存储推送信息成功：DataID:${v.toJson()}------'),
    );
  }

  UpDataInfo? getUpDataList() =>
      doType == JPushDoType.upGrade ? UpDataInfo.fromJson(data) : null;

  bool isUpgrade() => doType == JPushDoType.upGrade;

  bool isReLogin() => doType == JPushDoType.reLogin;
}

class UpDataInfo {
  String? message;
  List<FunctionVersionInfo>? upDataList;

  UpDataInfo({this.message, this.upDataList});

  UpDataInfo.fromJson(dynamic json) {
    message = json['message'];
    upDataList = [
      if (json['UpDataList'] != null)
        for (var item in json['UpDataList']) FunctionVersionInfo.fromJson(item)
    ];
  }
}

class FunctionVersionInfo {
  int? id;
  String? version;

  FunctionVersionInfo({this.id, this.version});

  FunctionVersionInfo.fromJson(dynamic json) {
    id = json['ID'];
    version = json['Version'];
  }
}
