import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WiFiManager {
  /// 检查并请求WiFi权限
  Future<bool> requestWifiPermissions() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
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

      if (result) {
        // 等待连接建立
        await Future.delayed(Duration(seconds: 3));

        // 验证连接状态
        bool isConnected = await isConnectedToWiFi(ssid);
        return isConnected;
      }

      return false;
    } catch (e) {
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