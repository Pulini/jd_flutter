import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/user_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();

  @override
  void onInit() {
    super.onInit();
    state.stopwatch = Stopwatch();
  }

  @override
  onClose() {
    state.stopwatch.stop();
    super.onClose();
  }

  // 长按开始计时,5秒内长按3次为成功
  void handleLongPressStart({required Function() changeBaseUrl}) {
    if (!state.isCounting) {
      state.isCounting = true;
      state.longPressCount = 1;
      state.stopwatch
        ..reset()
        ..start();
    } else {
      state.longPressCount++;
      if (state.longPressCount >= 3) {
        state.stopwatch.stop();
        if (state.stopwatch.elapsed.inSeconds <= 5) {
          changeBaseUrl.call();
        }
        state.isCounting = false;
        state.longPressCount = 0;
      }
    }
  }

  void loginSuccess({
    required String loginType,
    required String account,
  }) {
    spSave(spSaveUserInfo, jsonEncode(userInfo!.toJson()).toString());
    spSave(spSaveLoginType, loginType);
    switch (loginType) {
      case spSaveLoginTypePhone:
        spSave(spSaveLoginPhone, account);
        break;
      case spSaveLoginTypeFace:
        spSave(spSaveLoginFace, account);
        break;
      case spSaveLoginTypeWorkNumber:
        spSave(spSaveLoginWork, account);
        break;
      case spSaveLoginTypeMachine:
        spSave(spSaveLoginMachine, account);
        break;
      case spSaveLoginTypeFeiShu:
        //飞书授权登录无需记录账号
        break;
    }
    state.isReLogin ? Get.back() : Get.offAll(() => const HomePage());
  }

  //根据手机号码获取用户头像并登录
  void faceLogin(String phone) {
    state.faceLogin(
        phone: phone,
        success: (s) {
          livenFaceVerification(
            faceUrl: s.replaceAll('"', ''),
            verifySuccess: (base64) => state.login(
              jiGuangID: getJPushID(),
              phone: phone,
              password: '',
              vCode: '',
              type: 2,
              success: (data) {
                userInfo = UserInfo.fromJson(data);
                if (userInfo!.mustChangePassword == 1) {
                  changePasswordDialog(
                    account: phone,
                    oldPassword: '',
                    success: (password) {
                      userInfo!.empPassWord = password;
                      userInfo!.passWord = password.md5Encode().toUpperCase();
                      loginSuccess(
                        loginType: spSaveLoginTypeFace,
                        account: phone,
                      );
                    },
                  );
                } else {
                  loginSuccess(
                    loginType: spSaveLoginTypeFace,
                    account: phone,
                  );
                }
              },
              error: (msg) => errorDialog(content: msg),
            ),
          );
        },
        error: (msg) => errorDialog(content: msg));
  }

  //机台账号登录
  void machineLogin(
    String machine,
    String password,
  ) {
    state.login(
      jiGuangID: getJPushID(),
      phone: machine,
      password: password,
      vCode: '',
      type: 1,
      success: (data) {
        userInfo = UserInfo.fromJson(data);
        if (userInfo!.mustChangePassword == 1) {
          changePasswordDialog(
            account: machine,
            oldPassword: password,
            success: (password) {
              userInfo!.empPassWord = password;
              userInfo!.passWord = password.md5Encode().toUpperCase();
              loginSuccess(
                loginType: spSaveLoginTypeMachine,
                account: machine,
              );
            },
          );
        } else {
          loginSuccess(
            loginType: spSaveLoginTypeMachine,
            account: machine,
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //获取验证码
 void getVerifyCode({required String phone, required Function() success}) async {
    state.getVerificationCode(
      phone: phone,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }



  // 手机号码登录
  void phoneLogin(
    String phone,
    String password,
    String vCode,
  ) {
    state.login(
      jiGuangID: getJPushID(),
      phone: phone,
      password: password,
      vCode: vCode,
      type: 0,
      success: (data) {
        userInfo = UserInfo.fromJson(data);
        if (userInfo!.mustChangePassword == 1) {
          changePasswordDialog(
            account: phone,
            oldPassword: password,
            success: (password) {
              userInfo!.empPassWord = password;
              userInfo!.passWord = password.md5Encode().toUpperCase();
              loginSuccess(
                loginType: spSaveLoginTypePhone,
                account: phone,
              );
            },
          );
        } else {
          loginSuccess(
            loginType: spSaveLoginTypePhone,
            account: phone,
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //工号登录
  void workNumberLogin(
    String workNumber,
    String password,
  ) {
    state.login(
      jiGuangID: getJPushID(),
      phone: workNumber,
      password: password,
      vCode: '',
      type: 3,
      success: (data) {
        userInfo = UserInfo.fromJson(data);
        if (userInfo!.mustChangePassword == 1) {
          changePasswordDialog(
            account: workNumber,
            oldPassword: password,
            success: (password) {
              userInfo!.empPassWord = password;
              userInfo!.passWord = password.md5Encode().toUpperCase();
              loginSuccess(
                loginType: spSaveLoginTypeWorkNumber,
                account: workNumber,
              );
            },
          );
        } else {
          loginSuccess(
            loginType: spSaveLoginTypeWorkNumber,
            account: workNumber,
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void larkLogin(String userId) {
    state.login(
      jiGuangID: getJPushID(),
      phone: userId,
      password: '',
      vCode: '',
      type: 4,
      success: (data) {
        userInfo = UserInfo.fromJson(data);
        if (userInfo!.mustChangePassword == 1) {
          changePasswordDialog(
            account: userInfo?.number ?? '',
            oldPassword: '',
            success: (password) {
              userInfo!.empPassWord = password;
              userInfo!.passWord = password.md5Encode().toUpperCase();
              loginSuccess(
                loginType: spSaveLoginTypeFeiShu,
                account: '',
              );
            },
          );
        } else {
          loginSuccess(
            loginType: spSaveLoginTypeFeiShu,
            account: '',
          );
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
