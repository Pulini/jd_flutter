import 'dart:io';

import 'package:dio/dio.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class DioManager {
  static Dio? _dio;
  static final DioManager _instance = DioManager._internal();

  factory DioManager() => _instance;

  DioManager._internal();

  static final simpleInterceptors = InterceptorsWrapper(
    onRequest: (options, handler) {
      options.print();
      handler.next(options);
    },
    onResponse: (response, handler) {
      if (response.data is String) {
        logger.f('Response data: ${response.data}');
      } else {
        loggerF(response.data);
      }
      handler.next(response);
    },
    onError: (DioException e, handler) {
      logger.e('error:$e');
      handler.next(e);
    },
  );

  static final geInterceptors = InterceptorsWrapper(
    onRequest: (options, handler) {
      options.print();
      handler.next(options);
    },
    onResponse: (response, handler) {
      var baseData = response.getBaseData();
      if (baseData.resultCode == resultReLogin) {
        logger.e('需要重新登录');
        spSave(spSaveUserInfo, '');
        loadingDismiss();
        handler.next(response);
        reLoginPopup();
      } else if (baseData.resultCode == resultToUpdate) {
        logger.e('需要更新版本');
        loadingDismiss();
        upData();
      } else {
        handler.next(response);
      }
    },
    onError: (DioException e, handler) {
      logger.e('DioException Type: ${e.type}');
      logger.e('DioException Message: ${e.message}');
      logger.e('DioException Error: ${e.error}');
      if (e.error is SocketException) {
        var socketError = e.error as SocketException;
        logger.e('Socket Exception OS Error: ${socketError.osError}');
        logger.e('Socket Exception Address: ${socketError.address}');
        logger.e('Socket Exception Port: ${socketError.port}');
      }
      handler.next(e);
    },
  );

  InterceptorsWrapper getFeiShuInterceptors() => simpleInterceptors;

  Dio getDio(String baseUrl) {
    if (_dio == null) {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(minutes: 1),
      ));

      // 添加拦截器
      _dio!.interceptors.add(geInterceptors);
    } else {
      // 确保baseUrl是最新的
      _dio!.options.baseUrl = baseUrl;
    }

    return _dio!;
  }

  // 重置Dio实例
  void reset() {
    _dio?.close(force: true);
    _dio = null;
  }
}
