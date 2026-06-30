import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/field.dart';

class FaceLoginWidget extends StatefulWidget {
  final Function(String phone) login;
  final Function() longClick;

  const FaceLoginWidget({
    super.key,
    required this.login,
    required this.longClick,
  });

  @override
  State<FaceLoginWidget> createState() => _FaceLoginWidgetState();
}

class _FaceLoginWidgetState extends State<FaceLoginWidget> {
  final phoneController =
      TextEditingController(text: spGet(spSaveLoginFace) ?? '');

  void _login() {
    hideKeyBoard();
    String phone = phoneController.text;
    if (phone.isEmpty) {
      errorDialog(content: 'login_tips_phone'.tr);
      return;
    }
    widget.login.call(phone);
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
    super.dispose();
  }
}
