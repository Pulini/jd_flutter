import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/home_function_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'home_logic.dart';
import 'home_setting_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;
  var controller = EasyRefreshController(controlFinishRefresh: true);
  var logo = 'assets/images/ic_logo.png';

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
        onChanged: (v) => logic.search(v),
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
        : item.hasPermission
            ? Colors.blueAccent
            : Colors.grey;
  }

  _listTile(bool isGroup, HomeButton item) {
    return ListTile(
      onTap: () => item.hasUpdate
          ? upData()
          : item.route.isEmpty
              ? showSnackBar(
                  title: '无路由',
                  message: '该功能暂未开放',
                  isWarning: true,
                )
              : Get.toNamed(item.route),
      enabled: item.hasUpdate ? true : item.hasPermission,
      leading: Image.network(
        item.icon,
        width: isGroup ? 30 : 40,
        height: isGroup ? 30 : 40,
        color: _color(item),
        errorBuilder: (ctx, err, stackTrace) => Image.asset(
          logo,
          width: isGroup ? 30 : 40,
          height: isGroup ? 30 : 40,
          color: _color(item),
        ),
      ),
      title: Text(item.name),
      subtitle: Text(item.description),
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
          : item.hasPermission
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
              leading: Image.network(
                (item as HomeButtonGroup).icon,
                width: 50,
                height: 50,
                color: Colors.blueAccent,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  logo,
                  height: 30,
                  width: 30,
                  color: Colors.blueAccent,
                ),
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

  _navigationBar(HomeFunctions bar) {
    return BottomNavigationBarItem(
      icon: Image.network(
        bar.icon ?? '',
        width: 30,
        height: 30,
        color: bar.getTextColor(),
        errorBuilder: (bc, o, st) => Image.asset(
          logo,
          height: 30,
          width: 30,
          color: bar.getTextColor(),
        ),
      ),
      label: bar.className ?? 'Fun',
      backgroundColor: bar.getBKGColor(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getVersionInfo(
        false,
        noUpdate: () {
          loadingDialog('读取功能列表中...');
          logic.refreshFunList(refresh: () =>Get.back());
        },
        needUpdate: (versionInfo) => doUpdate(versionInfo),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Obx(
        () => Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _appBar(),
          body: EasyRefresh(
            controller: controller,
            header: const MaterialHeader(),
            onRefresh: () => logic.refreshFunList(
              refresh: () => controller.finishRefresh(),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.buttons.length,
              itemBuilder: (BuildContext context, int index) =>
                  _item(state.buttons[index], index),
            ),
          ),
          bottomNavigationBar: state.navigationBar.isEmpty
              ? null
              : BottomNavigationBar(
                  // type: BottomNavigationBarType.fixed,
                  type: BottomNavigationBarType.shifting,
                  items: [
                    for (var bar in state.navigationBar) _navigationBar(bar)
                  ],
                  currentIndex: state.nBarIndex,
                  selectedItemColor: state.navigationBar[0].getTextColor(),
                  onTap: (i) => logic.navigationBarClick(i),
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<HomeLogic>();
    controller.dispose();
    super.dispose();
  }
}
