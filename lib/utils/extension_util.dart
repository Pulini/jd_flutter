import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';

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
extension RequestOptionsExt on RequestOptions {
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

extension ApiResponseExtensions<T> on Response<T> {
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
