import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/response/base_data.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../reading.dart';

///网络异常
const resultNetworkException = -1;

///接口返回异常
const resultError = 0;

///接口返回成功
const resultSuccess = 1;

///重新登录
const resultReLogin = 2;

///版本升级
const resultToUpdate = 3;

///WebService 基地址
const baseUrlForMES = "https://geapp.goldemperor.com:1226/";

///WebService 基地址
const testUrlForMES = "https://geapptest.goldemperor.com:1224/";

/// 日志工具
var logger = Logger();

///当前语言
var language = "zh";

///初始化dio
var _dio = Dio(BaseOptions(
  baseUrl: baseUrlForMES,
  connectTimeout: const Duration(minutes: 2),
  receiveTimeout: const Duration(minutes: 2),
))
  ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    logger.i(
        "type：${options.method}\npath：${options.path}\nheaders：${options.headers}\nbody：${options.data}");
    handler.next(options);
  }, onResponse: (response, handler) {
    logger.i('response：$response');
    handler.next(response);
  }, onError: (DioException e, handler) {
    logger.e('error:$e');
    handler.next(e);
  }));

httpPost(String method,
    {Map<String, dynamic>? query,
    Object? body,
    required Function(int, dynamic, String?) callBack}) {
  _doHttp(true, method, query: query, body: body, callBack: callBack);
}

httpGet(String method,
    {Map<String, dynamic>? query,
    Object? body,
    required Function(int, dynamic, String?) callBack}) {
  _doHttp(false, method, query: query, body: body, callBack: callBack);
}

///初始化网络请求
_doHttp(bool isPost, String method,
    {Map<String, dynamic>? query,
    Object? body,
    required Function(int, dynamic, String?) callBack}) async {
  ///拼接post请求的query
  String queryStr = "";
  query?.forEach((key, value) {
    queryStr += '$key=$value&';
  });
  if (queryStr.isNotEmpty) {
    queryStr = "?${queryStr.substring(0, queryStr.length - 1)}";
  }

  ///拼接post请求的uri
  var uri = Uri.parse(testUrlForMES + method + queryStr);
  UserController userController=Get.find();
  ///设置请求的headers
  var options = Options(headers: {
    "Content-Type": "application/json",
    "FunctionID": "",
    "Version": "",
    "Language": "",
    "Token": userController.user.value!.token ?? "",
  });

  try {
    ///发起post/get请求
    var response = isPost
        ? await _dio.postUri(uri, data: body, options: options)
        : await _dio.getUri(uri, data: body, options: options);

    if (response.statusCode == 200) {
      var baseData = BaseData.fromJson(response.data.runtimeType == String
          ? jsonDecode(response.data)
          : response.data);
      callBack.call(
          baseData.resultCode!, jsonEncode(baseData.data), baseData.message);
    } else {
      logger.e("网络异常");
      callBack.call(resultNetworkException, null, "网络异常");
    }
  } on DioException catch (e) {
    logger.e('error:${e.toString()}');
    callBack.call(0, null, "服务器接口异常：${e.toString()}");
  } on Exception catch (e) {
    logger.e('error:${e.toString()}');
    callBack.call(0, null, "发生错误：${e.toString()}");
  } on Error catch (e) {
    logger.e('error:${e.toString()}');
    callBack.call(0, null, "发生异常：${e.toString()}");
  }
}

///下載文件
download(
  String url, {
  required cancel,
  required Function(int count, int total) progress,
  required Function(String filePath) completed,
  required Function(String message) error,
}) async {
  try {
    var fileName = url.substring(url.lastIndexOf("/") + 1);
    var temporary = await getTemporaryDirectory();
    var savePath = "${temporary.path}/$fileName";
    logger.i("savePath：$savePath\nfileName：$fileName");
    await _dio.download(url, savePath,
        cancelToken: cancel,
        options: Options(receiveTimeout: const Duration(minutes: 2)),
        onReceiveProgress: (int count, int total) {
      progress.call(count, total);
    }).then((value) {
      completed.call(savePath);
    });
  } on DioException catch (e) {
    logger.e("error:$e");
    if (e.type != DioExceptionType.cancel) {
      error.call("下载异常：$e");
    }
  } on Exception catch (e) {
    logger.e("error:${e.toString()}");
    error.call("发生错误：$e");
  } on Error catch (e) {
    logger.e('error:${e.toString()}');
    error.call("发生异常：${e.toString()}");
  }
}

///登录接口
const webApiLogin = "api/User/Login";

///登录接口
const webApiGetUserPhoto = "api/User/GetEmpPhotoByPhone";

///获取验证码接口
const webApiVerificationCode = "api/User/SendVerificationCode";

///修改头像接口
const webApiChangeUserAvatar = "api/User/UploadEmpPicture";

///修改密码接口
const webApiChangePassword = "api/User/ChangePassWord";

///获取部门组别列表接口
const webApiGetDepartment = "api/User/GetDepListByEmpID";

///修改部门组别接口
const webApiChangeDepartment = "api/User/GetLoginInfo";

///检查版本更新接口
const webApiCheckVersion = "api/Public/VersionUpgrade";
