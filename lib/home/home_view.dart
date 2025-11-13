import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

const _logo = 'assets/images/ic_logo.png';

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

  _item(ButtonItem item) => Card(
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
                leading: Image.network(
                  (item as HomeButtonGroup).icon,
                  width: 50,
                  height: 50,
                  cacheHeight: 75,
                  cacheWidth: 75,
                  color: Colors.blueAccent,
                  errorBuilder: (c, e, s) => Image.asset(
                    _logo,
                    height: 30,
                    width: 30,
                    cacheHeight: 75,
                    cacheWidth: 75,
                    color: Colors.blueAccent,
                  ),
                ),
                title: Text(item.name),
                subtitle: Text(item.description),
                children: [
                  for (var item in item.functionGroup) ...[
                    const Divider(indent: 20, endIndent: 20),
                    HomeSubItem(
                      isGroup: true,
                      item: item,
                      checkUpData: () => logic.checkFunctionVersion(),
                    )
                  ]
                ],
              ),
      );

  _refreshFunList() =>
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
    return Container(
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
                  Get.to(()=> const MessageCenterPage());
                }
              },
            ),
            title: CupertinoSearchTextField(
              decoration: BoxDecoration(
                color: Colors.white54,
                borderRadius: BorderRadius.circular(20),
              ),
              placeholder: 'home_top_search'.tr,
              onChanged: (v) => setState(() => logic.search(v)),
            ),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: Hero(tag: 'user', child: logic.userAvatar),
                onPressed: () => Get.to(() => const UserSetting())!.then((v){}),
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
                  itemBuilder: (context, index) => _item(state.buttons[index]),
                )),
          ),
          bottomNavigationBar: Obx(
            () => state.navigationBar.isEmpty
                ? Container()
                : BottomNavigationBar(
                    type: BottomNavigationBarType.shifting,
                    items: [
                      for (var bar in state.navigationBar)
                        BottomNavigationBarItem(
                          icon: Image.network(
                            bar.icon ?? '',
                            width: 30,
                            height: 30,
                            cacheHeight: 75,
                            cacheWidth: 75,
                            color: bar.getTextColor(),
                            errorBuilder: (ctx, err, stackTrace) => Image.asset(
                              _logo,
                              height: 30,
                              width: 30,
                              cacheHeight: 75,
                              cacheWidth: 75,
                              color: bar.getTextColor(),
                            ),
                          ),
                          label: bar.className ?? 'Fun',
                          backgroundColor: bar.getBKGColor(),
                        )
                    ],
                    currentIndex: state.nBarIndex,
                    selectedItemColor: state.navigationBar.first.getTextColor(),
                    onTap: (i) => setState(() => logic.navigationBarClick(i)),
                  ),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<HomeLogic>();
    super.dispose();
  }
}

class HomeSubItem extends StatelessWidget {
  const HomeSubItem({
    super.key,
    required this.isGroup,
    required this.item,
    required this.checkUpData,
  });

  final bool isGroup;
  final HomeButton item;
  final Function() checkUpData;

  Color _color(HomeButton item) {
    return item.hasUpdate
        ? Colors.green[200]!
        : item.hasPermission
            ? Colors.blueAccent
            : Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => item.hasUpdate
          ? upData()
          : item.route.isEmpty
              ? showSnackBar(
                  title: 'home_no_route'.tr,
                  message: 'home_this_function_is_not_open'.tr,
                  isWarning: true,
                )
              : item.toFunction(checkUpData: checkUpData),
      enabled: item.hasUpdate ? true : item.hasPermission,
      leading: Image.network(
        item.icon,
        width: isGroup ? 30 : 40,
        height: isGroup ? 30 : 40,
        cacheHeight: 75,
        cacheWidth: 75,
        color: _color(item),
        errorBuilder: (context, url, error) => Image.asset(
          _logo,
          width: isGroup ? 30 : 40,
          height: isGroup ? 30 : 40,
          cacheHeight: 75,
          cacheWidth: 75,
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
                Icon(Icons.cloud_upload, color: Colors.green.shade200),
                Text(
                  'home_button_has_update'.tr,
                  style: TextStyle(
                    color: _color(item),
                    fontSize: 10,
                  ),
                ),
              ],
            )
          : item.hasPermission
              ? const Icon(Icons.arrow_forward_ios, size: 15)
              : Text('home_button_no_permission'.tr),
    );
  }
}
