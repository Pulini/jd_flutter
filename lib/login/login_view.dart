import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/number_text_field_widget.dart';
import 'login_logic.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var language = ''.obs;

  void refreshLanguage() {
    language.value = languages[
        locales.indexWhere((v) => v.languageCode == Get.locale!.languageCode)];
  }

  @override
  void initState() {
    refreshLanguage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      //设置背景
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isTestUrl()
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
          GestureDetector(
            onTap: () => changeLanguagePopup(changed: () => refreshLanguage()),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => Text(
                      language.value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.none,
                        color: Colors.white,
                      ),
                    )),
                const Icon(Icons.arrow_drop_down, color: Colors.white)
              ],
            ),
          ),
          Image.asset(
            'assets/images/ic_logo.png',
            width: 130,
            height: 130,
          ),
          const Text(
            'Gold Emperor',
            style: TextStyle(
              fontSize: 40,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
            ),
            textAlign: TextAlign.center,
          ),
          const Center(child: LoginPick(isReLogin: false)),
          const SizedBox(height: 20),
        ],
      ),
    );
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
  late TabController tabController = TabController(
    length: hasFrontCamera() && GetPlatform.isMobile ? 4 : 3,
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
    ..text = spGet(spSaveLoginPhone) ?? '';

  //手机登录密码输入框控制器
  var phoneLoginPasswordController = TextEditingController();

  //手机登录验证码输入框控制器
  var phoneLoginVCodeController = TextEditingController();

  //工号登录工号输入框控制器
  var workLoginWorkNumberController = TextEditingController()
    ..text = spGet(spSaveLoginWork) ?? '';

  //工号登录密码输入框控制器
  var workLoginPasswordController = TextEditingController();

  TextField textField({
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

  Wrap _box(Widget child) => Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: isTestUrl() ? Colors.teal : Colors.blueAccent,
            ),
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(20),
            child: child,
          )
        ],
      );

  dynamic _phoneLogin() => _box(
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
            if (!isTestUrl())
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
                          backgroundColor: state.countTimer.value == 0
                              ? Colors.white
                              : Colors.grey.shade400,
                        ),
                        onPressed: () => logic.getVerifyCode(
                          phoneLoginPhoneController.text,
                        ),
                        child: Text(
                          state.countTimer.value == 0
                              ? 'get_verify_code'.tr
                              : (60 - state.countTimer.value).toString(),
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

  dynamic _faceLogin() => _box(
        textField(
          controller: faceLoginPhoneController,
          hint: 'login_hint_phone'.tr,
          leftIcon: const Icon(Icons.phone_android, color: Colors.white),
          maxLength: 11,
        ),
      );

  dynamic _machineLogin() => _box(
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

  dynamic _workLogin() => _box(
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
  void _changeBaseUrlDialog() {
    var mesList = BaseUrl.values.where((v) => v.type == 'MES').toList();
    var sapList = BaseUrl.values.where((v) => v.type == 'SAP').toList();
    var initMes = mesList.indexWhere((v) => v.value == mesBaseUrl);
    var initSap = sapList.indexWhere((v) => v.value == sapBaseUrl);
    var mesInputController = TextEditingController(
      text: mesList[initMes].value,
    );
    var sapInputController = TextEditingController(
      text: sapList[initSap].value,
    );
    var mesScrollController = FixedExtentScrollController(
      initialItem: initMes == -1 ? 0 : initMes,
    );
    var sapScrollController = FixedExtentScrollController(
      initialItem: initSap == -1 ? 0 : initSap,
    );
    Get.dialog(
      PopScope(
        canPop: false,
        child: AlertDialog(
          content: SizedBox(
            width: 450,
            height: 400,
            child: ListView(
              children: [
                EditText(controller: mesInputController,hint: 'MES url',),
                selectView(
                  controller: mesScrollController,
                  list: mesList.map((v) => v.name).toList(),
                  select: (i) => mesInputController.text = mesList[i].value,
                  errorMsg: '',
                  hint: 'MES BaseUrl :',
                ),
                const SizedBox(height: 40),
                EditText(controller: sapInputController,hint: 'SAP url',),
                selectView(
                  controller: sapScrollController,
                  list: sapList.map((v) => v.name).toList(),
                  select: (i) => sapInputController.text = sapList[i].value,
                  errorMsg: '',
                  hint: 'SAP BaseUrl :',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                var mes=mesInputController.text;
                var sap=sapInputController.text;
                if(mes.isNotEmpty && sap.isNotEmpty){
                  mesBaseUrl=mes;
                  sapBaseUrl=sap;
                  spSave(spSaveMesBaseUrl, mes);
                  spSave(spSaveSapBaseUrl, sap);
                  Get.offAll(() => const LoginPage());
                }else{
                  errorDialog(content: 'URL 不能为空');
                }
              },
              child: Text('dialog_default_confirm'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'dialog_default_back'.tr,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            if (hasFrontCamera() && GetPlatform.isMobile)
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
                  if (hasFrontCamera() && GetPlatform.isMobile) _faceLogin(),
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
                onLongPress: () => logic.handleLongPressStart(
                  changeBaseUrl: () => _changeBaseUrlDialog(),
                ),
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
                    if (hasFrontCamera() && GetPlatform.isMobile) {
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
                    if (hasFrontCamera() && GetPlatform.isMobile) {
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
