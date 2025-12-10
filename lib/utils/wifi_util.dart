import 'package:wifi_iot/wifi_iot.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class WiFiManager {
  /// 检查并请求WiFi权限
  Future<bool> requestWifiPermissions() async {
    var status = await Permission.location.request();
    return status == PermissionStatus.granted;
  }

  /// 扫描可用的WiFi网络
  Future<List<WifiNetwork>> scanNetworks() async {
    try {
      bool permissionsGranted = await requestWifiPermissions();
      if (!permissionsGranted) {
        throw Exception('缺少必要的权限');
      }

      // 启用WiFi（如果尚未启用）
      await WiFiForIoTPlugin.forceWifiUsage(true);

      // 加载WiFi列表
      List<WifiNetwork> networks = await WiFiForIoTPlugin.loadWifiList();
      return networks;
    } catch (e) {
      return [];
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
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.wifi) {
        return false;
      }

      // 获取当前连接的WiFi名称
      String? currentSSID = await WiFiForIoTPlugin.getSSID();
      return currentSSID == expectedSSID;
    } catch (e) {
      return false;
    }
  }

  /// 获取当前WiFi连接信息
  Future<Map<String, dynamic>> getCurrentWiFiInfo() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.wifi) {
        String? ssid = await WiFiForIoTPlugin.getSSID();
        String? bssid = await WiFiForIoTPlugin.getBSSID();
        return {
          'connected': true,
          'ssid': ssid,
          'bssid': bssid,
        };
      } else {
        return {
          'connected': false,
        };
      }
    } catch (e) {
      print('获取WiFi信息失败: $e');
      return {
        'connected': false,
        'error': e.toString(),
      };
    }
  }

  /// 监听网络连接状态变化
  Stream<List<ConnectivityResult>> watchConnectivity() {
    return Connectivity().onConnectivityChanged;
  }
}
