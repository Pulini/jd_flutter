import '../web_api.dart';

class BaseData {
  BaseData({
    this.resultCode,
    this.data,
    this.message,
  });

  BaseData.fromJson(dynamic json) {
    resultCode = json['ResultCode'];
    data = json['Data'] ?? '';
    message = json['Message'];
  }

  int? resultCode;
  dynamic data;
  String? message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ResultCode'] = resultCode;
    map['Data'] = data;
    map['Message'] = message;
    return map;
  }
  print(){
    Map<String, dynamic> map = <String, dynamic>{};
    map['ResponseTime'] = DateTime.now();
    map['ResultCode'] = resultCode;
    map['Data'] = data;
    map['Message'] = message;
    logger.f(map);
  }
}
