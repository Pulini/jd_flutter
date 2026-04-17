import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class DioManager {
  static Dio? _dio;
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
      if (e.error is SocketException) {
        var socketError = e.error as SocketException;
        logger.e('Socket Exception OS Error: ${socketError.osError}');
        logger.e('Socket Exception Address: ${socketError.address}');
        logger.e('Socket Exception Port: ${socketError.port}');

        // 检测到连接拒绝或网络不可达时，清除 DNS 缓存
        if (socketError.osError?.errorCode == 111 ||
            socketError.osError?.errorCode == 101) {
          logger.w('⚠️ 检测到网络连接错误，清除 DNS 缓存');
          clearDnsCache();
          _instance.reset();
        }
      }
      handler.next(e);
    },
  );

  InterceptorsWrapper getFeiShuInterceptors() => simpleInterceptors;

  Dio getDio(String baseUrl) {
    // 如果 baseUrl 变化或者 _dio 为空，创建新实例
    if (_dio == null || _dio!.options.baseUrl != baseUrl) {
      // 关闭旧的 Dio 实例
      if (_dio != null) {
        logger.i('🔄 baseUrl 变化，关闭旧实例: ${_dio!.options.baseUrl}');
        _dio?.close(force: true);
      }

      _dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(minutes: 1),
      ));

      // 添加拦截器
      _dio!.interceptors.add(geInterceptors);

      // 为 Android 平台配置 HttpClient，解决 SSL 证书和 DNS 问题
      if (Platform.isAndroid) {
        (_dio!.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
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

      logger.i('✅ 创建新的 Dio 实例: $baseUrl');
    } else {
      logger.i('📌 复用现有 Dio 实例: $baseUrl');
    }

    return _dio!;
  }

  // 重置Dio实例
  void reset() {
    _dio?.close(force: true);
    _dio = null;
    clearDnsCache();
    logger.i('🔄 Dio 实例和 DNS 缓存已重置');
  }
}
