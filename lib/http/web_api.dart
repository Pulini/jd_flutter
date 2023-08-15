import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/response/base_data.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../utils.dart';
import '../widget/dialogs.dart';

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

UserController userController = Get.find();

///初始化dio
var _dio = Dio(BaseOptions(
  baseUrl: testUrlForMES,
  connectTimeout: const Duration(minutes: 2),
  receiveTimeout: const Duration(minutes: 2),
))
  ..interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
    logger.i("""
type：${options.method}
baseUrl:${options.baseUrl}
path：${options.path}
headers：${options.headers}
""");
    logL("请求时间:${DateTime.now()}\nbody：${options.data}");
    handler.next(options);
  }, onResponse: (response, handler) {
    logL('响应时间:${DateTime.now()}\nbody：${response.data}');
    handler.next(response);
  }, onError: (DioException e, handler) {
    logger.e('error:$e');
    handler.next(e);
  }));

///post请求
Future<BaseData> httpPost({
  String? loading,
  required String method,
  Map<String, dynamic>? query,
  Object? body,
}) {
  return _doHttp(true, method, loading: loading, query: query, body: body);
}

///get请求
Future<BaseData> httpGet({
  String? loading,
  required String method,
  Map<String, dynamic>? query,
  Object? body,
}) {
  return _doHttp(false, method, loading: loading, query: query, body: body);
}

///初始化网络请求
Future<BaseData> _doHttp(bool isPost, String method,
    {String? loading, Map<String, dynamic>? query, Object? body}) async {
  if (loading?.isNotEmpty ?? true) loadingDialog(Get.overlayContext!, loading);

  ///拼接post请求的query
  String queryStr = "";
  query?.forEach((key, value) {
    queryStr += '$key=$value&';
  });
  if (queryStr.isNotEmpty) {
    queryStr = "?${queryStr.substring(0, queryStr.length - 1)}";
  }

  ///拼接post请求的uri
  var uri = Uri.parse(method + queryStr);

  ///设置请求的headers
  var options = Options(headers: {
    "Content-Type": "application/json",
    "FunctionID": "",
    "Version": "",
    "Language": language,
    "Token": userController.user.value!.token ?? "",
  });
  int resultCode = 0;
  String? json;
  String message;
  try {
    ///发起post/get请求
    var response = isPost
        ? await _dio.postUri(uri, data: body, options: options)
        : await _dio.getUri(uri, data: body, options: options);
    if (response.statusCode == 200) {
      var baseData = BaseData.fromJson(response.data.runtimeType == String
          ? jsonDecode(response.data)
          : response.data);
      resultCode = baseData.resultCode ?? 0;
      json = jsonEncode(baseData.data);
      message = baseData.message ?? "";
    } else {
      logger.e("网络异常");
      message = "网络异常";
    }
  } on DioException catch (e) {
    logger.e('error:${e.error}');
    message = "链接服务器失败：${e.error}";
  } on Exception catch (e) {
    logger.e('error:${e.toString()}');
    message = "发生错误：${e.toString()}";
  } on Error catch (e) {
    logger.e('error:${e.toString()}');
    message = "发生异常：${e.toString()}";
  }
  if (loading?.isNotEmpty ?? true) Get.back();
  return BaseData(resultCode: resultCode, data: json, message: message);
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
