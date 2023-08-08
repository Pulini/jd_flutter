import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/http/do_http.dart';

import '../home/home.dart';
import '../utils.dart';

class MachineLogin extends StatefulWidget {
  const MachineLogin({Key? key}) : super(key: key);

  @override
  State<MachineLogin> createState() => _MachineLoginState();
}

class _MachineLoginState extends State<MachineLogin> {
  TextEditingController machine = TextEditingController();
  TextEditingController password = TextEditingController();

  @override
  void initState() {
    super.initState();
    machine.text = spGet(spSaveLoginMachine) ?? "";
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
                    TextField(
                      controller: machine,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'login_hint_machine'.tr,
                        hintStyle: const TextStyle(color: Colors.white),
                        counterStyle: const TextStyle(color: Colors.white),
                        prefixIcon: const Icon(Icons.precision_manufacturing,
                            color: Colors.white),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            machine.clear();
                          },
                        ),
                      ),
                      maxLength: 5,
                    ),
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
          onPressed: () => machineLogin(context, machine.text, password.text,
              back: (userInfo) => Get.offAll(const Home())),
          child: Text('login'.tr, style: const TextStyle(fontSize: 20)))
    ]);
  }
}
