import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/bean/http/response/sap_surplus_material_info.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/downloader.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

bool isTestUrl() => AppInitService.to.isTestUrl.value;

void toggleTestUrl() => AppInitService.to.toggle();

BaseDeviceInfo deviceInfo() => AppInitService.to.deviceInfo;

SharedPreferences sharedPreferences() => AppInitService.to.sharedPreferences;

PackageInfo packageInfo() => AppInitService.to.packageInfo;

bool hasFrontCamera() => AppInitService.to.hasFrontCamera();

bool hasBackCamera() => AppInitService.to.hasFrontCamera();

class AppInitService extends GetxService {
  RxBool isTestUrl = false.obs;
  late SharedPreferences sharedPreferences;
  late PackageInfo packageInfo;
  late BaseDeviceInfo deviceInfo;
  List<CameraDescription>? cameras;

  static AppInitService get to => Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      packageInfo = await PackageInfo.fromPlatform();
      deviceInfo = await DeviceInfoPlugin().deviceInfo;

      if (GetPlatform.isMobile) {
        try {
          cameras = await availableCameras();
        } catch (e) {
          debugPrint('相机初始化失败: $e');
          cameras = [];
        }
      }

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
    } catch (e) {
      debugPrint('应用初始化过程中出现错误: $e');
    } finally {
      // 确保无论如何都会导航到适当页面
      debugPrint('--------${userInfo == null ? 'to Login' : 'to Home'}-------');
      Get.offAll(() => userInfo == null ? const LoginPage() : const HomePage());
    }
  }

  initDatabase() async {
    var path = await getDatabasesPath();
    openDatabase(join(path, jdDatabase), version: 4, onCreate: (db, v) {
      debugPrint('onCreate -----------v=$v');
      db.execute(SaveDispatch.dbCreate);
      db.execute(SaveWorkProcedure.dbCreate);
      db.execute(BarCodeInfo.dbCreate);
      db.execute(SurplusMaterialLabelInfo.dbCreate);
      db.execute(WorkshopPlanningWorkersCache.dbCreate);
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


  bool hasFrontCamera() => cameras == null
      ? false
      : cameras!.any((v) => v.lensDirection == CameraLensDirection.front);

  bool hasBackCamera() => cameras == null
      ? false
      : cameras!.any((v) => v.lensDirection == CameraLensDirection.back);
}
