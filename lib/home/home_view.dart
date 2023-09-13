import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../bean/home_button.dart';
import '../constant.dart';
import '../http/web_api.dart';
import '../utils.dart';
import '../widget/dialogs.dart';
import 'home_logic.dart';
import 'home_setting_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;

  _appBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.email_outlined,
          color: Colors.blueAccent,
        ),
        onPressed: () => showSnackBar(
          title: '消息中心',
          message: '进入消息中心',
        ),
      ),
      title: CupertinoSearchTextField(
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.circular(20),
        ),
        placeholder: 'home_top_search'.tr,
        onChanged: (String value) {
          state.search = value;
          state.refreshButton();
        },
      ),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Hero(tag: 'user', child: logic.userAvatar),
          onPressed: () => Get.to(() => const UserSetting()),
        )
      ],
    );
  }

  Color _color(HomeButton item) {
    return item.hasUpdate
        ? Colors.green[200]!
        : item.lock
            ? Colors.blueAccent
            : Colors.grey;
  }

  _listTile(bool isGroup, HomeButton item) {
    return ListTile(
      onTap: () => item.hasUpdate
          ? upData()
          : item.route.isEmpty
              ? showSnackBar(title: '无路由', message: '该功能暂未开放')
              : Get.toNamed(item.route),
      enabled: item.hasUpdate ? true : item.lock,
      leading: Image.asset(
        item.icon,
        color: _color(item),
        width: isGroup ? 30 : 40,
        height: isGroup ? 30 : 40,
      ),
      title: Text(item.name),
      subtitle: Text(
        item.description,
      ),
      trailing: item.hasUpdate
          ? Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              direction: Axis.vertical,
              children: [
                Icon(Icons.cloud_upload, color: Colors.green[200]),
                Text('home_button_has_update'.tr,
                    style: TextStyle(
                      color: _color(item),
                      fontSize: 10,
                    )),
              ],
            )
          : item.lock
              ? const Icon(Icons.arrow_forward_ios, size: 15)
              : Text('home_button_no_permission'.tr),
    );
  }

  _item(ButtonItem item, int index) {
    return Card(
      color: item is HomeButton ? Colors.white : Colors.blue.shade50,
      child: item is HomeButton
          ? _listTile(false, item)
          : ExpansionTile(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              leading: Image.asset(
                (item as HomeButtonGroup).icon,
                color: Colors.blueAccent,
                width: 50,
                height: 50,
              ),
              title: Text(item.name),
              subtitle: Text(item.description),
              children: [
                for (var item in item.functionGroup)
                  Column(
                    children: [
                      const Divider(indent: 20, endIndent: 20),
                      _listTile(true, item),
                    ],
                  )
              ],
            ),
    );
  }

  _bottomNavigationBar() {
    return Obx(
      () => BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.display_settings),
            label: 'home_bottom_bar_produce'.tr,
            backgroundColor: const Color.fromARGB(0xff, 0x99, 0xcc, 0x66),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.factory_outlined),
            label: 'home_bottom_bar_warehouse'.tr,
            backgroundColor: const Color.fromARGB(0xff, 0xff, 0x66, 0x66),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.assignment_outlined),
            label: 'home_bottom_bar_manage'.tr,
            backgroundColor: const Color.fromARGB(0xff, 0x00, 0x99, 0xcc),
          ),
        ],
        currentIndex: state.navigationBarIndex.value,
        selectedItemColor: const Color.fromARGB(0xff, 0xff, 0xff, 0x66),
        onTap: (index) {
          state.navigationBarIndex.value = index;
          state.refreshButton();
        },
      ),
    );
  }

  _methodChannel() {
    const MethodChannel(channelAndroidSend).setMethodCallHandler((call) {
      switch (call.method) {
        case 'JMessage':
          {
            switch (call.arguments['json']) {
              case 'UpDate':
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

    // getVersionInfo(
    //   false,
    //   noUpdate: () => _getFunList(),
    //   needUpdate: (versionInfo) => doUpdate(versionInfo),
    // );
    _methodChannel();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _appBar(),
        body: Obx(
          () => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.buttons.length,
            itemBuilder: (BuildContext context, int index) =>
                _item(state.buttons[index], index),
          ),
        ),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<HomeLogic>();
    super.dispose();
  }
}
