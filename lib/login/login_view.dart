import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/login/login_state.dart';

import '../widget/custom_widget.dart';
import 'login_logic.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    var logic = Get.put(LoginLogic());
    var state = Get.find<LoginLogic>().state;
    return Container(
      alignment: Alignment.center,
      //设置背景
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.lightBlueAccent, Colors.blueAccent],
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
            'lib/res/images/ic_logo.png',
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
          Container(
            alignment: Alignment.center,
            child: SizedBox(
              width: 320,
              height: 320,
              child: LoginInlet(logic: logic, state: state),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(280, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () => logic.login(),
              child: Text(
                'login'.tr,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class LoginInlet extends StatelessWidget {
  const LoginInlet({
    super.key,
    required this.logic,
    required this.state,
  });

  final LoginLogic logic;
  final LoginState state;

  _tabBar() => TabBar(
        controller: logic.tabController,
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
      );

  _box(Widget child) => Wrap(
        children: [
          Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                color: Colors.blueAccent,
              ),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(20),
              child: child)
        ],
      );

  _phoneLogin() => _box(
        Column(
          children: [
            TextField(
              controller: logic.phoneLoginPhoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_phone'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.phone, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.phoneLoginPhoneController.clear();
                  },
                ),
              ),
              maxLength: 11,
            ),
            TextField(
              obscureText: true,
              controller: logic.phoneLoginPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_password'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.phoneLoginPasswordController.clear();
                  },
                ),
              ),
              maxLength: 10,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: NumberTextField(
                    numberController: logic.phoneLoginVCodeController,
                    maxLength: 6,
                    textStyle: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'login_hint_verify_code'.tr,
                      hintStyle: const TextStyle(color: Colors.white),
                      counterStyle: const TextStyle(color: Colors.white),
                      prefixIcon:
                          const Icon(Icons.email_outlined, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          state.buttonName.value == 'get_verify_code'.tr
                              ? Colors.white
                              : Colors.grey.shade400,
                    ),
                    onPressed: () => logic.getVerifyCode(),
                    child: Obx(
                      () => Text(
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
        NumberTextField(
          numberController: logic.faceLoginPhoneController,
          maxLength: 11,
          textStyle: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'login_hint_phone'.tr,
            hintStyle: const TextStyle(color: Colors.white),
            counterStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.phone_android, color: Colors.white),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                logic.faceLoginPhoneController.clear();
              },
            ),
          ),
        ),
      );

  _machineLogin() => _box(
        Column(
          children: [
            TextField(
              controller: logic.machineLoginMachineController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_machine'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(
                  Icons.precision_manufacturing,
                  color: Colors.white,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.machineLoginMachineController.clear();
                  },
                ),
              ),
              maxLength: 10,
            ),
            TextField(
              obscureText: true,
              controller: logic.machineLoginPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_password'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.machineLoginPasswordController.clear();
                  },
                ),
              ),
              maxLength: 10,
            ),
          ],
        ),
      );

  _workLogin() => _box(
        Column(
          children: [
            NumberTextField(
              numberController: logic.workLoginWorkNumberController,
              maxLength: 6,
              textStyle: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_work_number'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon:
                    const Icon(Icons.badge_outlined, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.workLoginWorkNumberController.clear();
                  },
                ),
              ),
            ),
            TextField(
              obscureText: true,
              controller: logic.workLoginPasswordController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'login_hint_password'.tr,
                hintStyle: const TextStyle(color: Colors.white),
                counterStyle: const TextStyle(color: Colors.white),
                prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    logic.workLoginPasswordController.clear();
                  },
                ),
              ),
              maxLength: 10,
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: _tabBar(),
      body: TabBarView(
        controller: logic.tabController,
        children: [
          _phoneLogin(),
          if (GetPlatform.isAndroid) _faceLogin(),
          _machineLogin(),
          _workLogin()
        ],
      ),
    );
  }
}
