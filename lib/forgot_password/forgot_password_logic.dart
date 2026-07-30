import 'package:get/get.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'forgot_password_state.dart';

class ForgotPasswordLogic extends GetxController {
  final ForgotPasswordState state = ForgotPasswordState();

  //获取验证码
  void sendResetCode({required String account, required Function() success}) {
    if(account.isEmpty){
      errorDialog(content: 'forgot_password_account_tips'.tr);
      return;
    }
    state.sendResetCode(
      account: account,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void resetPassword({
    required String account,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) {
    if(account.isEmpty){
      errorDialog(content: 'forgot_password_account_tips'.tr);
      return;
    }
    if(code.isEmpty){
      errorDialog(content: 'login_tips_verify_code'.tr);
      return;
    }
    if(newPassword.isEmpty){
      errorDialog(content: 'forgot_password_new_password_tips'.tr);
      return;
    }
    if(confirmPassword.isEmpty){
      errorDialog(content: 'forgot_password_confirm_password_tips'.tr);
      return;
    }
    if(newPassword != confirmPassword){
      errorDialog(content: 'forgot_password_password_mismatch'.tr);
      return;
    }
    state.resetPassword(
      account: account,
      code: code,
      newPassword: newPassword,
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
