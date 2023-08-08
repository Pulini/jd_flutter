import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/home/user_setting.dart';
import 'package:jd_flutter/utils.dart';

import '../constant.dart';
import '../reading.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  int _selectedIndex = 0;
  UserController userController = Get.find();
  final _widgetOptions = [
    Text('home_bottom_bar_produce'.tr),
    Text('home_bottom_bar_warehouse'.tr),
    Text('home_bottom_bar_manage'.tr),
  ];


  @override
  void initState() {
    super.initState();
    _initJPushListener();
  }

  _initJPushListener() {
    const MethodChannel(channelAndroidSend).setMethodCallHandler((call) {
      switch (call.method) {
        case "JMessage":
          {
            String msg = call.arguments["json"];
          }
          break;
      }
      return Future.value(null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            title: const Text('Gold Emperor'),
            titleTextStyle: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              IconButton(
                icon: Hero(
                  tag: "user",
                  child: Obx(
                    () => userController.user.value!.picUrl == null
                        ? const Icon(Icons.flutter_dash, color: Colors.white)
                        : ClipOval(
                            child: Image.network(
                                userController.user.value!.picUrl!),
                          ),
                  ),
                ),
                onPressed: () {
                  Get.to(const UserSetting());
                },
              )
            ]),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: const Icon(Icons.display_settings),
                label: 'home_bottom_bar_produce'.tr,
                backgroundColor: const Color.fromARGB(0xff, 0x99, 0xcc, 0x66)),
            BottomNavigationBarItem(
                icon: const Icon(Icons.factory_outlined),
                label: 'home_bottom_bar_warehouse'.tr,
                backgroundColor: const Color.fromARGB(0xff, 0xff, 0x66, 0x66)),
            BottomNavigationBarItem(
                icon: const Icon(Icons.assignment_outlined),
                label: 'home_bottom_bar_manage'.tr,
                backgroundColor: const Color.fromARGB(0xff, 0x00, 0x99, 0xcc)),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color.fromARGB(0xff, 0xff, 0xff, 0x66),
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
      ),
    );
  }
}
