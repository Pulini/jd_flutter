import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jd_flutter/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http/response/user_info.dart';
import 'http/web_api.dart';

///隐藏键盘而不丢失文本字段焦点：
void hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

/// 保存SP数据
spSave(String key, Object value) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  if (value is String) {
    sp.setString(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is int) {
    sp.setInt(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is double) {
    sp.setDouble(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else if (value is bool) {
    sp.setBool(key, value);
    logger.d("save\nclass:${value.runtimeType}\nkey:$key\nvalue:$value");
  } else {
    logger.e("error\nclass:${value.runtimeType}");
  }
}

/// 获取SP数据
Future<dynamic> spGet(String key) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  var value = sp.get(key);
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
  }
}

///获取用户数据
Future<UserInfo> userInfo() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  try {
    return UserInfo.fromJson(jsonDecode(sp.get(spSaveUserInfo) as String));
  } on Error catch (e) {
    logger.e(e);
    return UserInfo();
  }
}


///屏幕适配工具
class ScreenUtil {
  static ScreenUtil instance = ScreenUtil();

  //设计稿的设备尺寸修改
  double width;
  double height;
  bool allowFontScaling;

  static late MediaQueryData _mediaQueryData;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double _pixelRatio;
  static late double _statusBarHeight;

  static late double _bottomBarHeight;

  static late double _textScaleFactor;

  ScreenUtil({
    this.width = 1080,
    this.height = 1920,
    this.allowFontScaling = false,
  });

  static ScreenUtil getInstance() {
    return instance;
  }

  void init(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    _mediaQueryData = mediaQuery;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _statusBarHeight = mediaQuery.padding.top;
    _bottomBarHeight = _mediaQueryData.padding.bottom;
    _textScaleFactor = mediaQuery.textScaleFactor;
  }

  static MediaQueryData get mediaQueryData => _mediaQueryData;

  ///每个逻辑像素的字体像素数，字体的缩放比例
  static double get textScaleFactory => _textScaleFactor;

  ///设备的像素密度
  static double get pixelRatio => _pixelRatio;

  ///当前设备宽度 dp
  static double get screenWidthDp => _screenWidth;

  ///当前设备高度 dp
  static double get screenHeightDp => _screenHeight;

  ///当前设备宽度 px
  static double get screenWidth => _screenWidth * _pixelRatio;

  ///当前设备高度 px
  static double get screenHeight => _screenHeight * _pixelRatio;

  ///状态栏高度 dp 刘海屏会更高
  static double get statusBarHeight => _statusBarHeight;

  ///底部安全区距离 dp
  static double get bottomBarHeight => _bottomBarHeight;

  ///实际的dp与设计稿px的比例
  get scaleWidth => _screenWidth / instance.width;

  get scaleHeight => _screenHeight / instance.height;

  ///根据设计稿的设备宽度适配
  ///高度也根据这个来做适配可以保证不变形
  setWidth(double width) => width * scaleWidth;

  /// 根据设计稿的设备高度适配
  /// 当发现设计稿中的一屏显示的与当前样式效果不符合时,
  /// 或者形状有差异时,高度适配建议使用此方法
  /// 高度适配主要针对想根据设计稿的一屏展示一样的效果
  setHeight(double height) => height * scaleHeight;

  ///字体大小适配方法
  ///@param fontSize 传入设计稿上字体的px ,
  ///@param allowFontScaling 控制字体是否要根据系统的“字体大小”辅助选项来进行缩放。默认值为false。
  ///@param allowFontScaling Specifies whether fonts should scale to respect Text Size accessibility settings. The default is false.
  setSp(double fontSize) => allowFontScaling
      ? setWidth(fontSize)
      : setWidth(fontSize) / _textScaleFactor;
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

///app 背景渐变色
backgroundColor() => const BoxDecoration(
        gradient: LinearGradient(
      colors: [
        Color.fromARGB(0xff, 0xe4, 0xe8, 0xda),
        Color.fromARGB(0xff, 0xba, 0xe9, 0xed)
      ],
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ));

///图片转 base64
Future<String> imageToBase64(File file) async {
  List<int> imageBytes = await file.readAsBytes();
  logger.i('图片大小:${imageBytes.length}');
  return base64Encode(imageBytes);
}