import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NetworkManager extends GetxController {
  RxBool isTestUrl = false.obs;
  void toggle() => isTestUrl.toggle();

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
