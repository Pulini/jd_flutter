import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../bean/http/response/bar_code.dart';

bool isTestUrl() => AppInitService.to.isTestUrl.value;

void toggleTestUrl() => AppInitService.to.toggle();

BaseDeviceInfo deviceInfo() => AppInitService.to.deviceInfo;

SharedPreferences sharedPreferences() => AppInitService.to.sharedPreferences;

PackageInfo packageInfo() => AppInitService.to.packageInfo;

class AppInitService extends GetxService {
  RxBool isTestUrl = false.obs;
  late SharedPreferences sharedPreferences;
  late PackageInfo packageInfo;
  late BaseDeviceInfo deviceInfo;

  static AppInitService get to => Get.find();

  @override
  onInit() async {
    super.onInit();
    sharedPreferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    deviceInfo = await DeviceInfoPlugin().deviceInfo;
    userInfo = getUserInfo();
    var save = spGet('isTestUrl');
    if (save == null) {
      spSave('isTestUrl', false);
      isTestUrl.value = false;
    } else {
      isTestUrl.value = save;
    }
    if (GetPlatform.isMobile) {
      await initDatabase();
    }
    Get.offAll(() => userInfo == null ? const LoginPage() : const HomePage());
  }

  initDatabase() async {
    var path = await getDatabasesPath();
    openDatabase(join(path, jdDatabase), version: 3, onCreate: (db, v) {
      debugPrint('onCreate -----------v=$v');
      db.execute(SaveDispatch.dbCreate);
      db.execute(SaveWorkProcedure.dbCreate);
      db.execute(BarCodeInfo.dbCreate);
      db.execute(SurplusMaterialLabelInfo.dbCreate);
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
          default:
            break;
        }
      }
      db.close();
    }, onOpen: (db) {
      debugPrint('onOpen-------');
    });
  }

  toggle() {
    isTestUrl.toggle();
    spSave('isTestUrl', isTestUrl.value);
  }

  final Connectivity _connectivity = Connectivity();
  RxList<ConnectivityResult> networkStatus = [ConnectivityResult.none].obs;

  AppInitService() {
    _connectivity.onConnectivityChanged.listen(_notifyStatus);
  }

  checkConnectivity() {
    _connectivity.checkConnectivity().then(_notifyStatus);
  }

  bool isOnLine() => networkStatus.any((v) => v != ConnectivityResult.none);

  _notifyStatus(List<ConnectivityResult> result) {
    networkStatus.value = result;
    debugPrint('网络状态: $result');
  }
}
