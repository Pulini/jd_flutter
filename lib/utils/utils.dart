import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
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
import 'package:jd_flutter/utils/extension_util.dart';
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
      if (packageInfo().version.replaceAll('.', '').toIntTry() <
          versionInfo.versionName!.replaceAll('.', '').toIntTry()) {
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
    final physicalSize =  View.of(Get.context!).physicalSize;
    final devicePixelRatio = View.of(Get.context!).devicePixelRatio;
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
String getFileName(String url, {int num = 2}) {
  final code = unicodeDecode(url.replaceAll('%u', '\\u'));
  logger.f('url=$code');
  var name = code;
  for (var i = 1; i < num; i++) {
    name = name.substring(0, name.lastIndexOf('/'));
    if (i == num - 1) {
      name = code.substring(name.lastIndexOf('/') + 1);
    }
  }
  return name;
}
String unicodeDecode(String string) {
  var str = string;
  final regex = RegExp(r'(\\u(\w{4}))');
  final matches = regex.allMatches(str);

  for (final match in matches) {
    final unicodeHex = match.group(2)!;
    final unicodeInt = int.parse(unicodeHex, radix: 16);
    final unicodeChar = String.fromCharCode(unicodeInt);
    str = str.replaceFirst(match.group(1)!, unicodeChar);
  }

  return str;
}