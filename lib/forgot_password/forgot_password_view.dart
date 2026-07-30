import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/field.dart';

import 'forgot_password_logic.dart';
import 'forgot_password_state.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final ForgotPasswordLogic logic = Get.put(ForgotPasswordLogic());
  final ForgotPasswordState state = Get.find<ForgotPasswordLogic>().state;
  final accountController = TextEditingController();
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var vCodeCountdown = 0.obs;
  var obscurePassword = true.obs;


  void startCountdown() {
    if (vCodeCountdown.value > 0) return;
    logic.sendResetCode(
      account: accountController.text,
      success: () {
        showSnackBar(
          title: 'get_verify_code'.tr,
          message: 'phone_login_get_verify_code_success'.tr,
        );
        vCodeCountdown.value = 60;
        Future.doWhile(() async {
          await Future.delayed(const Duration(seconds: 1));
          if (!mounted) return false;
          vCodeCountdown.value--;
          return vCodeCountdown.value > 0;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTestUrl()
              ? [Colors.lightBlueAccent, Colors.greenAccent]
              : [Colors.lightBlueAccent, Colors.blueAccent],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text('forgot_password_title'.tr),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 30, right: 30),
          child: Column(
            children: [
              const Spacer(),
              Text('change_password_dialog_tips'.tr),
              const Spacer(),
              Card(
                color: Colors.blueAccent,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LoginField(
                        controller: accountController,
                        hint: 'forgot_password_account_tips'.tr,
                        prefixIcon: Icons.account_circle,
                      ),
                      LoginField(
                        controller: codeController,
                        hint: 'login_hint_verify_code'.tr,
                        prefixIcon: Icons.sms_outlined,
                        suffix: SizedBox(
                          height: 32,
                          child: TextButton(
                            onPressed: vCodeCountdown.value == 0
                                ? startCountdown
                                : null,
                            style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              minimumSize: Size.zero,
                            ),
                            child: Obx(() => Text(
                                  vCodeCountdown.value == 0
                                      ? 'get_verify_code'.tr
                                      : '${vCodeCountdown.value}s',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: vCodeCountdown.value == 0
                                        ? Colors.white
                                        : Colors.grey.shade400,
                                  ),
                                )),
                          ),
                        ),
                      ),
                      Obx(() => LoginField(
                            controller: passwordController,
                            hint: 'forgot_password_new_password_tips'.tr,
                            prefixIcon: Icons.lock_outline,
                            obscureText: obscurePassword.value,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () => obscurePassword.value =
                                  !obscurePassword.value,
                            ),
                          )),
                      Obx(() => LoginField(
                            controller: confirmPasswordController,
                            hint: 'forgot_password_confirm_password_tips'.tr,
                            prefixIcon: Icons.lock_outline,
                            obscureText: obscurePassword.value,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                size: 20,
                                color: Colors.white,
                              ),
                              onPressed: () => obscurePassword.value =
                                  !obscurePassword.value,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child:CombinationButton(
                  backgroundColor: Colors.blueAccent,
                  text: 'forgot_password_reset_password'.tr,
                  click: () =>logic.resetPassword(
                    account: accountController.text,
                    code: codeController.text,
                    newPassword: passwordController.text,
                    confirmPassword: confirmPasswordController.text,
                  ),
                ),
              ),
              const Spacer(
                flex: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    accountController.dispose();
    codeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    Get.delete<ForgotPasswordLogic>();
    super.dispose();
  }
}
