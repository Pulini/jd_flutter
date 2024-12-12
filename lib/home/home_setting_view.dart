import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bean/http/response/department_info.dart';
import '../constant.dart';
import '../login/login_view.dart';
import '../utils/utils.dart';
import '../widget/custom_widget.dart';
import '../widget/dialogs.dart';
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

  ///分割线
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

  ///返回按钮
  backArrow() {
    return Positioned(
      top: 50,
      left: 20,
      child: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.black54,
        ),
      ),
    );
  }

  ///头像
  avatarImage() {
    return Positioned(
      top: 100,
      child: SizedBox(
        width: 200,
        height: 200,
        child: GestureDetector(
          onTap: () => logic.takeAvatarPhoto(),
          child: Hero(
            tag: 'user',
            child: logic.userAvatar,
          ),
        ),
      ),
    );
  }

  ///名字
  name() {
    return Text(
      '${userInfo?.name ?? ''}(${userInfo?.number ?? ''})',
      style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.none,
          color: Colors.black),
    );
  }

  ///工厂
  factory() {
    return SizedBox(
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
  }

  ///部门
  department() {
    return SizedBox(
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
                Obx(
                  () => Text(
                    state.departmentName.value,
                    style: clickTextStyle,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black45)
              ],
            ),
          )
        ],
      ),
    );
  }

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
            list.map((data) {
              return Center(child: Text(data.name!));
            }).toList(),
            controller,
          ),
        )
      ],
    ));
  }

  ///职位
  position() {
    return SizedBox(
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
  }

  ///修改密码
  changePassword() {
    return SizedBox(
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
                child:
                    const Icon(Icons.arrow_forward_ios, color: Colors.black45),
              ),
            ),
          )
        ],
      ),
    );
  }

  ///修改密码弹窗
  changePasswordDialog() {
    var oldPassword = TextEditingController();
    var newPassword = TextEditingController();
    showCupertinoModalPopup<void>(
      context: Get.overlayContext!,
      builder: (context) => AlertDialog(
        title: Text('change_password_dialog_title'.tr),
        content: SizedBox(
          height: 150,
          child: Column(
            children: [
              TextField(
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
              TextField(
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

  ///检查版本更新
  checkVersion() {
    return SizedBox(
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
/*            测试接口
              httpGet(
                loading: '检查网络中...',
                method: webApiLNetTest,
                params: {'Seconds': 30},
              ).then((response) {
                if (response.resultCode == resultSuccess) {
                  successDialog(content: response.message);
                } else {
                  errorDialog(content: response.message );
                }
              });
*/
              if (!GetPlatform.isWeb) {
                getVersionInfo(
                  true,
                  noUpdate: () {
                    showSnackBar(
                      title: 'home_user_setting_check_version'.tr,
                      message: 'is_already_latest_version'.tr,
                    );
                  },
                  needUpdate: (versionInfo) {
                    doUpdate(versionInfo);
                  },
                );
              }
            },
            child: Row(
              children: [
                Text(
                  packageInfo.version,
                  style: clickTextStyle,
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.black45)
              ],
            ),
          )
        ],
      ),
    );
  }

  ///注销
  logout() {
    return Positioned(
      bottom: 30,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              minimumSize: const Size(320, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25))),
          onPressed: () {
            spSave(spSaveUserInfo, '');
            Get.offAll(() => const LoginPage());
          },
          child: Text('home_user_setting_logout'.tr,
              style: const TextStyle(fontSize: 20))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          backArrow(),
          avatarImage(),
          Positioned(
            top: 320,
            child: Column(
              children: [
                name(),
                const SizedBox(height: 20),
                factory(),
                line,
                department(),
                line,
                position(),
                line,
                changePassword(),
                line,
                checkVersion(),
              ],
            ),
          ),
          logout()
        ],
      ),
    );
  }
}
