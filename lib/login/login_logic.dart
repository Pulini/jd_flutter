import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../constant.dart';
import '../home/home_view.dart';
import '../http/response/user_info.dart';
import '../http/web_api.dart';
import '../utils.dart';
import '../widget/dialogs.dart';
import '../widget/downloader.dart';
import 'login_state.dart';

///获取验证码
String _getVCode() {
  var date = DateTime.now();
  var now = '${date.year.toString().substring(2, 4)}'
      '${date.month.toString().padLeft(2, '0')}'
      '${date.day.toString().padLeft(2, '0')}';
  var vCode = '';
  for (var i = now.length; i > 0; i--) {
    vCode += now.substring(i - 1, i);
  }
  return vCode;
}

class LoginLogic extends GetxController with GetSingleTickerProviderStateMixin {
  final LoginState state = LoginState();
  var _isReLogin = false;

  ///tab控制器
  late TabController tabController =
      TabController(length: GetPlatform.isAndroid ? 4 : 3, vsync: this);

  ///人脸登录手机号输入框控制器
  TextEditingController faceLoginPhoneController = TextEditingController()
    ..text = spGet(spSaveLoginFace) ?? '';

  ///机台登录机台号输入框控制器
  TextEditingController machineLoginMachineController = TextEditingController()
    ..text = spGet(spSaveLoginMachine) ?? '';

  ///机台登录密码输入框控制器
  TextEditingController machineLoginPasswordController =
      TextEditingController();

  ///手机登录手机号输入框控制器
  TextEditingController phoneLoginPhoneController = TextEditingController()
    // ..text = spGet(spSaveLoginPhone) ?? '15868587600';
    ..text = spGet(spSaveLoginPhone) ?? '';

  ///手机登录密码输入框控制器
  TextEditingController phoneLoginPasswordController = TextEditingController();

  // ..text = '123456';

  ///手机登录验证码输入框控制器
  TextEditingController phoneLoginVCodeController = TextEditingController();

  // ..text = _getVCode();

  ///工号登录工号输入框控制器
  TextEditingController workLoginWorkNumberController = TextEditingController()
    ..text = spGet(spSaveLoginWork) ?? '';

  ///工号登录密码输入框控制器
  TextEditingController workLoginPasswordController = TextEditingController();

  reLogin() {
    _isReLogin = true;
    _login();
  }

  login() {
    _isReLogin = false;
    _login();
  }

  _login() {
    if (tabController.index == 0) {
      phoneLogin();
      return;
    }
    if (tabController.index == 1) {
      if (GetPlatform.isAndroid) {
        faceLogin();
      } else {
        machineLogin();
      }
      return;
    }
    if (tabController.index == 2) {
      if (GetPlatform.isAndroid) {
        machineLogin();
      } else {
        workNumberLogin();
      }
      return;
    }

    if (tabController.index == 3) {
      workNumberLogin();
      return;
    }
  }

