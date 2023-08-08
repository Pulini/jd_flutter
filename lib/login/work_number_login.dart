import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/http/do_http.dart';
import 'package:jd_flutter/utils.dart';

import '../home/home.dart';
import '../widget/number_text_field.dart';

class WorkNumberLogin extends StatefulWidget {
  const WorkNumberLogin({Key? key}) : super(key: key);

  @override
  State<WorkNumberLogin> createState() => _WorkNumberLoginState();
}

class _WorkNumberLoginState extends State<WorkNumberLogin> {
  TextEditingController workNumber = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    workNumber.text = spGet(spSaveLoginWork) ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SizedBox(
        width: 340.0,
        height: 200.0,
        child: Card(
            // color: const Color.fromARGB(255, 213, 41, 42),
            // color: const Color(0xFF242A38),
            color: Colors.blueAccent,
            child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    NumberTextField(
                        numberController: workNumber,
                        maxLength: 6,
                        textStyle: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'login_hint_work_number'.tr,
                          hintStyle: const TextStyle(color: Colors.white),
                          counterStyle: const TextStyle(color: Colors.white),
                          prefixIcon: const Icon(Icons.badge_outlined,
                              color: Colors.white),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              workNumber.clear();
                            },
                          ),
                        )),
                    TextField(
                      obscureText: true,
                      controller: password,
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
                            password.clear();
                          },
                        ),
                      ),
                      maxLength: 10,
                    ),
                  ],
                ))),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(320, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
          onPressed: () => workNumberLogin(
              context, workNumber.text, password.text,
              back: (userInfo) => Get.offAll(const Home())),
          child: Text('login'.tr, style: const TextStyle(fontSize: 20)))
    ]);
  }
}
