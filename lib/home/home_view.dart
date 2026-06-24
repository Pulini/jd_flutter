import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/message_center/message_center_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/tsc_label_templates/tsc_label_preview.dart';
import 'package:permission_handler/permission_handler.dart';

import 'home_logic.dart';
import 'home_setting_view.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final logic = Get.put(HomeLogic());
  final state = Get.find<HomeLogic>().state;
  var refreshController = EasyRefreshController(controlFinishRefresh: true);

  @override
  bool get wantKeepAlive => true; // 启用保活

  Card _item(ButtonItem item) => Card(
        color: item is HomeButton ? Colors.white : Colors.blue.shade50,
        child: item is HomeButton
            ? HomeSubItem(
                isGroup: false,
                item: item,
                checkUpData: () => logic.checkFunctionVersion(),
              )
            : ExpansionTile(
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                leading: cachedNetworkImage(
                  (item as HomeButtonGroup).icon,
                  width: 50,
                  height: 50,
                  color: Colors.blueAccent,
                ),
                title: Text(item.name,style: const TextStyle(fontSize: 18)),
                subtitle: Text(item.description),
                children: [
                  for (var item in item.functionGroup) ...[
                    const Divider(
                      indent: 50,
                      endIndent: 20,
                      height: 1,
                    ),
                    HomeSubItem(
                      isGroup: true,
                      item: item,
                      checkUpData: () => logic.checkFunctionVersion(),
                    )
                  ]
                ],
              ),
      );

  void _refreshFunList() =>
      logic.refreshFunList(() => refreshController.finishRefresh());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getVersionInfo(
        false,
        noUpdate: () => _refreshFunList(),
        needUpdate: (v) =>
            doUpdate(version: v, ignore: () => _refreshFunList()),
        error: (msg) => errorDialog(content: msg),
      );
      await Permission.notification.request();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          exitDialog(
            content: 'home_exit'.tr,
            confirm: () => SystemNavigator.pop(),
          );
        }
      },
      child: Container(
        decoration: backgroundColor(),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.email_outlined,
                  color: Colors.blueAccent,
                ),
                onPressed: () {
                  if (isTestUrl()) {
                    Get.to(() => const TscLabelPreview());
                  } else {
                    Get.to(() => const MessageCenterPage());
                  }
                },
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
                  onPressed: () =>
                      Get.to(() => const UserSetting())!.then((v) {}),
                )
              ],
            ),
            body: EasyRefresh(
              controller: refreshController,
              header: const MaterialHeader(),
              onRefresh: () => _refreshFunList(),
              child: Obx(() => ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: state.buttons.length,
                    itemBuilder: (context, index) =>
                        _item(state.buttons[index]),
                  )),
            ),
            bottomNavigationBar: Obx(
              () => state.navigationBar.isEmpty
                  ? Container(height: 0)
                  : BottomNavigationBar(
                      type: BottomNavigationBarType.shifting,
                      items: [
                        for (var bar in state.navigationBar)
                          BottomNavigationBarItem(
                            icon: cachedNetworkImage(
                              bar.icon,
                              width: 30,
                              height: 30,
                              color: bar.getTextColor(),
                            ),
                            label: bar.className ?? 'Fun',
                            backgroundColor: bar.getBKGColor(),
                          )
                      ],
                      currentIndex: state.nBarIndex.value,
                      selectedItemColor:
                          state.navigationBar.first.getTextColor(),
                      onTap: (i) => logic.navigationBarClick(i),
                    ),
            )),
      ),
    );
  }

  @override
  void dispose() {
    refreshController.dispose();
    Get.delete<HomeLogic>();
    super.dispose();
  }
}

class HomeSubItem extends StatefulWidget {
  const HomeSubItem({
    super.key,
    required this.isGroup,
    required this.item,
    required this.checkUpData,
  });

  final bool isGroup;
  final HomeButton item;
  final Function() checkUpData;

  @override
  State<HomeSubItem> createState() => _HomeSubItemState();
}

class _HomeSubItemState extends State<HomeSubItem> {

  Color _color(HomeButton item) {
    return item.hasUpdate
        ? Colors.green[200]!
        : item.hasPermission
            ? Colors.blueAccent
            : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: widget.isGroup ? 40 : 0),
      child: ListTile(
        onTap: () {
          if (widget.item.hasUpdate) {
            (() => upData());
          } else if (widget.item.route.isEmpty) {
            showSnackBar(
              title: 'home_no_route'.tr,
              message: 'home_this_function_is_not_open'.tr,
              isWarning: true,
            );
          } else {
            widget.item.toFunction(checkUpData: widget.checkUpData);
          }
        },
        enabled: widget.item.hasUpdate ? true : widget.item.hasPermission,
        leading: cachedNetworkImage(
          widget.item.icon,
          width: widget.isGroup ? 30 : 40,
          height: widget.isGroup ? 30 : 40,
          color: _color(widget.item),
        ),
        title: Text(widget.item.name, style: const TextStyle(fontSize: 14)),
        subtitle: Text(widget.item.description, style: const TextStyle(fontSize: 12)),
        trailing: widget.item.hasUpdate
            ? Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                children: [
                  Icon(Icons.cloud_upload, color: Colors.green.shade200),
                  Text(
                    'home_button_has_update'.tr,
                    style: TextStyle(
                      color: _color(widget.item),
                      fontSize: 10,
                    ),
                  ),
                ],
              )
            : widget.item.hasPermission
                ? const Icon(Icons.arrow_forward_ios, size: 15)
                : Text('home_button_no_permission'.tr),
      ),
    );
  }
}
