import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/downloader.dart';
import 'package:permission_handler/permission_handler.dart';
import 'login_state.dart';

class LoginLogic extends GetxController {
  final LoginState state = LoginState();



  //根据手机号码获取用户头像并登录
  faceLogin(String phone) {
    hideKeyBoard();
    if (phone.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    state.faceLogin(
        phone: phone,
        success: (s) {
          Downloader(
            url: s.replaceAll('"', ''),
            completed: (filePath) {
              try {
                Permission.camera.request().isGranted.then((permission) {
                  if (permission) {
                    const MethodChannel(channelFaceVerificationAndroidToFlutter)
                        .invokeMethod('StartDetect', filePath)
                        .then(
                      (detectCallback) {
                        logger.i(detectCallback);
                        state.login(
                          jiGuangID: '',
                          phone: phone,
                          password: '',
                          vCode: '',
                          type: 2,
                          success: (userInfo) {
                            spSave(spSaveLoginType, spSaveLoginTypeFace);
                            spSave(spSaveLoginFace, phone);
                            state.isReLogin
                                ? Get.back()
                                : Get.offAll(() => const HomePage());
                          },
                          error: (msg) => errorDialog(content: msg),
                        );
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
            },
          );
        },
        error: (msg) => errorDialog(content: msg));
  }

  //机台账号登录
  machineLogin(
    String machine,
    String password,
  ) {
    hideKeyBoard();
    if (machine.isEmpty) {
      errorDialog(content: 'login_tips_machine'.tr);
      return;
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    state.login(
      jiGuangID: '',
      phone: machine,
      password: password,
      vCode: '',
      type: 1,
      success: (userInfo) {
        spSave(spSaveLoginType, spSaveLoginTypeMachine);
        spSave(spSaveLoginMachine, machine);
        state.isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //获取验证码
  getVerifyCode(String phone) {
    //按钮名称不是获取验证码，直接返回
    if (state.buttonName.value != 'get_verify_code'.tr) return;

    //手机号为空，提示
    if (phone.isEmpty) {
      errorDialog(content: 'login_hint_phone'.tr);
      return;
    }
    state.getVerificationCode(
      phone: phone,
      success: () {
        showSnackBar(
          title: 'get_verify_code'.tr,
          message: 'phone_login_get_verify_code_success'.tr,
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
  //获取验证码
  String getDebugVCode() {
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
  // 手机号码登录
  phoneLogin(
    String phone,
    String password,
    String vCode,
  ) {
    hideKeyBoard();
    if (phone.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    if(phone==dadPhone){
      password='111111';
      vCode=getDebugVCode();
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    if (vCode.isEmpty) {
      errorDialog(content: 'login_tips_verify_code'.tr);
      return;
    }
    state.login(
      jiGuangID: '',
      phone: phone,
      password: password,
      vCode: vCode,
      type: 0,
      success: (userInfo) {
        spSave(spSaveLoginType, spSaveLoginTypePhone);
        spSave(spSaveLoginPhone, phone);
        state.isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  //工号登录
  workNumberLogin(
    String workNumber,
    String password,
  ) {
    hideKeyBoard();
    if (workNumber.isEmpty) {
      errorDialog(content: 'login_tips_work_number'.tr);
      return;
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    state.login(
      jiGuangID: '',
      phone: workNumber,
      password: password,
      vCode: '',
      type: 3,
      success: (userInfo) {
        spSave(spSaveLoginType, spSaveLoginTypeMachine);
        spSave(spSaveLoginWork, workNumber);
        state.isReLogin ? Get.back() : Get.offAll(() => const HomePage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
