import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/login/login_dialog.dart';
import 'package:jd_flutter/login/login_lark/login_lark_view.dart';
import 'package:jd_flutter/login/login_work_view.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
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
              child: Obx(() => Text(
                    'v:${getVersion()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.none,
                    ),
                  )),
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
  var pageIndex = 0.obs;
  var tabList = <Widget>[];
  var tabPageList = <Widget>[];

  //tab控制器
  late TabController tabController;

  void longClick() =>
      logic.handleLongPressStart(changeBaseUrl: () => changeBaseUrlDialog());

  void tabChange() => pageIndex.value = tabController.index;

  void initTab() {
    tabList = [
      // if (GetPlatform.isMobile)
        Tab(icon: Image.asset('assets/images/ic_feishu.png')),
      const Tab(icon: Icon(Icons.phone)),
      if (hasFrontCamera() && GetPlatform.isMobile)
        const Tab(icon: Icon(Icons.account_circle_outlined)),
      const Tab(icon: Icon(Icons.precision_manufacturing)),
      const Tab(icon: Icon(Icons.assignment_ind_outlined))
    ];
    tabPageList = [
      // if (GetPlatform.isMobile)
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
        getVCode: (phone) => logic.getVerifyCode(phone),
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
    ];
    tabController = TabController(
      length: tabPageList.length,
      vsync: this,
    )..addListener(tabChange);
  }

  @override
  void initState() {
    state.isReLogin = widget.isReLogin;
    initTab();
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
      height: 380,
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
          tabs: tabList,
        ),
        body: Obx(() => IndexedStack(
              index: pageIndex.value,
              children: tabPageList,
            )),
      ),
    );
  }
}
