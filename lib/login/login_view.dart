import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/number_text_field.dart';
import 'login_logic.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final logic = Get.put(LoginLogic());
  final state = Get.find<LoginLogic>().state;

  ///人脸登录Page
  Widget _pageFaceLogin() {
    return Column(
      children: [
        SizedBox(
          width: 340.0,
          height: 120.0,
          child: Card(
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  NumberTextField(
                    numberController: logic.faceLoginPhoneController,
                    maxLength: 11,
                    textStyle: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'login_hint_phone'.tr,
                      hintStyle: const TextStyle(color: Colors.white),
                      counterStyle: const TextStyle(color: Colors.white),
                      prefixIcon:
                          const Icon(Icons.phone_android, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          logic.faceLoginPhoneController.clear();
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(320, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => logic.faceLogin(),
          child: Text(
            'login'.tr,
            style: const TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  ///机台登录Page
  Widget _pageMachineLogin() {
    return Column(
      children: [
        SizedBox(
          width: 340.0,
          height: 200.0,
          child: Card(
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                    maxLength: 5,
                  ),
                  TextField(
                    obscureText: true,
                    controller: logic.machineLoginPasswordController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'login_hint_password'.tr,
                      hintStyle: const TextStyle(color: Colors.white),
                      counterStyle: const TextStyle(color: Colors.white),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.white),
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
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(320, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () => logic.machineLogin(),
          child: Text(
            'login'.tr,
            style: const TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  ///手机号登录Page
  Widget _pagePhoneLogin() {
    return Column(
      children: [
        SizedBox(
          width: 340.0,
          height: 270.0,
          child: Card(
            color: Colors.blueAccent,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
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
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.white),
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
                            prefixIcon: const Icon(Icons.email_outlined,
                                color: Colors.white),
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
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(320, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
          onPressed: () => logic.phoneLogin(),
          child: Text(
            'login'.tr,
            style: const TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  ///工号登录Page
  Widget _workNumberLogin() {
    return Column(children: [
      SizedBox(
        width: 340.0,
        height: 200.0,
        child: Card(
          color: Colors.blueAccent,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.white),
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
          ),
        ),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(320, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () => logic.workNumberLogin(),
        child: Text(
          'login'.tr,
          style: const TextStyle(fontSize: 20),
        ),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //设置背景
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: ListView(
          //添加登录UI
          children: [
            const SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "lib/res/images/ic_logo.png",
                  width: 130,
                  height: 130,
                ),
                const Text(
                  "Gold Emperor",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 500,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 340,
                    child: TabBar(
                      controller: logic.tabController,
                      dividerColor: Colors.transparent,
                      indicatorColor: Colors.greenAccent,
                      labelColor: Colors.greenAccent,
                      unselectedLabelColor: Colors.white,
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                      tabs: [
                        const Tab(icon: Icon(Icons.phone)),
                        if (GetPlatform.isAndroid)
                          const Tab(icon: Icon(Icons.account_circle_outlined)),
                        const Tab(icon: Icon(Icons.precision_manufacturing)),
                        const Tab(icon: Icon(Icons.assignment_ind_outlined))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: TabBarView(
                      controller: logic.tabController,
                      children: [
                        _pagePhoneLogin(),
                        if (GetPlatform.isAndroid) _pageFaceLogin(),
                        _pageMachineLogin(),
                        _workNumberLogin(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<LoginLogic>();
    super.dispose();
  }
}
