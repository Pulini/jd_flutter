import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/user_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/dio_manager.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../bean/http/response/feishu_info.dart';
import '../widget/feishu_authorize.dart';

class LoginState {
  var countTimer = 0.obs;
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
    ).then((verifyCodeCallback) {
      if (verifyCodeCallback.resultCode == resultSuccess) {
        success.call();
        //开始倒计时
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
          countTimer.value++;
          if (countTimer.value == 60) {
            timer.cancel();
            countTimer.value = 0;
          }
        });
      } else {
        error.call(verifyCodeCallback.message ??
            'phone_login_get_verify_code_failed'.tr);
      }
    });
  }

  void login({
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
      reLoginDialogIsShowing = false;
      if (response.resultCode == resultSuccess) {
        spSave(spSaveUserInfo, jsonEncode(response.data).toString());
        userInfo = UserInfo.fromJson(response.data);
        success.call(userInfo!);
      } else {
        error.call(response.message ?? 'login_failed'.tr);
      }
    });
  }

  void getFeishuUserAccessToken({
    required String code,
    required Function(String accessToken) success,
    required Function(String msg) error,
  }) {
    loadingShow('正在获取用户Token...');
    Dio()
      ..interceptors.add(DioManager.simpleInterceptors)
      ..post(
        getUserTokenUrl,
        data: {
          'grant_type': 'authorization_code',
          'client_id': appID,
          'client_secret': appSecret,
          'code': code,
          'redirect_uri': redirectUri,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      ).then(
        (response) {
          loadingDismiss();
          var feishu = FeishuUserTokenInfo.fromJson(response.data);
          if (feishu.code == 0) {
            success.call(feishu.accessToken ?? '');
          } else {
            error.call('获取token失败：${feishu.code}');
          }
        },
        onError: (e) {
          loadingDismiss();
          error.call(
              '获取token失败：${(e as DioException).response?.statusCode} ${e.response?.statusMessage}');
        },
      );
  }

  void getFeishuUserInfo({
    required String token,
    required Function(FeishuUserInfo userInfo) success,
    required Function(String msg) error,
  }) {
    loadingShow('正在获取用户信息...');
    Dio()
      ..interceptors.add(DioManager.simpleInterceptors)
      ..get(
        getUserInfoUrl,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json; charset=utf-8',
          },
        ),
      ).then(
        (response) {
          loadingDismiss();
          var code=response.data['code'];
          if (code == 0) {
            success.call(FeishuUserInfo.fromJson(response.data['data']));
          } else {
            error.call('获取用户信息失败：$code');
          }
        },
        onError: (e) {
          loadingDismiss();
          error.call(
              '获取用户信息失败：${(e as DioException).response?.statusCode} ${e.response?.statusMessage}');
        },
      );
  }
}
