import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class LoginState {
  var isReLogin = false;

  // 添加计时相关变量
  late Stopwatch stopwatch;
  int longPressCount = 0;
  bool isCounting = false;

  void faceLogin({
    required String phone,
    required Function(String s) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'face_login_getting_photo_path'.tr,
      method: webApiGetUserPhoto,
      params: {'Phone': phone},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data.toString());
      } else {
        error.call(response.message ?? 'face_login_get_photo_path_failed'.tr);
      }
    });
  }

  void getVerificationCode({
    required String phone,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'phone_login_getting_verify_code'.tr,
      method: webApiVerificationCode,
      params: {'phone': phone},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? 'phone_login_get_verify_code_failed'.tr);
      }
    });
  }



  void login({
    required String jiGuangID,
    required String phone,
    required String password,
    required String vCode,
    required int type,
    required Function(dynamic userInfo) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'logging'.tr,
      method: webApiLogin,
      params: {
        'JiGuangID': jiGuangID,
        'Phone': phone,
        'Password': password,
        'VCode': vCode,
        'Type': type,
      },
    ).then((response) {
      reLoginDialogIsShowing = false;
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? 'login_failed'.tr);
      }
    });
  }
}
