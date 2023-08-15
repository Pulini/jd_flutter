import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../constant.dart';
import '../http/web_api.dart';
import '../utils.dart';
import '../widget/dialogs.dart';
import 'home_logic.dart';
import 'home_setting_view.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;

  int selectedIndex = 0;
  final pages = [
    GestureDetector(
      onTap: TapUtil.debounce(() {
        logger.d("onTap${DateTime.now()}");
      }),
      child: Text('home_bottom_bar_produce'.tr),
    ),
    Text('home_bottom_bar_warehouse'.tr),
    Text('home_bottom_bar_manage'.tr),
  ];

  final barItem = [
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
  ];

  appBar() {
    return AppBar(
      title: const Text('Gold Emperor'),
      titleTextStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Hero(tag: "user", child: logic.userAvatar),
          onPressed: () => Get.to(() => const UserSetting()),
        )
      ],
    );
  }

  _methodChannel() {
    const MethodChannel(channelAndroidSend).setMethodCallHandler((call) {
      switch (call.method) {
        case "JMessage":
          {
            switch (call.arguments["json"]) {
              case "UpDate":
                {}
                break;
            }
          }
          break;
      }
      return Future.value(null);
    });
  }

  @override
  void initState() {
    super.initState();
    getVersionInfo(
      false,
      noUpdate: () {},
      needUpdate: (versionInfo) => doUpdate(context, versionInfo),
    );
    _methodChannel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar(),
        body: Center(
          child: pages.elementAt(selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.shifting,
          items: barItem,
          currentIndex: selectedIndex,
          selectedItemColor: const Color.fromARGB(0xff, 0xff, 0xff, 0x66),
          onTap: (index) => setState(() => selectedIndex = index),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<HomeLogic>();
    super.dispose();
  }
}
