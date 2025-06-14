import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


isTestUrl() =>AppInitController.to.isTestUrl.value;
toggleTestUrl() =>AppInitController.to.isTestUrl.toggle();
deviceInfo() =>AppInitController.to.deviceInfo;
sharedPreferences() =>AppInitController.to.sharedPreferences;
packageInfo() =>AppInitController.to.packageInfo;


class AppInitController extends GetxController {
  RxBool isTestUrl = false.obs;
  late SharedPreferences sharedPreferences;
  late PackageInfo packageInfo;
  late BaseDeviceInfo deviceInfo;
  static AppInitController get to => Get.find();

  @override
  onInit() async {
    super.onInit();
    sharedPreferences = await SharedPreferences.getInstance();
    packageInfo = await PackageInfo.fromPlatform();
    deviceInfo = await DeviceInfoPlugin().deviceInfo;
    var save=spGet('isTestUrl');
    if(save==null){
      spSave('isTestUrl', false);
      isTestUrl.value =false;
    }else{
      isTestUrl.value = save;
    }
  }

  toggle() {
    isTestUrl.toggle();
    spSave('isTestUrl', isTestUrl.value);
  }

  final Connectivity _connectivity = Connectivity();
  RxList<ConnectivityResult> networkStatus = [ConnectivityResult.none].obs;

  AppInitController() {
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
