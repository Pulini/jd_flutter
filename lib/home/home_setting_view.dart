import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:jd_flutter/bean/http/response/department_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/login/login_view.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/app_init.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'home_logic.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  final logic = Get.find<HomeLogic>();
  final state = Get.find<HomeLogic>().state;

  var hintTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
      color: Colors.black54);

  var clickTextStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none,
      color: Colors.blueAccent);

  //分割线
  var line = const Column(
    children: [
      SizedBox(height: 5),
      SizedBox(
          width: 250,
          child: Divider(
            height: 1,
            color: Colors.grey,
          )),
      SizedBox(height: 10),
    ],
  );

  //头像
  avatarImage() => Container(
        height: 150,
        width: 150,
        padding: const EdgeInsets.all(7),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: GestureDetector(
          onTap: () => logic.takeAvatarPhoto(),
          child: Hero(
            tag: 'user',
            child: logic.userAvatar,
          ),
        ),
      );

  //名字工号
  name() => Text(
        '${userInfo?.name ?? ''}\r\n${userInfo?.number ?? ''}',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          color: Colors.black,
        ),
      );

  //工厂
  factory() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'home_user_setting_factory'.tr,
              style: hintTextStyle,
            ),
            Text(
              userInfo?.factory ?? '',
              style: hintTextStyle,
            ),
          ],
        ),
      );

  //部门
  department() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'home_user_setting_department'.tr,
              style: hintTextStyle,
            ),
            GestureDetector(
              onTap: () => logic.getDepartment(
                (l, i) => showChangeDepartmentPopup(l, i),
              ),
              child: Row(
                children: [
                  Obx(() =>
                      Text(state.departmentName.value, style: clickTextStyle)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black45)
                ],
              ),
            )
          ],
        ),
      );

  showChangeDepartmentPopup(List<Department> list, int selected) {
    //创建选择器控制器
    var controller = FixedExtentScrollController(initialItem: selected);
    //创建底部弹窗
    showPopup(Column(
      children: <Widget>[
        //选择器顶部按钮
        Container(
          height: 45,
          color: Colors.grey[200],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  'dialog_default_cancel'.tr,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => logic.changeDepartment(
                  list[controller.selectedItem],
                ),
                child: Text(
                  'dialog_default_confirm'.tr,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20,
                  ),
                ),
              )
            ],
          ),
        ),
        //选择器主体
        Expanded(
          child: getCupertinoPicker(
            items: list.map((data) {
              return Center(child: Text(data.name!));
            }).toList(),
            controller: controller,
          ),
        )
      ],
    ));
  }

  //职位
  position() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'home_user_setting_position'.tr,
              style: hintTextStyle,
            ),
            Text(
              userInfo?.position ?? '',
              style: hintTextStyle,
            )
          ],
        ),
      );

  //修改密码
  changePassword() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'home_user_setting_password_change'.tr,
              style: hintTextStyle,
            ),
            SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () => changePasswordDialog(),
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black45),
                ),
              ),
            )
          ],
        ),
      );

  //修改密码弹窗
  changePasswordDialog() {
    var oldPassword = TextEditingController();
    var newPassword = TextEditingController();
    showCupertinoModalPopup<void>(
      context: Get.overlayContext!,
      builder: (context) => AlertDialog(
        title: Text('change_password_dialog_title'.tr),
        content: SizedBox(
          height: 150,
          width: 200,
          child: ListView(
            children: [
              SizedBox(
                height: 50,
                width: 200,
                child: TextField(
                  controller: oldPassword,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    hintText: 'change_password_dialog_old_password'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    counterStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        oldPassword.clear();
                      },
                    ),
                  ),
                  maxLength: 10,
                ),
              ),
              SizedBox(
                height: 50,
                width: 200,
                child: TextField(
                  controller: newPassword,
                  style: const TextStyle(color: Colors.grey),
                  decoration: InputDecoration(
                    hintText: 'change_password_dialog_new_password'.tr,
                    hintStyle: const TextStyle(color: Colors.grey),
                    counterStyle: const TextStyle(color: Colors.grey),
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        newPassword.clear();
                      },
                    ),
                  ),
                  maxLength: 10,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => logic.changePassword(
              oldPassword.text,
              newPassword.text,
            ),
            child: Text('change_password_dialog_submit'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  //检查版本更新
  checkVersion() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'home_user_setting_check_version'.tr,
              style: hintTextStyle,
            ),
            GestureDetector(
              onTap: () {
                // Get.to(()=>PreviewWebLabelList(labelCodes: ['00505685E5761FD0A6B41F6C6832A270','00505685E5761FE0A9AF611246AC0B11','00505685E5761FE0A9B63B849A43B67C'],));
                // Get.to(() =>  const Scanner())?.then((v) {
                //   if(v!=null){
                //     showSnackBar(title: '扫码', message: v);
                //   }
                // });
                // scannerDialog( detect: (String code)=>showSnackBar(title: 'title', message: code));
                if (!GetPlatform.isWeb) {
                  getVersionInfo(
                    true,
                    noUpdate: () {
                      showSnackBar(
                        title: 'home_user_setting_check_version'.tr,
                        message: 'is_already_latest_version'.tr,
                      );
                    },
                    needUpdate: (v) => doUpdate(version: v),
                    error: (msg) => errorDialog(content: msg),
                  );
                }
              },
              child: Row(
                children: [
                  Text(
                    packageInfo().version,
                    style: clickTextStyle,
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.black45)
                ],
              ),
            )
          ],
        ),
      );

  //切换语言
  changeLanguage() => SizedBox(
        width: 260,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              'app_language'.tr,
              style: hintTextStyle,
            ),
            GestureDetector(
              onTap: () =>
                  changeLanguagePopup(changed: () => state.refreshLanguage()),
              child: Row(
                children: [
                  Obx(() => Text(state.language.value, style: clickTextStyle)),
                  const Icon(Icons.arrow_drop_down, color: Colors.black45)
                ],
              ),
            )
          ],
        ),
      );

  //注销
  logout() => ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(320, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        onPressed: () {
          spSave(spSaveUserInfo, '');
          spSave(spSaveFeishuUserWikiTokenData, '');
          spSave(spSaveFeishuUserCloudDocTokenData, '');
          Get.offAll(() => const LoginPage());
        },
        child: Text('home_user_setting_logout'.tr,
            style: const TextStyle(fontSize: 20)),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: 300,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(top: 75),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      name(),
                      const SizedBox(height: 10),
                      factory(),
                      line,
                      department(),
                      line,
                      position(),
                      line,
                      changePassword(),
                      line,
                      checkVersion(),
                      line,
                      changeLanguage(),
                      const SizedBox(height: 30),
                      logout(),
                    ],
                  ),
                ),
                Positioned(
                  child: avatarImage(),
                  right: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
