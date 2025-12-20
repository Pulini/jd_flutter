import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WiFiManager {
  /// 检查并请求WiFi权限
  Future<bool> requestWifiPermissions() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  /// 锁定当前WiFi连接，防止vivo等手机自动切换网络
  Future<bool> lockCurrentNetwork() async {
    try {
      bool permissionsGranted = await requestWifiPermissions();
      if (!permissionsGranted) {
        throw Exception('缺少必要的权限');
      }

      // 获取当前WiFi信息
      final currentSSID = await WiFiForIoTPlugin.getSSID();
      if (currentSSID == null || currentSSID.isEmpty) {
        return false;
      }

      // 重新连接到当前网络以刷新连接状态
      await WiFiForIoTPlugin.connect(currentSSID);

      // 在Android平台上添加特殊处理
      if (Platform.isAndroid) {
        // 设置网络优先级，防止自动切换
        await WiFiForIoTPlugin.forceWifiUsage(true);

        // 等待网络稳定
        await Future.delayed(Duration(milliseconds: 1500));
      }

      return true;
    } catch (e) {
      print('锁定WiFi连接失败: $e');
      return false;
    }
  }


  /// 连接到指定WiFi网络
  Future<bool> connectToWiFi({
    required String ssid,
    required String password,
    NetworkSecurity security = NetworkSecurity.WPA,
  }) async {
    try {
      bool permissionsGranted = await requestWifiPermissions();
      if (!permissionsGranted) {
        throw Exception('缺少必要的权限');
      }

      // 执行连接
      bool result = await WiFiForIoTPlugin.connect(
        ssid,
        password: password,
        joinOnce: true,
        security: security,
      );

      return result;
    } catch (e) {
      return false;
    }
  }

  /// 断开当前WiFi连接
  Future<bool> disconnectFromWiFi({Function()? onSuccess}) async {
    try {
      bool permissionsGranted = await requestWifiPermissions();
      if (!permissionsGranted) {
        throw Exception('缺少必要的权限');
      }

      // 断开当前WiFi连接
      await WiFiForIoTPlugin.disconnect();

      // 执行成功回调
      onSuccess?.call();

      return true;
    } catch (e) {
      print('断开WiFi连接失败: $e');
      return false;
    }
  }

  /// 检查是否连接到指定WiFi
  Future<bool> isConnectedToWiFi(String expectedSSID) async {
    try {
      // 检查网络连接类型
      final result = await Connectivity().checkConnectivity();
      // 使用toString()方法进行比较
      if (result.toString() != ConnectivityResult.wifi.toString()) {
        return false;
      }

      // 获取当前连接的WiFi名称
      final currentSSID = await WiFiForIoTPlugin.getSSID();
      return currentSSID == expectedSSID;
    } catch (e) {
      return false;
    }
  }

}