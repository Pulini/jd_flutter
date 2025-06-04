import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/user_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class LoginState {
  var buttonName = 'get_verify_code'.tr.obs;
  var countTimer = 0;
  var isReLogin = false;
  // 添加计时相关变量
  late Stopwatch stopwatch;
  int longPressCount = 0;
  bool isCounting = false;

  faceLogin({
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

  getVerificationCode({
    required String phone,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'phone_login_getting_verify_code'.tr,
      method: webApiVerificationCode,
      params: {'phone': phone},
    ).then((verifyCodeCallback) {
      if (verifyCodeCallback.resultCode == resultSuccess) {
        success.call();
        //开始倒计时
        Timer.periodic(
          const Duration(milliseconds: 1000),
              (timer) {
            countTimer++;
            if (countTimer == 60) {
              timer.cancel();
              countTimer = 0;
              buttonName.value = 'get_verify_code'.tr;
            } else {
             buttonName.value = (60 - countTimer).toString();
            }
          },
        );
      } else {
        error.call(verifyCodeCallback.message ?? 'phone_login_get_verify_code_failed'.tr);
      }
    });
  }

  login({
    required String jiGuangID,
    required String phone,
    required String password,
    required String vCode,
    required int type,
    required Function(UserInfo userInfo) success,
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
      reLoginDialogIsShowing=false;
      if (response.resultCode == resultSuccess) {
        spSave(spSaveUserInfo, jsonEncode(response.data).toString());
        userInfo = UserInfo.fromJson(response.data);
        success.call(userInfo!);
      } else {
        error.call(response.message ?? 'login_failed'.tr);
      }
    });
  }
}
