import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/home/home_view.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
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
  handleLongPressStart() {
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
          toggleTestUrl();
          Get.offAll(() => const LoginPage());
        }
        state.isCounting = false;
        state.longPressCount = 0;
      }
    }
  }

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
          livenFaceVerification(
            faceUrl: s.replaceAll('"', ''),
            verifySuccess: (base64) => state.login(
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
            ),
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
      jiGuangID: 'JID_Empty',
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
    if (state.countTimer.value > 0) return;

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
    if (isTestUrl()) {
      //测试库无需验证码
      vCode = getDebugVCode();
    }
    String dadPwd = dadPhone[phone] ?? '';
    if (dadPwd.isNotEmpty && password.isEmpty) {
      //程序员专用通道
      password = dadPwd;
      vCode = getDebugVCode();
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
