import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constant.dart';
import '../http/do_http.dart';
import '../http/web_api.dart';
import '../login/login.dart';
import '../reading.dart';
import '../utils.dart';
import '../widget/bluetooth.dart';
import '../widget/dialogs.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({super.key});

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  late Widget image;
  UserController userController = Get.find();

  ///获取照片
  Future<void> takePhoto(bool isGallery) async {
    Get.back();
    //获取照片
    ImagePicker()
        .pickImage(
          imageQuality: 75,
          maxWidth: 700,
          maxHeight: 700,
          source: isGallery ? ImageSource.gallery : ImageSource.camera,
        )
        .then(
          (xFile) => ImageCropper().cropImage(
            sourcePath: xFile!.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            aspectRatioPresets: [CropAspectRatioPreset.square],
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'cropper_title'.tr,
                toolbarColor: Colors.blueAccent,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: 'cropper_title'.tr,
                cancelButtonTitle: 'cropper_cancel'.tr,
                doneButtonTitle: 'cropper_confirm'.tr,
                aspectRatioPickerButtonHidden: true,
                resetAspectRatioEnabled: false,
                aspectRatioLockEnabled: true,
              ),
              WebUiSettings(context: context),
            ],
          ).then((cFile) {
            if (cFile != null) {
              imageToBase64(File(cFile.path)).then((base64) {
                changeUserAvatar(
                  context,
                  base64,
                  back: () => setState(() {
                    userController.user.update((val) => userController.user);
                    image = ClipOval(
                      child: Image.asset(cFile.path, fit: BoxFit.fitWidth),
                    );
                  }),
                );
              });
            }
          }),
        );
  }

  ///图片来源选择 Sheet
  _showTakePhotoSheet() {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text('home_user_setting_avatar_photo_sheet_title'.tr),
        message: Text('home_user_setting_avatar_photo_sheet_message'.tr),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => takePhoto(false),
            child: Text(
              'home_user_setting_avatar_photo_sheet_take_photo'.tr,
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => takePhoto(true),
            child: Text(
              'home_user_setting_avatar_photo_sheet_select_photo'.tr,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Get.back();
            },
            child: Text('dialog_default_cancel'.tr),
          ),
        ],
      ),
    );
  }

  ///返回按钮
  back() {
    return Positioned(
      top: 50,
      left: 20,
      child: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: const Icon(
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
          onTap: () => _showTakePhotoSheet(),
          child: Hero(
            tag: "user",
            child: image,
          ),
        ),
      ),
    );
  }

  ///分割线
  line() {
    return const Column(
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
  }

  ///名字
  name() {
    return Obx(() => Text(
          "${userController.user.value?.name!}(${userController.user.value?.number!})",
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.none,
              color: Colors.black),
        ));
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          Obx(() => Text(
                userController.user.value!.factory!,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.none,
                    color: Colors.black54),
              ))
        ],
      ),
    );
  }

  ///修改部门组别
  _changeDepartment() {
    getDepartmentGroupList(context, back: (list) {
      List pickerChildren = [];
      int selected = 0;
      for (var group in list) {
        if (userController.user.value?.departmentName == group.name) {
          selected = list.indexOf(group);
        }
        pickerChildren.add(group.name);
      }
      showCupertinoModalPopup(
          context: context,
          builder: (BuildContext context) {
            var controller = FixedExtentScrollController(initialItem: selected);
            return Container(
              height: 250,
              color: Colors.grey[200],
              child: Column(
                children: <Widget>[
                  Container(
                    height: 40,
                    color: Colors.grey[200],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
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
                          onPressed: () {
                            changeDepartmentGroup(
                                context, list[controller.selectedItem].itemID);
                            Get.back();
                          },
                          child: Text(
                            'dialog_default_confirm'.tr,
                            style: const TextStyle(
                              color: Colors.blueAccent,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: DefaultTextStyle(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                      child: SizedBox(
                        height: 200,
                        child: CupertinoPicker(
                          scrollController: controller,
                          diameterRatio: 1.5,
                          magnification: 1.22,
                          squeeze: 1.2,
                          useMagnifier: true,
                          itemExtent: 32,
                          onSelectedItemChanged: (value) {
                            logger.i(pickerChildren[value]);
                          },
                          children: pickerChildren.map((data) {
                            return Center(child: Text(data));
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          });
    });
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          GestureDetector(
            onTap: () => _changeDepartment(),
            child: Row(
              children: [
                Obx(() => Text(
                      userController.user.value!.departmentName!,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                          color: Colors.blueAccent),
                    )),
                const Icon(Icons.arrow_drop_down, color: Colors.black45)
              ],
            ),
          )
        ],
      ),
    );
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          Text(
            userController.user.value!.position!,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          SizedBox(
              width: 100,
              child: GestureDetector(
                onTap: () {
                  changePasswordDialog(context);
                },
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.arrow_forward_ios,
                      color: Colors.black45),
                ),
              ))
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
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          GestureDetector(
            onTap: () {
              showDialog<String>(
                  barrierDismissible: false,
                  context: context,
                  builder: (BuildContext context) => const BluetoothDialog());
            },
            child: const Row(
              children: [
                Text(
                  '1.0.0',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      color: Colors.blueAccent),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.black45)
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
            spSave(spSaveUserInfo, "");
            Get.offAll(const Login());
          },
          child: Text('home_user_setting_logout'.tr,
              style: const TextStyle(fontSize: 20))),
    );
  }

  ///设置菜单
  settingMenu() {
    return Positioned(
      top: 320,
      child: Column(
        children: [
          name(),
          const SizedBox(height: 20),
          factory(),
          line(),
          department(),
          line(),
          position(),
          line(),
          changePassword(),
          line(),
          checkVersion(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    image = ClipOval(
      child: Image.network(userController.user.value!.picUrl!,
          fit: BoxFit.fitWidth),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [back(), avatarImage(), settingMenu(), logout()],
      ),
    );
  }
}
