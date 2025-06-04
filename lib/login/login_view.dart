import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/network_manager.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/number_text_field_widget.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          alignment: Alignment.center,
          //设置背景
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: Get.find<NetworkManager>().isTestUrl.value
                  ? [Colors.lightBlueAccent, Colors.greenAccent]
                  : [Colors.lightBlueAccent, Colors.blueAccent],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: ListView(
            //添加登录UI
            children: [
              const SizedBox(height: 30),
              Image.asset(
                'assets/images/ic_logo.png',
                width: 130,
                height: 130,
              ),
              const Center(
                  child: Text(
                'Gold Emperor',
                style: TextStyle(
                  fontSize: 40,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              )),
              const Center(child: LoginPick(isReLogin: false)),
              const SizedBox(height: 40),
            ],
          ),
        ));
  }
}

class LoginPick extends StatefulWidget {
  const LoginPick({super.key, required this.isReLogin});

  final bool isReLogin;

  @override
  State<LoginPick> createState() => _LoginPickState();
}

class _LoginPickState extends State<LoginPick>
    with SingleTickerProviderStateMixin {
  var logic = Get.put(LoginLogic());
  var state = Get.find<LoginLogic>().state;

  //tab控制器
  late var tabController = TabController(
    length: GetPlatform.isAndroid ? 4 : 3,
    vsync: this,
  );

  //人脸登录手机号输入框控制器
  var faceLoginPhoneController = TextEditingController()
    ..text = spGet(spSaveLoginFace) ?? '';

  //机台登录机台号输入框控制器
  var machineLoginMachineController = TextEditingController()
    ..text = spGet(spSaveLoginMachine) ?? '';

  //机台登录密码输入框控制器
  var machineLoginPasswordController = TextEditingController();

  //手机登录手机号输入框控制器
  late var phoneLoginPhoneController = TextEditingController()
    ..text = Get.find<NetworkManager>().isTestUrl.value
        ? dadPhone
        : spGet(spSaveLoginPhone) ?? '';

  //手机登录密码输入框控制器
  var phoneLoginPasswordController = TextEditingController();

  //手机登录验证码输入框控制器
  var phoneLoginVCodeController = TextEditingController();

  //工号登录工号输入框控制器
  var workLoginWorkNumberController = TextEditingController()
    ..text = spGet(spSaveLoginWork) ?? '';

  //工号登录密码输入框控制器
  var workLoginPasswordController = TextEditingController();

  textField({
    required TextEditingController controller,
    required String hint,
    required Icon leftIcon,
    required int maxLength,
    bool isPassword = false,
  }) =>
      TextField(
        obscureText: isPassword,
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white),
          counterStyle: const TextStyle(color: Colors.white),
          prefixIcon: leftIcon,
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              controller.clear();
            },
          ),
        ),
        maxLength: maxLength,
      );

  _box(Widget child) => Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Get.find<NetworkManager>().isTestUrl.value
                  ? Colors.teal
                  : Colors.blueAccent,
            ),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(20),
            child: child,
          )
        ],
      );

  _phoneLogin() => _box(
        Column(
          children: [
            textField(
              controller: phoneLoginPhoneController,
              hint: 'login_hint_phone'.tr,
              leftIcon: const Icon(Icons.phone, color: Colors.white),
              maxLength: 11,
            ),
            textField(
              controller: phoneLoginPasswordController,
              hint: 'login_hint_password'.tr,
              leftIcon: const Icon(Icons.lock_outline, color: Colors.white),
              maxLength: 10,
              isPassword: true,
            ),
            if (!Get.find<NetworkManager>().isTestUrl.value)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: NumberTextField(
                      numberController: phoneLoginVCodeController,
                      maxLength: 6,
                      textStyle: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'login_hint_verify_code'.tr,
                        hintStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              state.buttonName.value == 'get_verify_code'.tr
                                  ? Colors.white
                                  : Colors.grey.shade400,
                        ),
                        onPressed: () => logic.getVerifyCode(
                          phoneLoginPhoneController.text,
                        ),
                        child: Text(
                          state.buttonName.value,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 213, 41, 42),
                          ),
                        ),
                      )),
                ],
              )
          ],
        ),
      );

  _faceLogin() => _box(
        textField(
          controller: faceLoginPhoneController,
          hint: 'login_hint_phone'.tr,
          leftIcon: const Icon(Icons.phone_android, color: Colors.white),
          maxLength: 11,
        ),
      );

  _machineLogin() => _box(
        Column(
          children: [
            textField(
              controller: machineLoginMachineController,
              hint: 'login_hint_machine'.tr,
              leftIcon: const Icon(Icons.precision_manufacturing,
                  color: Colors.white),
              maxLength: 10,
            ),
            textField(
              controller: machineLoginPasswordController,
              hint: 'login_hint_password'.tr,
              leftIcon: const Icon(Icons.lock_outline, color: Colors.white),
              maxLength: 10,
              isPassword: true,
            ),
          ],
        ),
      );

  _workLogin() => _box(
        Column(
          children: [
            textField(
              controller: workLoginWorkNumberController,
              hint: 'login_hint_work_number'.tr,
              leftIcon: const Icon(Icons.badge_outlined, color: Colors.white),
              maxLength: 6,
            ),
            textField(
              controller: workLoginPasswordController,
              hint: 'login_hint_password'.tr,
              leftIcon: const Icon(Icons.lock_outline, color: Colors.white),
              maxLength: 10,
              isPassword: true,
            ),
          ],
        ),
      );

  @override
  void initState() {
    state.isReLogin = widget.isReLogin;
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<LoginLogic>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      height: 400,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        appBar: TabBar(
          controller: tabController,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            const Tab(icon: Icon(Icons.phone)),
            if (GetPlatform.isAndroid)
              const Tab(icon: Icon(Icons.account_circle_outlined)),
            const Tab(icon: Icon(Icons.precision_manufacturing)),
            const Tab(icon: Icon(Icons.assignment_ind_outlined))
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  _phoneLogin(),
                  if (GetPlatform.isAndroid) _faceLogin(),
                  _machineLogin(),
                  _workLogin()
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onLongPress: () =>logic.handleLongPressStart(),
                onPressed: () {
                  if (tabController.index == 0) {
                    logic.phoneLogin(
                      phoneLoginPhoneController.text,
                      phoneLoginPasswordController.text,
                      phoneLoginVCodeController.text,
                    );
                    return;
                  }
                  if (tabController.index == 1) {
                    if (GetPlatform.isAndroid) {
                      logic.faceLogin(faceLoginPhoneController.text);
                    } else {
                      logic.machineLogin(
                        machineLoginMachineController.text,
                        machineLoginPasswordController.text,
                      );
                    }
                    return;
                  }
                  if (tabController.index == 2) {
                    if (GetPlatform.isAndroid) {
                      logic.machineLogin(
                        machineLoginMachineController.text,
                        machineLoginPasswordController.text,
                      );
                    } else {
                      logic.workNumberLogin(
                        workLoginWorkNumberController.text,
                        workLoginPasswordController.text,
                      );
                    }
                    return;
                  }
                  if (tabController.index == 3) {
                    logic.workNumberLogin(
                      workLoginWorkNumberController.text,
                      workLoginPasswordController.text,
                    );
                    return;
                  }
                },
                child: Text(
                  'login'.tr,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
