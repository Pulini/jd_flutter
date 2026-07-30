import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ForgotPasswordState {
  void sendResetCode({
    required String account,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'phone_login_getting_verify_code'.tr,
      method: webApiSendResetCode,
      params: {'phone': account},
    ).then((verifyCodeCallback) {
      if (verifyCodeCallback.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(verifyCodeCallback.message ??
            'phone_login_get_verify_code_failed'.tr);
      }
    });
  }

  void resetPassword({
    required String account,
    required String code,
    required String newPassword,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'forgot_password_submitting'.tr,
      method: webApiResetPassword,
      params: {
        'phone': account,
        'code': code,
        'newPassword': newPassword,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message??'');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
