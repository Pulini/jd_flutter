import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class DioManager {
  /// 每个 baseUrl 维护一个独立的 Dio 实例。
  /// 原先只保留单个 Dio，MES(geapp:1226) 与 SAP(webdispatcher:8007) 共用同一实例，
  /// 切换 baseUrl 或重试 reset 时会 force close 掉正在飞行的另一个域名请求，造成“连坐”报错。
  static final Map<String, Dio> _dioMap = {};
  static final DioManager _instance = DioManager._internal();

  // DNS 缓存
  static final Map<String, InternetAddress> _dnsCache = {};
  static final Map<String, DateTime> _dnsCacheTime = {};
  static const Duration _dnsCacheValidDuration = Duration(minutes: 5);

  factory DioManager() => _instance;

  DioManager._internal();

  /// 解析域名并缓存结果
  static Future<InternetAddress?> resolveHost(String host) async {
    final now = DateTime.now();

    // 检查缓存是否有效
    if (_dnsCache.containsKey(host)) {
      final cacheTime = _dnsCacheTime[host];
      if (cacheTime != null && now.difference(cacheTime) < _dnsCacheValidDuration) {
        logger.i('✅ 使用 DNS 缓存: $host -> ${_dnsCache[host]!.address}');
        return _dnsCache[host];
      } else {
        // 缓存过期，清除
        _dnsCache.remove(host);
        _dnsCacheTime.remove(host);
      }
    }

    // 解析 DNS
    try {
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isNotEmpty) {
        _dnsCache[host] = addresses.first;
        _dnsCacheTime[host] = now;
        logger.i('✅ DNS 解析成功: $host -> ${addresses.first.address}');
        return addresses.first;
      }
    } catch (e) {
      logger.e('❌ DNS 解析失败: $host, error: $e');
      _dnsCache.remove(host);
      _dnsCacheTime.remove(host);
    }

    return null;
  }

  /// 清除 DNS 缓存
  static void clearDnsCache([String? host]) {
    if (host != null) {
      _dnsCache.remove(host);
      _dnsCacheTime.remove(host);
      logger.i('🗑️ 已清除 DNS 缓存: $host');
    } else {
      _dnsCache.clear();
      _dnsCacheTime.clear();
      logger.i('🗑️ 已清除所有 DNS 缓存');
    }
  }

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
      logger.e('DioException Error Response: ${e.response?.data}');
      if (e.error is SocketException) {
        var socketError = e.error as SocketException;
        logger.e('Socket Exception OS Error: ${socketError.osError}');
        logger.e('Socket Exception Address: ${socketError.address}');
        logger.e('Socket Exception Port: ${socketError.port}');

        // 检测到连接拒绝或网络不可达时，清除 DNS 缓存
        // 注意：不要在 onError 中调用 _instance.reset()，它会关闭正在使用的
        // 底层 adapter，导致其它并发请求报
        // "Can't establish connection after the adapter was closed"。
        if (socketError.osError?.errorCode == 111 ||
            socketError.osError?.errorCode == 101) {
          logger.w('⚠️ 检测到网络连接错误，清除 DNS 缓存');
          clearDnsCache();
        }
      }
      handler.next(e);
    },
  );

  InterceptorsWrapper getFeiShuInterceptors() => simpleInterceptors;

  Dio getDio(String baseUrl) {
    // 已存在该 baseUrl 的实例则直接复用，各域名互不干扰
    if (_dioMap.containsKey(baseUrl)) {
      logger.i('📌 复用现有 Dio 实例: $baseUrl');
      return _dioMap[baseUrl]!;
    }

    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(minutes: 1),
    ));

    // 添加拦截器
    dio.interceptors.add(geInterceptors);

    // 为 Android 平台配置 HttpClient，解决 SSL 证书和 DNS 问题
    if (GetPlatform.isAndroid) {
      (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();

        // 允许自签名证书（测试环境必需）
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          logger.w('⚠️ 证书接受: $host:$port');
          return true;
        };

        // 配置 DNS 超时
        client.connectionTimeout = const Duration(seconds: 10);

        // 禁用 HTTP 缓存，避免 DNS 问题
        client.autoUncompress = true;

        logger.i('✅ Dio HttpClient 已配置 for: $baseUrl');
        return client;
      };
    }

    _dioMap[baseUrl] = dio;
    logger.i('✅ 创建新的 Dio 实例: $baseUrl');
    return dio;
  }

  // 重置：仅清除 DNS 缓存，不再 force close 任何 Dio 实例。
  // 原先 reset 会强关唯一的 Dio，导致其它 baseUrl 在途请求被连坐取消；
  // 现在 Dio 按 baseUrl 各自独立，无需强关即可恢复（下次请求会重新解析 DNS）。
  void reset() {
    clearDnsCache();
    logger.i('🔄 DNS 缓存已重置（Dio 实例保留，避免误杀在途请求）');
  }
}
