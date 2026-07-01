import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/field.dart';

class WorkLoginWidget extends StatefulWidget {
  final Function(String workNumber, String password) login;
  final Function() longClick;

  const WorkLoginWidget({
    super.key,
    required this.login,
    required this.longClick,
  });

  @override
  State<WorkLoginWidget> createState() => _WorkLoginWidgetState();
}

class _WorkLoginWidgetState extends State<WorkLoginWidget> {
  var workNumberController = TextEditingController(text: spGet(spSaveLoginWork) ?? '');
  var passwordController = TextEditingController();
  var obscurePassword = true.obs;

  void _login() {
    hideKeyBoard();
    var workNumber = workNumberController.text;
    var password = passwordController.text;
    if (workNumber.isEmpty) {
      errorDialog(content: 'login_tips_work_number'.tr);
      return;
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    widget.login.call(workNumber, password);
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
                  controller: workNumberController,
                  hint: 'login_hint_work_number'.tr,
                  prefixIcon: Icons.badge_outlined,
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
    workNumberController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
