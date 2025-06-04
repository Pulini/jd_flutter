import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

class NetworkManager extends GetxController {
  RxBool isTestUrl = false.obs;

  @override
  onInit() {
    super.onInit();
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

  NetworkManager() {
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
