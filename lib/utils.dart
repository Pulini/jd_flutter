import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'http/response/user_info.dart';
import 'http/response/version_info.dart';
import 'http/web_api.dart';

late SharedPreferences sharedPreferences;
late PackageInfo packageInfo;
late BaseDeviceInfo deviceInfo;
var localeChinese = const Locale('zh', 'Hans_CN');
var localeEnglish = const Locale('en', 'US');
SnackbarController? snackbarController;
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

///app 背景渐变色
var backgroundColor = const BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color.fromARGB(0xff, 0xe4, 0xe8, 0xda),
      Color.fromARGB(0xff, 0xba, 0xe9, 0xed)
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  ),
);

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
}

///File扩展方法
extension FileExt on File {
  ///图片转 base64
  String toBase64() => base64Encode(readAsBytesSync());
}

///String扩展方法
extension StringExt on String {
  String md5Encode() =>
      md5.convert(const Utf8Encoder().convert(this)).toString();
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
    map['data'] = data;
    logger.f(map);
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
      var versionInfo =
          VersionInfo.fromJson(jsonDecode(versionInfoCallback.data));
      // versionInfo.versionName = '2.0.0';
      // versionInfo.force = false;
      // versionInfo.url =
      //     'https://geapp.goldemperor.com:8021/AndroidUpdate/GoldEmperor/GE1.0.73.apk';
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
      doUpdate(VersionInfo.fromJson(jsonDecode(versionInfoCallback.data)));
    } else {
      errorDialog(content: versionInfoCallback.message);
    }
  });
}

///显示SnackBar
showSnackBar({required String title, required String message}) {
  snackbarController = Get.snackbar(title, message,
      margin: const EdgeInsets.all(10),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white, snackbarStatus: (state) {
    if (state == SnackbarStatus.CLOSED) snackbarController = null;
  });
}

getCupertinoPicker(List<Widget> items, FixedExtentScrollController controller) {
  return CupertinoPicker(
    scrollController: controller,
    diameterRatio: 1.5,
    magnification: 1.2,
    squeeze: 1.2,
    useMagnifier: true,
    itemExtent: 32,
    onSelectedItemChanged: (value) {},
    children: items,
  );
}

showPopup(Widget widget, {double? height}) {
  showCupertinoModalPopup(
    context: Get.overlayContext!,
    builder: (BuildContext context) {
      return AnimatedPadding(
          padding: MediaQuery.of(context).viewInsets,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: height ?? 260,
            color: Colors.grey[200],
            child: widget,
          ));
    },
  );
}

titleWithDrawer({
  required String title,
  required List<Widget> children,
  required Function query,
  required Widget? body,
}) {
  return Container(
    decoration: backgroundColor,
    child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(title),
        actions: [
          Builder(
            //不加builder会导致openDrawer崩溃
            builder: (context) => IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        child: ListView(children: [
          const SizedBox(height: 30),
          ...children,
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: () {
                  query.call();
                },
                child: Text(
                  'page_title_with_drawer_query'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ]),
      ),
      body: body,
    ),
  );
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

bool checkUserPermission(String code) {
  return userInfo?.jurisdictionList?.any((v) => v.jid == code) ?? false;
}
Future<void> goLaunch(Uri uri) async {
  if (!await launchUrl(uri)) {
    throw Exception('Could not launch $uri');
  }
}