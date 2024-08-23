import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bean/http/response/user_info.dart';
import 'bean/http/response/version_info.dart';
import 'bean/http/response/worker_info.dart';
import 'web_api.dart';
import 'package:intl/intl.dart';

late SharedPreferences sharedPreferences;
late PackageInfo packageInfo;
late BaseDeviceInfo deviceInfo;
var localeChinese = const Locale('zh', 'Hans_CN');
var localeEnglish = const Locale('en', 'US');
SnackbarController? snackbarController;
SnackbarStatus? snackbarStatus;
UserInfo? userInfo;

/// 保存SP数据
spSave(String key, Object value) {
  if (value is String) {
    sharedPreferences.setString(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is int) {
    sharedPreferences.setInt(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is double) {
    sharedPreferences.setDouble(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is bool) {
    sharedPreferences.setBool(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else if (value is List<String>) {
    sharedPreferences.setStringList(key, value);
    logger.d('save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  } else {
    logger.e('error\nclass:${value.runtimeType}');
  }
}

/// 获取SP数据
dynamic spGet(String key) {
  var value = sharedPreferences.get(key);
  logger.d('read\nclass:${value.runtimeType}\nkey:$key\nvalue:$value');
  switch (value.runtimeType) {
    case String:
      return value ?? '';
    case int:
      return value ?? 0;
    case double:
      return value ?? 0.0;
    case bool:
      return value ?? false;
    case const (List<Object?>):
      return sharedPreferences.getStringList(key) ?? [];
    default:
      return value;
  }
}

///获取用户数据
UserInfo? getUserInfo() {
  try {
    var spUserInfo = sharedPreferences.get(spSaveUserInfo) as String?;
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

///获取设备唯一码
String getDeviceID() {
  if (GetPlatform.isAndroid) {
    return (deviceInfo as AndroidDeviceInfo).id;
  }
  if (GetPlatform.isIOS) {
    return (deviceInfo as IosDeviceInfo).identifierForVendor ?? '';
  }
  if (GetPlatform.isWeb) {
    return (deviceInfo as WebBrowserInfo).userAgent ?? '';
  }
  if (GetPlatform.isWindows) {
    return (deviceInfo as WindowsDeviceInfo).productId;
  }
  if (GetPlatform.isLinux) {
    return (deviceInfo as LinuxDeviceInfo).machineId ?? '';
  }
  if (GetPlatform.isMacOS) {
    return (deviceInfo as MacOsDeviceInfo).systemGUID ?? '';
  }
  return '';
}

///获取设备名称
String getDeviceName() {
  if (GetPlatform.isAndroid) {
    return (deviceInfo as AndroidDeviceInfo).model;
  }
  if (GetPlatform.isIOS) {
    return (deviceInfo as IosDeviceInfo).model;
  }
  if (GetPlatform.isWeb) {
    return (deviceInfo as WebBrowserInfo).vendor ?? '';
  }
  if (GetPlatform.isWindows) {
    return (deviceInfo as WindowsDeviceInfo).deviceId;
  }
  if (GetPlatform.isLinux) {
    return (deviceInfo as LinuxDeviceInfo).name;
  }
  if (GetPlatform.isMacOS) {
    return (deviceInfo as MacOsDeviceInfo).computerName;
  }
  return '';
}

///隐藏键盘而不丢失文本字段焦点：
hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

///BuildContext扩展
extension ContextExt on BuildContext {
  ///是否是大屏幕
  bool isLargeScreen() => MediaQuery.of(this).size.width > 768;

  ///是否是中屏幕
  bool isMediumScreen() =>
      MediaQuery.of(this).size.width > 425 &&
      MediaQuery.of(this).size.width < 1200;

  ///是否是小屏幕
  bool isSmallScreen() => MediaQuery.of(this).size.width < 768;
}

///Double扩展方法
extension DoubleExt on double? {
  ///double转string并去除小数点后为0的位数，非0不去除
  String toShowString() {
    if (this == null) {
      return '0';
    } else {
      return Decimal.parse(toString()).toString();
    }
  }

  double add(double value) =>
      (Decimal.parse(toString()) + Decimal.parse(value.toString())).toDouble();

  double sub(double value) =>
      (Decimal.parse(toString()) - Decimal.parse(value.toString())).toDouble();

  double mul(double value) =>
      (Decimal.parse(toString()) * Decimal.parse(value.toString())).toDouble();

  double div(double value) =>
      (Decimal.parse(toString()) / Decimal.parse(value.toString())).toDouble();
}

///File扩展方法
extension FileExt on File {
  ///图片转 base64
  String toBase64() => base64Encode(readAsBytesSync());
}

///String扩展方法
extension StringExt on String? {
  String md5Encode() =>
      md5.convert(const Utf8Encoder().convert(this ?? '')).toString();

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
}

extension RequestOptionsExt on RequestOptions {
  print() {
    Map<String, dynamic> map = <String, dynamic>{};
    map['RequestTime'] = DateTime.now();
    map['Method'] = method;
    map['BaseUrl'] = baseUrl;
    map['Path'] = path;
    map['Headers'] = headers;
    map['QueryParameters'] = queryParameters;
    map['Data'] = data;
    logger.f(map);
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

///Log日志工具
log(String msg) {
  var strLength = msg.length;
  var start = 0;
  var end = 2000;
  var printText = '';
  for (int i = 0; i < 999; i++) {
    if (strLength > end) {
      printText += '${msg.substring(start, end)}\n';
      debugPrint(msg.substring(start, end));
      start = end;
      end += 2000;
    } else {
      debugPrint(msg.substring(start, strLength));
      printText += '${msg.substring(start, strLength)}\n';
      break;
    }
  }
  logger.f(printText);
}

/// 权限检查
bool checkUserPermission(String code) {
  return userInfo?.jurisdictionList?.any((v) => v.jid == code) ?? false;
}

///Launch启动器
Future<void> goLaunch(Uri uri) async {
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}

///获取服务器版本信息
getVersionInfo(
  bool showLoading, {
  required Function noUpdate,
  required Function(VersionInfo) needUpdate,
}) {
  httpGet(
    method: webApiCheckVersion,
    loading: showLoading ? 'checking_version'.tr : '',
  ).then((versionInfoCallback) {
    if (versionInfoCallback.resultCode == resultSuccess) {
      logger.i(packageInfo);
      var versionInfo = VersionInfo.fromJson(versionInfoCallback.data);
      if (packageInfo.version == versionInfo.versionName) {
        noUpdate.call();
      } else {
        needUpdate.call(versionInfo);
      }
    } else {
      errorDialog(content: versionInfoCallback.message);
    }
  });
}

///更新app
upData() {
  httpGet(
    method: webApiCheckVersion,
    loading: 'checking_version'.tr,
  ).then((versionInfoCallback) {
    if (versionInfoCallback.resultCode == resultSuccess) {
      logger.i(packageInfo);
      doUpdate(VersionInfo.fromJson(versionInfoCallback.data));
    } else {
      errorDialog(content: versionInfoCallback.message);
    }
  });
}

///获取员工信息
getWorkerInfo({
  String? number,
  String? department,
  required Function(List<WorkerInfo>) workers,
  Function(String)? error,
}) {
  httpGet(method: webApiGetWorkerInfo, params: {
    'EmpNumber': number,
    'DeptmentID': department,
  }).then((worker) {
    if (worker.resultCode == resultSuccess) {
      workers.call([
        for (var i = 0; i < worker.data.length; ++i)
          WorkerInfo.fromJson(worker.data[i])
      ]);
    } else {
      error?.call(worker.message??'');
      errorDialog(content: worker.message);
    }
  });
}

String getDateYMD({DateTime? time}) {
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
  return '$y-$m-$d';
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
  final formattedTime =  DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

  return formattedTime;
}
