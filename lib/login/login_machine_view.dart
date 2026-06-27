import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/field.dart';

class MachineLoginWidget extends StatefulWidget {
  final Function(String machine, String password) login;
  final Function() longClick;

  const MachineLoginWidget({
    super.key,
    required this.login,
    required this.longClick,
  });

  @override
  State<MachineLoginWidget> createState() => _MachineLoginWidgetState();
}

class _MachineLoginWidgetState extends State<MachineLoginWidget> {
  final machineController = TextEditingController(text:  spGet(spSaveLoginMachine) ?? '');
  final passwordController = TextEditingController();
  var obscurePassword = true.obs;

  void _login() {
    hideKeyBoard();
    var machine = machineController.text;
    var password = passwordController.text;
    if (machine.isEmpty) {
      errorDialog(content: 'login_tips_machine'.tr);
      return;
    }
    if (password.isEmpty) {
      errorDialog(content: 'login_tips_password'.tr);
      return;
    }
    widget.login.call(machine, password);
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
                  controller: machineController,
                  hint: 'login_hint_machine'.tr,
                  prefixIcon: Icons.precision_manufacturing,
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
    machineController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
