import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http/response/user_info.dart';
import 'http/response/version_info.dart';
import 'http/web_api.dart';

late SharedPreferences sharedPreferences;
late PackageInfo packageInfo;

/// 保存SP数据
spSave(String key, Object value) {
  if (value is String) {
    sharedPreferences.setString(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is int) {
    sharedPreferences.setInt(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is double) {
    sharedPreferences.setDouble(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is bool) {
    sharedPreferences.setBool(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else {
    logger.e("error\nclass:${value.runtimeType}");
  }
}

/// 获取SP数据
dynamic spGet(String key) {
  var value = sharedPreferences.get(key);
  logger.d("read\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  switch (value.runtimeType) {
    case String:
      return value ?? "";
    case int:
      return value ?? 0;
    case double:
      return value ?? 0.0;
    case bool:
      return value ?? false;
    default:
      return value;
  }
}

///获取用户数据
UserInfo? userInfo() {
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

///获取服务器版本信息
getVersionInfo(bool showLoading,
    {required Function noUpdate, required Function(VersionInfo) needUpdate}) {
  httpGet(
    method: webApiCheckVersion,
    loading: showLoading ? 'checking_version'.tr : "",
  ).then((versionInfoCallback) {
    if (versionInfoCallback.resultCode == resultSuccess) {
      logger.f(packageInfo);
      var versionInfo =
          VersionInfo.fromJson(jsonDecode(versionInfoCallback.data));
      // versionInfo.versionName = "2.0.0";
      // versionInfo.force = false;
      if (packageInfo.version == versionInfo.versionName) {
        noUpdate.call();
      } else {
        needUpdate.call(versionInfo);
      }
    } else {
      errorDialog(Get.overlayContext!, content: versionInfoCallback.message);
    }
  });
}

///显示SnackBar
showSnackBar({required String title, required String message}) {
  Get.snackbar(title, message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueAccent,
      colorText: Colors.white);
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

logL(String msg) {
    const logMaxLength = 2000;
    var strLength = msg.length;
    var start = 0;
    var end = logMaxLength;
    for (int i1 = 0; i1 < logMaxLength; i1++) {
      if (strLength > end) {
        print(msg.substring(start, end));
        start = end;
        end += logMaxLength;
      } else {
        print(msg.substring(start, strLength));
        break;
      }
    }
}