  ///根据手机号码获取用户头像并登录
  faceLogin() {
    hideKeyBoard();
    if (faceLoginPhoneController.text.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    httpGet(
      loading: 'face_login_getting_photo_path'.tr,
      method: webApiGetUserPhoto,
      query: {'Phone': faceLoginPhoneController.text},
    ).then((val) {
      if (val.resultCode == resultSuccess) {
        Downloader(
            url: val.data.toString().replaceAll('\'', ''),
            completed: (filePath) {
              try {
                Permission.camera.request().isGranted.then((permission) {
                  if (permission) {
                    const MethodChannel(channelFlutterSend)
                        .invokeMethod('StartDetect', filePath)
                        .then(
                      (detectCallback) {
                        logger.i(detectCallback);
                        httpPost(
                          loading: 'logging'.tr,
                          method: webApiLogin,
                          query: {
                            'JiGuangID': '',
                            'Phone': faceLoginPhoneController.text,
                            'Password': '',
                            'VCode': '',
                            'Type': 2,
                          },
                        ).then((loginCallback) {
                          if (loginCallback.resultCode == resultSuccess) {
                            spSave(spSaveLoginType, loginTypeFace);
                            spSave(
                                spSaveLoginFace, faceLoginPhoneController.text);
                            spSave(
                                spSaveUserInfo, loginCallback.data.toString());
                            userInfo = UserInfo.fromJson(
                                jsonDecode(loginCallback.data));
                            Get.delete<LoginLogic>();
                            _isReLogin
                                ? Get.back()
                                : Get.offAll(() => const HomePage());
                          } else {
                            errorDialog(
                                content:
                                    loginCallback.message ?? 'login_failed'.tr);
                          }
                        });
                      },
                    ).catchError((e) {
                      logger.i(e);
                    });
                  } else {
                    errorDialog(content: 'face_login_no_camera_permission'.tr);
                  }
                });
              } on PlatformException {
                errorDialog(content: 'face_login_failed'.tr);
              }
            });
      } else {
        errorDialog(
            content: val.message ?? 'face_login_get_photo_path_failed'.tr);
      }
    });
  }

  ///机台账号登录
  machineLogin() {
    hideKeyBoard();
    if (machineLoginMachineController.text.isEmpty) {
      errorDialog(content: 'login_tips_machine'.tr);
      return;
    }
    if (machineLoginPasswordController.text.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    httpPost(
      loading: 'logging'.tr,
      method: webApiLogin,
      query: {
        'JiGuangID': '',
        'Phone': machineLoginMachineController.text,
        'Password': machineLoginPasswordController.text,
        'VCode': '',
        'Type': 1,
      },
    ).then((loginCallback) {
      if (loginCallback.resultCode == resultSuccess) {
        spSave(spSaveLoginType, loginTypeMachine);
        spSave(spSaveLoginMachine, machineLoginMachineController.text);
        spSave(spSaveUserInfo, loginCallback.data.toString());
        userInfo=UserInfo.fromJson(jsonDecode(loginCallback.data));
        Get.delete<LoginLogic>();
        _isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      } else {
        errorDialog(content: loginCallback.message ?? 'login_failed'.tr);
      }
    });
  }

  ///获取验证码
  getVerifyCode() {
    //按钮名称不是获取验证码，直接返回
    if (state.buttonName.value != 'get_verify_code'.tr) return;

    //手机号为空，提示
    if (phoneLoginPhoneController.text.isEmpty) {
      errorDialog(content: 'login_hint_phone'.tr);
      return;
    }
    httpPost(
      loading: 'phone_login_getting_verify_code'.tr,
      method: webApiVerificationCode,
      query: {'phone': phoneLoginPhoneController.text},
    ).then((verifyCodeCallback) {
      if (verifyCodeCallback.resultCode == resultSuccess) {
        showSnackBar(
          title: 'get_verify_code'.tr,
          message: 'phone_login_get_verify_code_success'.tr,
        );
        //开始倒计时
        Timer.periodic(
          const Duration(milliseconds: 1000),
          (timer) {
            state.countTimer++;
            if (state.countTimer == 60) {
              timer.cancel();
              state.countTimer = 0;
              state.buttonName.value = 'get_verify_code'.tr;
            } else {
              state.buttonName.value = (60 - state.countTimer).toString();
            }
            update();
          },
        );
      } else {
        errorDialog(
            content: verifyCodeCallback.message ??
                'phone_login_get_verify_code_failed'.tr);
      }
    });
  }

  /// 手机号码登录
  phoneLogin() {
    hideKeyBoard();
    if (phoneLoginPhoneController.text.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    if (phoneLoginPasswordController.text.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    if (phoneLoginVCodeController.text.isEmpty) {
      errorDialog(content: 'login_tips_verify_code'.tr);
      return;
    }
    httpPost(
      loading: 'logging'.tr,
      method: webApiLogin,
      query: {
        'JiGuangID': '',
        'Phone': phoneLoginPhoneController.text,
        'Password': phoneLoginPasswordController.text,
        'VCode': phoneLoginVCodeController.text,
        'Type': 0,
      },
    ).then((loginCallback) {
      if (loginCallback.resultCode == resultSuccess) {
        spSave(spSaveLoginType, loginTypePhone);
        spSave(spSaveLoginPhone, phoneLoginPhoneController.text);
        spSave(spSaveUserInfo, loginCallback.data.toString());
        userInfo=UserInfo.fromJson(jsonDecode(loginCallback.data));
        Get.delete<LoginLogic>();
        _isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      } else {
        errorDialog(content: loginCallback.message ?? 'login_failed'.tr);
      }
    });
  }

  ///工号登录
  workNumberLogin() {
    hideKeyBoard();
    if (workLoginWorkNumberController.text.isEmpty) {
      errorDialog(content: 'login_tips_work_number'.tr);
      return;
    }
    if (workLoginPasswordController.text.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }

    httpPost(
      loading: 'logging'.tr,
      method: webApiLogin,
      query: {
        'JiGuangID': '',
        'Phone': workLoginWorkNumberController.text,
        'Password': workLoginPasswordController.text,
        'VCode': '',
        'Type': 3,
      },
    ).then((loginCallback) {
      if (loginCallback.resultCode == resultSuccess) {
        spSave(spSaveLoginType, loginTypeMachine);
        spSave(spSaveLoginWork, workLoginWorkNumberController.text);
        spSave(spSaveUserInfo, loginCallback.data.toString());
        userInfo=UserInfo.fromJson(jsonDecode(loginCallback.data));
        Get.delete<LoginLogic>();
        _isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      } else {
        errorDialog(content: loginCallback.message ?? 'login_failed'.tr);
      }
    });
  }
}
