
import 'package:jd_flutter/utils/web_api.dart';

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
  String baseUrl = '';

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ResultCode'] = resultCode;
    map['Data'] = data;
    map['Message'] = message;
    return map;
  }

  print(String uri, Map<String, dynamic> queryParameters) {
    Map<String, dynamic> map = <String, dynamic>{};
    map['Uri'] = uri;
    map['Parameters'] = queryParameters;
    map['ResponseTime'] = DateTime.now();
    map['ResultCode'] = resultCode;
    map['Data'] = data;
    map['Message'] = message;
    logger.f(map);
  }
}

class ParseJsonParams<T> {
  final dynamic data;
  final T Function(dynamic) fromJson;

  ParseJsonParams(this.data, this.fromJson);
}

List<T> parseJsonToList<T>(ParseJsonParams<T> params) {
  if (params.data is List) {
    return [for (var json in params.data) params.fromJson(json)];
  } else {
    return <T>[];
  }
}

T parseJsonToData<T>(ParseJsonParams<T> params) {
  return params.fromJson(params.data);
}
