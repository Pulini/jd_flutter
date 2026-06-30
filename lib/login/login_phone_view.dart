import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/field.dart';

class PhoneLoginWidget extends StatefulWidget {
  final Function(String phone, String password, String vCode) login;
  final Function(String phone) getVCode;
  final Function() longClick;

  const PhoneLoginWidget({
    super.key,
    required this.login,
    required this.longClick,
    required this.getVCode,
  });

  @override
  State<PhoneLoginWidget> createState() => _PhoneLoginWidgetState();
}

class _PhoneLoginWidgetState extends State<PhoneLoginWidget> {
  final phoneController =
      TextEditingController(text: spGet(spSaveLoginPhone) ?? '');
  final passwordController = TextEditingController();
  final codeController = TextEditingController();
  var obscurePassword = true.obs;
  var vCodeCountdown = 0.obs;

  void startCountdown() {
    if (vCodeCountdown.value > 0) return;
    vCodeCountdown.value = 60;
    widget.getVCode.call(phoneController.text);
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      vCodeCountdown.value--;
      return vCodeCountdown.value > 0;
    });
  }

  void _login() {
    var phone = phoneController.text;
    var password = passwordController.text;
    var vCode = codeController.text;
    hideKeyBoard();
    if (phone.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    if (isTestUrl()) {
      //测试库无需验证码
      vCode = getDebugVCode();
      String dadPwd = dadPhone[phone] ?? '';
      if (dadPwd.isNotEmpty && password.isEmpty) {
        //程序员专用通道
        password = dadPwd;
      }
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    if (vCode.isEmpty) {
      errorDialog(content: 'login_tips_verify_code'.tr);
      return;
    }
    widget.login.call(phone, password, vCode);
  }

  @override
  Widget build(BuildContext context) => Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: isTestUrl() ? Colors.teal : Colors.blueAccent,
            ),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                LoginField(
                  controller: phoneController,
                  hint: 'login_hint_phone'.tr,
                  prefixIcon: Icons.phone_android,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                Obx(() => LoginField(
                      controller: passwordController,
                      hint: 'login_hint_password'.tr,
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
                        onPressed: () =>
                            obscurePassword.value = !obscurePassword.value,
                      ),
                    )),
                const SizedBox(height: 16),
                LoginField(
                  controller: codeController,
                  hint: 'login_hint_verify_code'.tr,
                  prefixIcon: Icons.sms_outlined,
                  keyboardType: TextInputType.number,
                  suffix: SizedBox(
                    height: 32,
                    child: TextButton(
                      onPressed:
                          vCodeCountdown.value == 0 ? startCountdown : null,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: CombinationButton(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blueAccent,
                    text: 'login'.tr,
                    click: () => _login(),
                    longClick: () => widget.longClick.call(),
                  ),
                )
              ],
            ),
          )
        ],
      );

  @override
  void dispose() {
    phoneController.dispose();
    passwordController.dispose();
    codeController.dispose();
    super.dispose();
  }
}
