//隐藏键盘而不丢失文本字段焦点：
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

Future requestAllPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.camera,
    Permission.photos,
    Permission.speech,
    Permission.storage,
    Permission.location,
    Permission.phone,
    Permission.notification,
  ].request();

  if (await Permission.camera.isGranted) {
    print("相机权限申请通过");
  } else {
    print("相机权限申请失败");
  }

  if (await Permission.photos.isGranted) {
    print("照片权限申请通过");
  } else {
    print("照片权限申请失败");
  }

  if (await Permission.speech.isGranted) {
    print("语音权限申请通过");
  } else {
    print("语音权限申请失败");
  }

  if (await Permission.storage.isGranted) {
    print("文件权限申请通过");
  } else {
    print("文件权限申请失败");
  }

  if (await Permission.location.isGranted) {
    print("定位权限申请通过");
  } else {
    print("定位权限申请失败");
  }

  if (await Permission.phone.isGranted) {
    print("手机权限申请通过");
  } else {
    print("手机权限申请失败");
  }

  if (await Permission.notification.isGranted) {
    print("通知权限申请通过");
  } else {
    print("通知权限申请失败");
  }
}

Future requestCameraPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.camera,
  ].request();

  if (await Permission.camera.isGranted) {
    print("相机权限申请通过");
  } else {
    print("相机权限申请失败");
  }
}

Future requestPhotosPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.photos,
  ].request();

  if (await Permission.photos.isGranted) {
    print("照片权限申请通过");
  } else {
    print("照片权限申请失败");
  }
}

Future requestSpeechPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.speech,
  ].request();

  if (await Permission.speech.isGranted) {
    print("语音权限申请通过");
  } else {
    print("语音权限申请失败");
  }
}

Future requestStoragePermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.storage,
  ].request();

  if (await Permission.storage.isGranted) {
    print("文件权限申请通过");
  } else {
    print("文件权限申请失败");
  }
}

Future requestLocationPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.location,
  ].request();

  if (await Permission.location.isGranted) {
    print("定位权限申请通过");
  } else {
    print("定位权限申请失败");
  }
}

Future requestPhonePermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.phone,
  ].request();

  if (await Permission.phone.isGranted) {
    print("手机权限申请通过");
  } else {
    print("手机权限申请失败");
  }
}

Future requestNotificationPermission() async {
  Map<Permission, PermissionStatus> permission = await [
    Permission.notification,
  ].request();

  if (await Permission.notification.isGranted) {
    print("通知权限申请通过");
  } else {
    print("通知权限申请失败");
  }
}
const languageZh=Locale("zh","CN");
const languageEn=Locale("en");

Future<Locale> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? language = prefs.get("language") as String?;
  if (language == null) {
    return languageZh;
  } else {
    switch (language) {
      case "zh":
        return languageZh;
      case "en":
        return languageEn;
      default:
        return languageZh;
    }
  }
}
saveLanguage(String language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("language", language);
}