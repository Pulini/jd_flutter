import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/bean/jpush_notification.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/message_center/message_info.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jpush_flutter/jpush_flutter.dart';
import 'package:jpush_flutter/jpush_interface.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';


BaseDeviceInfo deviceInfo() => AppInitService.to.deviceInfo;

SharedPreferences sharedPreferences() => AppInitService.to.sharedPreferences;

PackageInfo packageInfo() => AppInitService.to.packageInfo;

bool hasFrontCamera() => AppInitService.to.hasFrontCamera();

bool hasBackCamera() => AppInitService.to.hasFrontCamera();

double getDpi() => AppInitService.to.androidXDpi;

String getJPushID() => AppInitService.to.jpushID ?? 'Flutter_JPushID_isEmpty';

class AppInitService extends GetxService {

  late SharedPreferences sharedPreferences;
  late PackageInfo packageInfo;
  double androidXDpi = 0.0;
  late BaseDeviceInfo deviceInfo;
  List<CameraDescription>? cameras;
  final JPushFlutterInterface jpush = JPush.newJPush();
  String? jpushID;

  static AppInitService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initJPush();
    _initializeApp();
  }

  void _doJPush(Map<String, dynamic> json) {
    var push = JPushNotification.fromJson(json);
    if (push.isUpgrade()) {
      getVersionInfo(
        false,
        needUpdate: (v) => doUpdate(version: v),
        error: (msg) => errorDialog(content: msg),
      );
    } else if (push.isReLogin()) {
      spSave(spSaveUserInfo, '');
      reLoginPopup();
    }
  }

  Future<void> _initJPush() async {
    try {
      jpush.setCallBackHarmony((eventName, data) async {
        debugPrint('''jPush CallBackHarmony
        ---------------
        eventName:$eventName
        data:$data
        ---------------
        ''');
      });

      jpush.addEventHandler(
        onReceiveNotification: (message) async {
          debugPrint('''jPush onReceiveNotification
        ---------------
        message:$message
        ---------------
        ''');
          _doJPush(message);
        },
        onOpenNotification: (message) async {
          debugPrint('''jPush onOpenNotification
        ---------------
        message:$message
        ---------------
        ''');
          _doJPush(message);
        },
        onReceiveMessage: (message) async {
          debugPrint('''jPush onReceiveMessage
        ---------------
        message:$message
        ---------------
        ''');
        },
        onReceiveNotificationAuthorization: (message) async {
          debugPrint('''jPush onReceiveNotificationAuthorization
        ---------------
        message:$message
        ---------------
        ''');
        },
        onNotifyMessageUnShow: (message) async {
          debugPrint('''jPush onNotifyMessageUnShow
        ---------------
        message:$message
        ---------------
        ''');
        },
        onInAppMessageShow: (message) async {
          debugPrint('''jPush onInAppMessageShow
        ---------------
        message:$message
        ---------------
        ''');
        },
        onCommandResult: (message) async {
          debugPrint('''jPush onCommandResult
        ---------------
        message:$message
        ---------------
        ''');
        },
        onInAppMessageClick: (message) async {
          debugPrint('''jPush onInAppMessageClick
        ---------------
        message:$message
        ---------------
        ''');
        },
        onNotifyButtonClick: (message) async {
          debugPrint('''jPush onNotifyButtonClick
        ---------------
        message:$message
        ---------------
        ''');
        },
        onConnected: (message) async {
          debugPrint('''jPush onConnected
        ---------------
        message:$message
        ---------------
        ''');
        },
        onReceiveDeviceToken: (message) async {
          debugPrint('''jPush onReceiveDeviceToken
        ---------------
        message:$message
        ---------------
        ''');
        },
      );
    } on PlatformException {
      debugPrint('''jPush PlatformException
      ---------------
      Failed to get platform version.a
      ---------------
      ''');
    }

    jpush.setAuth(enable: true);
    jpush.setup(
      appKey: '038491b7cfc3a1b0e579550d', //你自己应用的 AppKey
      channel: 'developer-default',
      production: false,
      debug: true,
    );
    jpush.applyPushAuthority(
      const NotificationSettingsIOS(sound: true, alert: true, badge: true),
    );
    jpush.getRegistrationID().then((rid) {
      debugPrint('''jPush RegistrationID
      ---------------
      rid:$rid
      ---------------
      ''');
      jpushID = rid;
    });
    // iOS要是使用应用内消息，请在页面进入离开的时候配置pageEnterTo 和  pageLeave 函数，参数为页面名。
    jpush.pageEnterTo('home'); // 在离开页面的时候请调用 jpush.pageLeave('HomePage');
  }

  Future<void> _initializeApp() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      Get.put(LanguageController());
      packageInfo = await PackageInfo.fromPlatform();
      deviceInfo = await DeviceInfoPlugin().deviceInfo;
      androidXDpi = await getAndroidXDpi();
      debugPrint('androidXDpi: $androidXDpi');
      if (GetPlatform.isMobile) {
        try {
          cameras = await availableCameras();
        } catch (e) {
          debugPrint('相机初始化失败: $e');
          cameras = [];
        }
      }

      userInfo = getUserInfo();
      mesBaseUrl = getMesBaseUrl().value;
      sapBaseUrl = getSapBaseUrl().value;
      if (GetPlatform.isMobile) {
        await initDatabase();
      }
    } catch (e) {
      debugPrint('应用初始化过程中出现错误: $e');
    } finally {
      // 确保无论如何都会导航到适当页面
      debugPrint('--------${userInfo == null ? 'to Login' : 'to Home'}-------');
      Get.offAll(() => userInfo == null ? const LoginPage() : const HomePage());
    }
  }


  Future<void> initDatabase() async {
    var path = await getDatabasesPath();
    openDatabase(join(path, jdDatabase), version: 5, onCreate: (db, v) {
      debugPrint('onCreate -----------v=$v');
      db.execute(SaveDispatch.dbCreate);
      db.execute(SaveWorkProcedure.dbCreate);
      db.execute(BarCodeInfo.dbCreate);
      db.execute(SurplusMaterialLabelInfo.dbCreate);
      db.execute(WorkshopPlanningWorkersCache.dbCreate);
      db.execute(MessageInfo.dbCreate);
      db.close();
    }, onUpgrade: (db, ov, nv) {
      debugPrint('onUpgrade-----------ov=$ov nv=$nv');
      // 从版本1开始，逐步处理到最新版本的升级操作
      for (int cv = ov + 1; cv <= nv; cv++) {
        switch (cv) {
          case 2: // 版本1升级到版本2
            debugPrint('版本1升级到版本2');
            db.execute(BarCodeInfo.dbCreate);
            break;
          case 3: // 版本2升级到版本3
            debugPrint('版本2升级到版本3');
            db.execute(SurplusMaterialLabelInfo.dbCreate);
            break;
          case 4: // 版本3升级到版本4
            debugPrint('版本3升级到版本4');
            db.execute(WorkshopPlanningWorkersCache.dbCreate);
            break;
          case 5: // 版本4升级到版本5
            debugPrint('版本4升级到版本5');
            db.execute(MessageInfo.dbCreate);
            break;
          default:
            break;
        }
      }
      db.close();
    }, onOpen: (db) {
      debugPrint('onOpen-------');
    });
  }

  bool hasFrontCamera() => cameras == null
      ? false
      : cameras!.any((v) => v.lensDirection == CameraLensDirection.front);

  bool hasBackCamera() => cameras == null
      ? false
      : cameras!.any((v) => v.lensDirection == CameraLensDirection.back);


}

class LanguageController extends GetxController {
  static LanguageController get to => Get.find();

  var currentLocale = const Locale('zh', '').obs;

  @override
  onReady() {
    var save = spGet('language');
    if (save == null) {
      spSave('language', localeChinese.languageCode);
    } else {
      changeLanguage(Locale(save));
    }
  }

  void changeLanguage(Locale locale) {
    currentLocale.value = locale;
    spSave('language', locale.languageCode);
    Get.updateLocale(locale);
  }
}
