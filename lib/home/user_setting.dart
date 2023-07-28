import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../constant.dart';
import '../generated/l10n.dart';
import '../http/do_http.dart';
import '../http/response/user_info.dart';
import '../utils.dart';
import '../widget/bluetooth.dart';
import '../widget/dialogs.dart';

class UserSetting extends StatefulWidget {
  const UserSetting({super.key, required this.user});

  final UserInfo user;

  @override
  State<UserSetting> createState() => _UserSettingState();
}

class _UserSettingState extends State<UserSetting> {
  late Widget image;
  late String path;

  ///获取照片
  Future<void> takePhoto(bool isGallery) async {
    Navigator.pop(context);
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
                toolbarTitle: S.current.cropper_title,
                toolbarColor: Colors.blueAccent,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
              ),
              IOSUiSettings(
                title: S.current.cropper_title,
                cancelButtonTitle: S.current.cropper_cancel,
                doneButtonTitle: S.current.cropper_confirm,
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
                  back: (path) => setState(() {
                    this.path = path;
                    image = ClipOval(
                      child: Image.asset(this.path, fit: BoxFit.fitWidth),
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
        title: Text(S.current.home_user_setting_avatar_photo_sheet_title),
        message: Text(S.current.home_user_setting_avatar_photo_sheet_message),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => takePhoto(false),
            child: Text(
              S.current.home_user_setting_avatar_photo_sheet_take_photo,
            ),
          ),
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () => takePhoto(true),
            child: Text(
              S.current.home_user_setting_avatar_photo_sheet_select_photo,
            ),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(S.current.dialog_default_cancel),
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
          Navigator.pop(context);
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
    return Text(
      "${widget.user.name!}(${widget.user.number!})",
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
            S.current.home_user_setting_factory,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          Text(
            widget.user.factory!,
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

  ///修改部门组别
  _changeDepartment() {
    getDepartmentGroupList(context, back: (list) {
      List pickerChildren = [];
      int selected = 0;
      for (var group in list) {
        if (widget.user.departmentName == group.name) {
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
                            Navigator.pop(context);
                          },
                          child: Text(
                            S.current.dialog_default_cancel,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context, controller.selectedItem);
                          },
                          child: Text(
                            S.current.dialog_default_confirm,
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
                            print(pickerChildren[value]);
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
          }).then((index) {
        print(index);
        if (index != selected && index != null) {
          changeDepartmentGroup(context, list[index].itemID, back: () {
            userInfo().then((newUser) {
              setState(() {
                selected = index;
                widget.user.departmentID = newUser.departmentID;
                widget.user.departmentName = newUser.departmentName;
                departmentName = widget.user.departmentName ?? "";
              });
            });
          });
        }
      });
    });
  }

  var departmentName = "";

  ///部门
  department() {
    return SizedBox(
      width: 260,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            S.current.home_user_setting_department,
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
                Text(
                  departmentName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                      color: Colors.blueAccent),
                ),
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
            S.current.home_user_setting_position,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
                color: Colors.black54),
          ),
          Text(
            widget.user.position!,
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
            S.current.home_user_setting_password_change,
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
            S.current.home_user_setting_check_version,
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
            Navigator.pushNamedAndRemoveUntil(
                context, "/login", (route) => false);
          },
          child: Text(S.current.home_user_setting_logout,
              style: const TextStyle(fontSize: 20))),
    );
  }

  ///设置菜单
  settingMenu() {
    return Positioned(
      top: 320,
      bottom: 200,
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
      child: Image.network(widget.user.picUrl!, fit: BoxFit.fitWidth),
    );
    departmentName = widget.user.departmentName ?? "";
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
