import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/login/login_lark_view.dart';
import 'package:jd_flutter/login/login_work_view.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'login_face_view.dart';
import 'login_logic.dart';
import 'login_machine_view.dart';
import 'login_phone_view.dart';

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
      child: Column(
        children: [
          Expanded(
            child: ListView(
              //添加登录UI
              children: [
                GestureDetector(
                  onTap: () =>
                      changeLanguagePopup(changed: () => refreshLanguage()),
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
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, bottom: 10),
              child: Text(
                'v:${packageInfo().version}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
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
  var isShowLoginButton = false.obs;
  var pageIndex = 0.obs;

  //tab控制器
  late TabController tabController = TabController(
    length: hasFrontCamera() && GetPlatform.isMobile ? 5 : 4,
    vsync: this,
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
                EditText(
                  controller: mesInputController,
                  hint: 'MES url',
                ),
                SelectView(
                  controller: mesScrollController,
                  list: mesList.map((v) => v.name).toList(),
                  select: (i) => mesInputController.text = mesList[i].value,
                  errorMsg: '',
                  hint: 'MES BaseUrl :',
                ),
                const SizedBox(height: 40),
                EditText(
                  controller: sapInputController,
                  hint: 'SAP url',
                ),
                SelectView(
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
                var mes = mesInputController.text;
                var sap = sapInputController.text;
                if (mes.isNotEmpty && sap.isNotEmpty) {
                  mesBaseUrl = mes;
                  sapBaseUrl = sap;
                  spSave(spSaveMesBaseUrl, mes);
                  spSave(spSaveSapBaseUrl, sap);
                  Get.offAll(() => const LoginPage());
                } else {
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

  void longClick() => logic.handleLongPressStart(
        changeBaseUrl: () => _changeBaseUrlDialog(),
      );

  void tabChange() {
    pageIndex.value = tabController.index;
  }

  @override
  void initState() {
    state.isReLogin = widget.isReLogin;
    tabController.addListener(tabChange);
    super.initState();
  }

  @override
  void dispose() {
    tabController.removeListener(tabChange);
    tabController.dispose();
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
            if (GetPlatform.isMobile)
              Tab(icon: Image.asset('assets/images/ic_feishu.png')),
            const Tab(icon: Icon(Icons.phone)),
            if (hasFrontCamera() && GetPlatform.isMobile)
              const Tab(icon: Icon(Icons.account_circle_outlined)),
            const Tab(icon: Icon(Icons.precision_manufacturing)),
            const Tab(icon: Icon(Icons.assignment_ind_outlined))
          ],
        ),
        body: Obx(() => IndexedStack(
              index: pageIndex.value,
              children: [
                if (GetPlatform.isMobile)
                  LarkLoginWidget(
                    login: (userId) => logic.larkLogin(userId),
                  ),
                PhoneLoginWidget(
                  login: (phone, password, vCode) => logic.phoneLogin(
                    phone,
                    password,
                    vCode,
                  ),
                  longClick: longClick,
                ),
                if (hasFrontCamera() && GetPlatform.isMobile)
                  FaceLoginWidget(
                    login: (phone) => logic.faceLogin(phone),
                    longClick: longClick,
                  ),
                MachineLoginWidget(
                  login: (machine, password) => logic.machineLogin(
                    machine,
                    password,
                  ),
                  longClick: longClick,
                ),
                WorkLoginWidget(
                  login: (workNumber, password) => logic.workNumberLogin(
                    workNumber,
                    password,
                  ),
                  longClick: longClick,
                )
              ],
            )),
      ),
    );
  }
}
