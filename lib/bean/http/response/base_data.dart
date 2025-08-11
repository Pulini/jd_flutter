import 'dart:convert';

class BaseData {
  BaseData({
    this.resultCode,
    this.data,
    this.message,
  });

  BaseData.fromJson(dynamic jsonData) {
    var json = jsonData.runtimeType == String ? jsonDecode(jsonData) : jsonData;
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
