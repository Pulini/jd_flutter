import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/screen_util.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/leader_info.dart';
import 'package:jd_flutter/bean/http/response/process_specification_info.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/bean/http/response/user_info.dart';
import 'package:jd_flutter/bean/http/response/version_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/downloader.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_init_service.dart';
import 'web_api.dart';

SnackbarController? snackbarController;
SnackbarStatus? snackbarStatus;
UserInfo? userInfo;

// 保存SP数据
spSave(String key, Object value) {
  if (value is String) {
    sharedPreferences().setString(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is int) {
    sharedPreferences().setInt(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is double) {
    sharedPreferences().setDouble(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is bool) {
    sharedPreferences().setBool(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is List<String>) {
    sharedPreferences().setStringList(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else {
    logger.e('error\nclass:${value.runtimeType}');
  }
}

// 获取SP数据
dynamic spGet(String key) {
  try {
    var value = sharedPreferences().get(key);
    logger.d('read\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
    switch (value.runtimeType) {
      case const (String):
        return value ?? '';
      case const (int):
        return value ?? 0;
      case const (double):
        return value ?? 0.0;
      case const (bool):
        return value ?? false;
      case const (List<Object?>):
        return sharedPreferences().getStringList(key) ?? [];
      default:
        return value;
    }
  } catch (e) {
    debugPrint('$key--------read sp error-------');
    return null;
  }
}

//获取用户数据
UserInfo? getUserInfo() {
  try {
    var spUserInfo = sharedPreferences().get(spSaveUserInfo) as String?;
    debugPrint('spUserInfo=$spUserInfo');
    if (spUserInfo != null) {
      return UserInfo.fromJson(jsonDecode(spUserInfo));
    }
  } on Error catch (e) {
    logger.e(e.runtimeType);
  } on Exception catch (e) {
    logger.e(e.runtimeType);
  }
  return null;
}

//获取设备唯一码
String getDeviceID() {
  if (GetPlatform.isAndroid) {
    return (deviceInfo() as AndroidDeviceInfo).id;
  }
  if (GetPlatform.isIOS) {
    return (deviceInfo() as IosDeviceInfo).identifierForVendor ?? '';
  }
  if (GetPlatform.isWeb) {
    return (deviceInfo() as WebBrowserInfo).userAgent ?? '';
  }
  if (GetPlatform.isWindows) {
    return (deviceInfo() as WindowsDeviceInfo).productId;
  }
  if (GetPlatform.isLinux) {
    return (deviceInfo() as LinuxDeviceInfo).machineId ?? '';
  }
  if (GetPlatform.isMacOS) {
    return (deviceInfo() as MacOsDeviceInfo).systemGUID ?? '';
  }
  return '';
}

//获取设备名称
String getDeviceName() {
  if (GetPlatform.isAndroid) {
    return (deviceInfo() as AndroidDeviceInfo).model;
  }
  if (GetPlatform.isIOS) {
    return (deviceInfo() as IosDeviceInfo).model;
  }
  if (GetPlatform.isWeb) {
    return (deviceInfo() as WebBrowserInfo).vendor ?? '';
  }
  if (GetPlatform.isWindows) {
    return (deviceInfo() as WindowsDeviceInfo).deviceId;
  }
  if (GetPlatform.isLinux) {
    return (deviceInfo() as LinuxDeviceInfo).name;
  }
  if (GetPlatform.isMacOS) {
    return (deviceInfo() as MacOsDeviceInfo).computerName;
  }
  return '';
}

//隐藏键盘而不丢失文本字段焦点：
hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

//BuildContext扩展
extension ContextExt on BuildContext {
  //是否是大屏幕
  bool isLargeScreen() => MediaQuery.of(this).size.width > 768;

  //是否是中屏幕
  bool isMediumScreen() =>
      MediaQuery.of(this).size.width > 425 &&
      MediaQuery.of(this).size.width < 1200;

  //是否是小屏幕
  bool isSmallScreen() => MediaQuery.of(this).size.width < 768;
}

//Double扩展方法
extension DoubleExt on double? {
  //double转string并去除小数点后为0的位数，非0不去除
  String toShowString() {
    if (this == null) {
      return '0';
    } else {
      return Decimal.parse(toString()).toString();
    }
  }

  //double转string并保留最大6位小数
  String toMaxString() => toFixed(6).toShowString();

  double toFixed(int fractionDigits) {
    if (this == null) return 0;
    return double.parse(this!.toStringAsFixed(fractionDigits));
  }

  double add(double value) =>
      (Decimal.parse(toString()) + Decimal.parse(value.toString())).toDouble();

  double sub(double value) =>
      (Decimal.parse(toString()) - Decimal.parse(value.toString())).toDouble();

  double mul(double value) =>
      (Decimal.parse(toString()) * Decimal.parse(value.toString())).toDouble();

  double div(double value) {
    if (value == 0) return 0;
    return (Decimal.parse(toString()) / Decimal.parse(value.toString()))
        .toDouble();
  }
}

extension Uint8ListExt on Uint8List {
  toHexString() {
    var hexString = '';
    for (int i = 0; i < length; i++) {
      String hex = this[i].toRadixString(16);
      if (hex.length == 1) {
        hexString += '0';
      }
      hexString += hex;
    }
    return hexString.toUpperCase();
  }

  String toBase64() => base64Encode(this);
}

//File扩展方法
extension FileExt on File {
  //图片转 base64
  String toBase64() => base64Encode(readAsBytesSync());
}

//String扩展方法
extension StringExt on String? {
  String md5Encode() =>
      md5.convert(const Utf8Encoder().convert(this ?? '')).toString();

  bool isNullOrEmpty() => this?.isEmpty ?? true;

  double toDoubleTry() {
    try {
      return double.parse(this ?? '');
    } on Exception catch (_) {
      return 0.0;
    }
  }

  int toIntTry() {
    try {
      return int.parse(this ?? '');
    } on Exception catch (_) {
      return 0;
    }
  }

  String ifEmpty(String v) {
    if (this != null && this?.isNotEmpty == true) {
      return this!;
    } else {
      return v;
    }
  }

  bool isLabel() {
    final regex = RegExp(
        r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$');
    final upperCaseInput = (this ?? '').toUpperCase();

    if (regex.hasMatch(upperCaseInput)) {
      return true;
    }

    final parts = (this ?? '').split('/');
    if (parts.length == 2 && parts[1].length == 3) {
      return true;
    }

    if ((this ?? '').length == 32) {
      return true;
    }
    return false;
  }

  bool isPallet() =>
      (this ?? '').startsWith('GE') &&
      (this ?? '').length >= 10 &&
      (this ?? '').length <= 13;

  //允许英文单词在换行时截断
  String allowWordTruncation() => Characters(this ?? '').join('\u{200B}');

  int hexToInt() {
    return int.parse(this ?? '', radix: 16);
  }

  Color getColorByDescription() {
    // 定义一个颜色映射表，将常见的颜色中文描述映射到对应的颜色值
    Map<String, Color> colorMap = {
      '红': const Color(0xFFFF0000),
      '橙': const Color(0xFFFFA500),
      '黄': const Color(0xFFFFFF00),
      '绿': const Color(0xFF00FF00),
      '青': const Color(0xFF00FFFF),
      '蓝': const Color(0xFF0000FF),
      '紫': const Color(0xFF800080),
      '黑': const Color(0xFF000000),
      '白': const Color(0xFFFFFFFF),
      '灰': const Color(0xFF808080),
      '粉': const Color(0xFFFFC0CB),
      '棕': const Color(0xFFA52A2A),
      '金': const Color(0xFFFFD700),
      '银': const Color(0xFFC0C0C0),
      '天蓝': const Color(0xFF87CEEB),
      '草绿': const Color(0xFF7CC57C),
      '深蓝': const Color(0xFF00008B),
      '浅蓝': const Color(0xFFADD8E6),
      '深绿': const Color(0xFF006400),
      '浅绿': const Color(0xFF90EE90),
      '深红': const Color(0xFF8B0000),
      '浅红': const Color(0xFFFFB6C1),
      '深紫': const Color(0xFF4B0082),
      '浅紫': const Color(0xFFE6E6FA),
      '橄榄绿': const Color(0xFF808000),
      '珊瑚': const Color(0xFFFF7F50),
      '桃红': const Color(0xFFFFDAB9),
      '杏': const Color(0xFFFED8B1),
      '橄榄': const Color(0xFF808000),
      '薄荷绿': const Color(0xFFB2FFFC),
      '丁香紫': const Color(0xFFE6E6FA),
      '湖蓝': const Color(0xFFADD8E6),
      '象牙白': const Color(0xFFFFFFF0),
      '巧克力': const Color(0xFFD2691E),
      '咖啡': const Color(0xFF6F4E37),
      '栗': const Color(0xFFCD5C5C),
      '紫罗兰': const Color(0xFFEE82EE),
      '宝石红': const Color(0xFF8B0000),
      '宝石蓝': const Color(0xFF4169E1),
      '宝石绿': const Color(0xFF006400),
      '宝石紫': const Color(0xFF800080),
      '宝石黄': const Color(0xFFFFD700),
      '宝石黑': const Color(0xFF000000),
      '宝石白': const Color(0xFFFFFFFF),
      '宝石灰': const Color(0xFF808080),
      '宝石粉': const Color(0xFFFFC0CB),
      '宝石棕': const Color(0xFFA52A2A),
      '宝石金': const Color(0xFFFFD700),
      '宝石银': const Color(0xFFC0C0C0),
      '蔚蓝': const Color(0xFF388EBA),
      '湛蓝': const Color(0xFF0077BE),
      '宝蓝': const Color(0xFF4A235A),
      '藏青': const Color(0xFF000080),
      '墨绿': const Color(0xFF006400),
      '军校绿': const Color(0xFF4B5320),
      '卡其': const Color(0xFFF0E68C),
      '米': const Color(0xFFF5F5DC),
      '驼': const Color(0xFFC19A6B),
      '香槟': const Color(0xFFF7E7CE),
      '杏仁': const Color(0xFFF0F0F0),
      '薰衣草紫': const Color(0xFFE6E6FA),
      '樱花粉': const Color(0xFFFEDCDC),
      '蜜桃粉': const Color(0xFFFFD5E0),
      '水绿': const Color(0xFF00FFFF),
      '柠檬黄': const Color(0xFFFFFF00),
      '香蕉黄': const Color(0xFFFFE135),
      '芒果黄': const Color(0xFFFFD500),
      '橘黄': const Color(0xFFFFA500),
      '橙红': const Color(0xFFFF4500),
      '番茄红': const Color(0xFFFF6347),
      '玫瑰红': const Color(0xFFFF007F),
      '樱桃红': const Color(0xFFF08080),
      '葡萄酒红': const Color(0xFF722F37),
      '玫瑰紫': const Color(0xFF9932CC),
      // 可以根据需要继续添加其他颜色映射
    };

    // 遍历颜色映射表的键（即颜色中文描述）
    for (var colorName in colorMap.keys) {
      // 检查描述字符串中是否包含该颜色中文描述
      if (this?.contains(colorName) == true) {
        // 如果包含，则返回对应的颜色值
        return colorMap[colorName]!;
      }
    }
    // 如果描述字符串中没有找到匹配的颜色字样，则返回默认颜色，这里以透明色为例
    return Colors.transparent;
  }
}

loggerF(Map<String, dynamic> map) {
  if (map.toString().length > 500) {
    map['日志类型'] = '异步打印日志';
    compute(_logF, map);
  } else {
    map['日志类型'] = '直接打印日志';
    logger.f(map);
  }
}

_logF(Map<String, dynamic> data) {
  logger.f(data);
}

extension RequestOptionsExt on dio.RequestOptions {
  print() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['Type'] = '===发送请求===';
    map['RequestTime'] = DateTime.now();
    map['Method'] = method;
    map['BaseUrl'] = baseUrl;
    map['Path'] = path;
    map['Headers'] = headers;
    map['QueryParameters'] = queryParameters;
    map['Data'] = data;
    loggerF(map);
  }
}

extension ApiResponseExtensions<T> on dio.Response<T> {
  BaseData getBaseData() {
    var base = BaseData.fromJson(data);
    Map<String, dynamic> map = <String, dynamic>{};
    map['Type'] = '===收到响应===';
    map['ResponseTime'] = DateTime.now();
    map['BaseUrl'] = requestOptions.baseUrl;
    map['Path'] = requestOptions.path;
    map['Status'] = '$statusCode';
    map['ResultCode'] = base.resultCode;
    map['Data'] = base.data;
    map['Message'] = base.message;
    loggerF(map);
    return base;
  }
}

extension ListExt on List? {
  bool isNullOrEmpty() {
    if (this == null) return true;
    return this!.isEmpty;
  }
}

class TapUtil {
  static debounce(Function() fn) {
    Timer? debounce;
    return () {
      // 还在时间之内，抛弃上一次
      if (debounce?.isActive ?? false) {
        debounce?.cancel();
      } else {
        fn.call();
      }
      debounce = Timer(const Duration(seconds: 2), () {
        debounce?.cancel();
        debounce = null;
      });
    };
  }
}

// 权限检查
bool checkUserPermission(String code) {
  return userInfo?.jurisdictionList?.any((v) => v.jid == code) ?? false;
}

//Launch启动器
Future<void> goLaunch(Uri uri) async {
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

//获取服务器版本信息
getVersionInfo(
  bool showLoading, {
  Function? noUpdate,
  required Function(VersionInfo) needUpdate,
  required Function(String) error,
}) {
  httpGet(
    method: webApiCheckVersion,
    loading: showLoading ? 'checking_version'.tr : '',
  ).then((versionInfoCallback) {
    if (versionInfoCallback.resultCode == resultSuccess) {
      logger.i(packageInfo());
      var versionInfo = VersionInfo.fromJson(versionInfoCallback.data);
      if (packageInfo().buildNumber.toIntTry() < versionInfo.versionCode!) {
        needUpdate.call(versionInfo);
      } else {
        noUpdate?.call();
      }
    } else {
      error.call(versionInfoCallback.message ?? '');
    }
  });
}

//更新app
upData() {
  httpGet(
    method: webApiCheckVersion,
    loading: 'checking_version'.tr,
  ).then((versionInfoCallback) {
    if (versionInfoCallback.resultCode == resultSuccess) {
      logger.i(packageInfo());
      if (versionInfoCallback.baseUrl == baseUrlForMES) {
        doUpdate(version: VersionInfo.fromJson(versionInfoCallback.data));
      }
    } else {
      errorDialog(content: versionInfoCallback.message);
    }
  });
}

//获取员工信息
getWorkerInfo({
  String? number,
  String? department,
  required Function(List<WorkerInfo>) workers,
  required Function(String) error,
}) {
  httpGet(method: webApiGetWorkerInfo, params: {
    'EmpNumber': number,
    'DeptmentID': department,
  }).then((worker) {
    if (worker.resultCode == resultSuccess) {
      workers.call([for (var json in worker.data) WorkerInfo.fromJson(json)]);
    } else {
      error.call(worker.message ?? '');
    }
  });
}

checkStockLeaderConfig({
  String? showLoading,
  required String type,
  required String number,
  required String factoryNumber,
  required String stockNumber,
  required Function(List<LeaderInfo>) hasConfig,
  required Function() noConfig,
  required Function(String) error,
}) {
  httpGet(
    loading: showLoading,
    method: webApiGetStockFaceConfig,
    params: {
      'BillType': type,
      'EmpCode': number,
      'SapFactoryNumber': factoryNumber,
      'SapStockNumber': stockNumber,
    },
  ).then((config) {
    if (config.resultCode == resultSuccess) {
      var data = LeaderConfigInfo.fromJson(config.data);
      if (data.isEnableFaceRecognition == true) {
        hasConfig.call(data.leaderList ?? []);
      } else {
        noConfig.call();
      }
    } else {
      error.call(config.message ?? 'query_default_error'.tr);
    }
  });
}

getProcessManual({
  required String typeBody,
  required Function(List<ProcessSpecificationInfo>) manualList,
  required Function(String) error,
}) {
  if (typeBody.isEmpty) {
    showSnackBar(message: 'view_process_specification_query_hint'.tr);
    return;
  }
  httpGet(
    loading: 'view_process_specification_querying'.tr,
    method: webApiGetProcessSpecificationList,
    params: {
      'Product': typeBody,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      manualList([
        for (var item in response.data) ProcessSpecificationInfo.fromJson(item)
      ]);
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

getAlreadyInStockBarCode({
  required BarCodeReportType type,
  required Function(List<UsedBarCodeInfo>) success,
  required Function(String) error,
}) {
  httpGet(
    method: webApiGetBarCodeStatusByDepartmentID,
    params: {
      'Type': type.text,
      'DepartmentID': userInfo?.departmentID,
    },
  ).then((response) async {
    if (response.resultCode == resultSuccess) {
      success.call(await compute(
        parseJsonToList,
        ParseJsonParams(
          response.data,
          UsedBarCodeInfo.fromJson,
        ),
      ));
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

getWaitInStockBarCodeReport({
  required List<BarCodeInfo> barCodeList,
  required BarCodeReportType type,
  bool reverse = false,
  int? processFlowID,
  int? organizeID,
  int? defaultStockID,
  int? userID,
  required Function(dynamic) success,
  required Function(String) error,
}) {
  httpPost(
    loading: '正在获取汇总信息...',
    method: webApiNewGetSubmitBarCodeReport,
    body: {
      'BarCodeList': [
        for (var item in barCodeList)
          {
            'BarCode': item.code,
            'PalletNo': item.palletNo,
          }
      ],
      'BillTypeID': type.value,
      'Red': reverse,
      'ProcessFlowID': processFlowID ?? 0,
      'OrganizeID': organizeID ?? userInfo?.organizeID,
      'DefaultStockID': defaultStockID ?? userInfo?.defaultStockID,
      'UserID': userID ?? userInfo?.userID,
    },
  ).then((response) {
    if (response.resultCode == resultSuccess) {
      success.call(response.data);
    } else {
      error.call(response.message ?? 'query_default_error'.tr);
    }
  });
}

String getDateYMD({DateTime? time}) {
  DateTime now = time ?? DateTime.now();
  var y = now.year.toString();
  var m = now.month.toString();
  if (m.length == 1) m = '0$m';
  var d = now.day.toString();
  if (d.length == 1) d = '0$d';
  return '$y-$m-$d';
}

String getTimeHms({DateTime? time}) {
  DateTime now = time ?? DateTime.now();
  var h = now.hour.toString();
  if (h.length == 1) h = '0$h';
  var m = now.minute.toString();
  if (m.length == 1) m = '0$m';
  var s = now.second.toString();
  if (s.length == 1) s = '0$s';

  return '$h:$m:$s';
}

String getDateSapYMD({DateTime? time}) {
  DateTime now;
  if (time == null) {
    now = DateTime.now();
  } else {
    now = time;
  }
  var y = now.year.toString();
  var m = now.month.toString();
  if (m.length == 1) m = '0$m';
  var d = now.day.toString();
  if (d.length == 1) d = '0$d';
  return '$y$m$d';
}

visitButtonWidget({
  required String title,
  required Function click,
}) {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () {
          click.call();
        },
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
}

Future<Database> openDb() async {
  return openDatabase(join(await getDatabasesPath(), jdDatabase));
}

String getCurrentTime() {
  final now = DateTime.now();
  var year = now.year.toString();
  var month = now.month.toString();
  if (month.length == 1) month = '0$month';
  var day = now.day.toString();
  if (day.length == 1) day = '0$day';
  var hour = now.hour.toString();
  if (hour.length == 1) hour = '0$hour';
  var minute = now.minute.toString();
  if (minute.length == 1) minute = '0$minute';
  var second = now.second.toString();
  if (second.length == 1) second = '0$second';
  return '$year-$month-$day $hour:$minute:$second';
}

checkUrlType({
  required String url,
  required Function(String) jdPdf,
  required Function(String) web,
}) {
  if (url.endsWith('pdf') && url.contains('url=')) {
    jdPdf.call(extractUrl(url));
  } else {
    web.call(url);
  }
}

String extractUrl(String url) {
  int startIndex = 0;
  if (url.contains('url=')) {
    startIndex = url.indexOf('url=') + 4;
  }
  return escapeDecode(url.substring(startIndex));
}

String escapeDecode(String input) {
  // 使用正则表达式匹配所有的 \uXXXX 格式的 Unicode 编码
  final RegExp unicodeRegex = RegExp('%u([0-9a-fA-F]{4})');

  // 替换所有匹配的 Unicode 编码
  return input.replaceAllMapped(unicodeRegex, (Match match) {
    String hex = match.group(1)!;
    int codePoint = int.parse(hex, radix: 16);
    return String.fromCharCode(codePoint);
  });
}

String escapeEncode(String originalString) {
  return originalString.codeUnits
      .map((codeUnit) => '%u${codeUnit.toRadixString(16).padLeft(4, '0')}')
      .join()
      .replaceAllMapped(
        RegExp(r'\\u([0-9A-Fa-f]{4})'),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
      );
}

bool containsChinese(String input) {
  // 使用正则表达式匹配中文字符
  final RegExp chineseRegex = RegExp(r'[\u4e00-\u9fff]');

  // 检查字符串中是否存在匹配的中文字符
  return chineseRegex.hasMatch(input);
}

weighbridgeOpen() async {
  await const MethodChannel(channelWeighbridgeAndroidToFlutter)
      .invokeMethod('OpenDevice');
}

weighbridgeListener({
  required Function() usbAttached,
  required Function(String) weighbridgeState,
  required Function(double) readWeight,
}) {
  debugPrint('weighbridge 注册监听');
  const MethodChannel(channelWeighbridgeFlutterToAndroid)
      .setMethodCallHandler((call) {
    switch (call.method) {
      case 'WeighbridgeState':
        {
          weighbridgeState.call(call.arguments);
        }
        break;
      case 'WeighbridgeRead':
        {
          readWeight.call(call.arguments);
        }
        break;
    }
    return Future.value(call);
  });
  const MethodChannel(channelUsbFlutterToAndroid).setMethodCallHandler((call) {
    switch (call.method) {
      case 'UsbState':
        {
          if (call.arguments == 'Attached') {
            debugPrint('USB设备插入');
            usbAttached.call();
          }
        }
        break;
    }
    return Future.value(call);
  });
}

randomDouble(double min, double max) =>
    min + Random().nextDouble() * (max - min);

//dp转换成px
int dp2Px(double dp, BuildContext context) {
  MediaQueryData mq = MediaQuery.of(context);
  // 屏幕密度
  double pixelRatio = mq.devicePixelRatio;

  return (dp * pixelRatio + 1).toInt();
}

livenFaceVerification({
  required String faceUrl,
  required Function(String) verifySuccess,
}) {
  Downloader(
    url: faceUrl,
    completed: (filePath) {
      Permission.camera.request().isGranted.then((permission) {
        if (permission) {
          const MethodChannel(channelFaceVerificationAndroidToFlutter)
              .invokeMethod('StartDetect', filePath)
              .then((v) {
            // Get.dialog( AlertDialog( content: Image.memory(v)));
            verifySuccess.call((v as Uint8List).toBase64());
          }).catchError((e) => errorDialog(
                  content: '人脸验证错误：${(e as PlatformException).message}'));
        } else {
          errorDialog(content: '缺少相机权限');
        }
      });
    },
  );
}

//获取Sap供应商列表
Future getStorageLocationList(String factoryNumber) async {
  var response = await httpGet(
      method: webApiGetStorageLocationList,
      params: {'FactoryNumber': factoryNumber});
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      list.addAll(await compute(
        parseJsonToList,
        ParseJsonParams(
          response.data,
          LocationInfo.fromJson,
        ),
      ));
      return list;
    } on Error catch (e) {
      logger.e(e);
      return 'json_format_error'.tr;
    }
  } else {
    return response.message;
  }
}

//根据userId获取负责部门列表
Future getResponsibleDepartmentList(int userID) async {
  var response = await httpGet(
      method: webApiGetResponsibleDepartmentList, params: {'UserID': userID});
  if (response.resultCode == resultSuccess) {
    try {
      List<PickerItem> list = [];
      list.addAll(await compute(
        parseJsonToList,
        ParseJsonParams(
          response.data,
          ResponsibleDepartmentInfo.fromJson,
        ),
      ));
      return list;
    } on Error catch (e) {
      logger.e(e);
      return 'json_format_error'.tr;
    }
  } else {
    return response.message;
  }
}

hidKeyboard() {
  FocusScope.of(Get.overlayContext!).requestFocus(FocusNode());
}

String textToKey(String text) {
  if (text.isEmpty) return 'empty';
  final bytes = utf8.encode(text);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

/// 获取屏幕逻辑尺寸（考虑了设备像素比）
Size getScreenSize() {
  final view = WidgetsBinding.instance.platformDispatcher.implicitView;
  if (view != null) {
    final physicalSize = view.physicalSize;
    final devicePixelRatio = view.devicePixelRatio;
    return physicalSize / devicePixelRatio;
  } else {
    final physicalSize = WidgetsBinding.instance.window.physicalSize;
    final devicePixelRatio = WidgetsBinding.instance.window.devicePixelRatio;
    return physicalSize / devicePixelRatio;
  }
}

/// 获取屏幕宽度（逻辑像素）
double getScreenWidth() {
  return getScreenSize().width;
}

/// 获取屏幕高度（逻辑像素）
double getScreenHeight() {
  return getScreenSize().height;
}

/// 获取屏幕方向
Orientation getScreenOrientation() {
  final size = getScreenSize();
  return size.width > size.height
      ? Orientation.landscape
      : Orientation.portrait;
}
