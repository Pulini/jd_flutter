import 'dart:convert';

import 'package:jd_flutter/data_entity/base_data.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

///网络异常
const resultNetworkException = -1;

///接口返回异常
const resultError = 0;

///接口返回成功
const resultSuccess = 1;

const resultReLogin = 2;
const resultToUpdate = 3;

/// 日志工具
var logger = Logger();

///WebService 基地址
const baseUrlForMES = "https://geapp.goldemperor.com:1226/";

///WebService 基地址
const testUrlForMES = "https://geapptest.goldemperor.com:1224/";

///登录接口
const webApiLogin = "api/User/Login"; //登录

///登录接口
const webApiGetUserPhoto = "pi/User/GetEmpPhotoByPhone"; //获取账号照片

///获取验证码接口
const webApiVerificationCode = "api/User/SendVerificationCode"; //登录

/// 网络请求工具
class DoHttp {
  ///请求uri
  late Uri _uri;

  ///请求body
  Object? _body;

  ///请求header
  final Map<String, String> _headers = {
    "FunctionID": "",
    "Version": "",
    "Language": "",
    "Token": "",
  };

  final dio = Dio(BaseOptions(
    baseUrl: testUrlForMES,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  ///初始化网络请求
  DoHttp(String method, {Map<String, dynamic>? query, Object? body}) {
    //拼接post请求的query
    String queryStr = "";
    query?.forEach((key, value) {
      queryStr += '$key=$value&';
    });
    if (queryStr.isNotEmpty) {
      queryStr = "?${queryStr.substring(0, queryStr.length - 1)}";
    }
    //创建uri
    _uri = Uri.parse(testUrlForMES + method + queryStr);
    _body = body;
  }

  ///POST请求
  post({required Function(int, dynamic, String?) back}) async {
    var response = await dio.postUri(_uri, data: _body, options: Options(headers: _headers));
    logger.v(response);
    if (response.statusCode == 200) {
      var baseData = BaseData.fromJson(response.data);
      logger.d(baseData.resultCode);
      logger.d(baseData.message);
      logger.i(baseData.data);
      back.call(baseData.resultCode!, jsonEncode(baseData.data), baseData.message);
    } else {
      logger.e("网络异常");
      back.call(resultNetworkException, null, "网络异常");
    }
  }
}
