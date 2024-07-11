import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';
import '../bean/http/request/user_avatar.dart';
import '../bean/http/response/department_info.dart';
import '../bean/http/response/home_function_info.dart';
import '../constant.dart';
import '../web_api.dart';
import '../widget/custom_widget.dart';
import '../widget/dialogs.dart';
import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  ///用户头像
  late Widget userAvatar;

  @override
  void onInit() {
    super.onInit();
    userAvatar = Obx(
      () => state.userPicUrl.value.isEmpty
          ? const Icon(Icons.flutter_dash, color: Colors.white)
          : ClipOval(child: Image.network(userInfo!.picUrl!)),
    );
  }

  @override
  onReady() {
    super.onReady();
    getVersionInfo(
      false,
      noUpdate: () {},
      needUpdate: (versionInfo) => doUpdate(versionInfo),
    );
  }

  refreshFunList({required Function()  refresh}) {
    httpGet(
      method: webApiGetMenuFunction,
      loading: 'checking_version'.tr,
      params: {'empID': userInfo?.empID ?? 0},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <HomeFunctions>[];
        for (var item in jsonDecode(response.data)) {
          list.add(HomeFunctions.fromJson(item));
        }
        state.refreshFunctions(list);
      } else {
        errorDialog(content: response.message);
      }
      refresh.call();
    });
  }

  ///底部弹窗
  takeAvatarPhoto() {
    takePhoto((f) {
      httpPost(
        loading: 'home_user_setting_avatar_photo_submitting'.tr,
        method: webApiChangeUserAvatar,
        body: UserAvatar(
          imageBase64: File(f.path).toBase64(),
          empID: userInfo!.empID!,
          userID: userInfo!.userID!,
        ),
      ).then((changeAvatarCallback) {
        if (changeAvatarCallback.resultCode == resultSuccess) {
          showSnackBar(
            title: 'home_user_setting_avatar_photo_sheet_title'.tr,
            message: changeAvatarCallback.message!,
          );
        } else {
          errorDialog(content: changeAvatarCallback.message);
        }
      });
    }, title: 'home_user_setting_avatar_photo_sheet_title'.tr);
  }

  ///部门列表弹窗
  changeDepartment() async {
    //获取部门列表
    var departmentCallback = await httpGet(
      loading: 'getting_group'.tr,
      method: webApiPickerSapGroup,
      params: {'EmpID': userInfo!.empID},
    );
    if (departmentCallback.resultCode == resultSuccess) {
      //创建部门列表数据
      List<Department> list = [];
      for (var item in jsonDecode(departmentCallback.data)) {
        list.add(Department.fromJson(item));
      }
      //查询当前部门下标
      int selected = list.indexWhere((element) {
        return element.name == userInfo?.departmentName;
      });
      //创建选择器控制器
      var controller = FixedExtentScrollController(
        initialItem: selected < 0 ? 0 : selected,
      );
      //创建取消按钮
      var cancel = TextButton(
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
      );
      //创建确认按钮
      var confirm = TextButton(
        onPressed: () {
          Get.back();
          //修改部门
          httpGet(
            loading: 'modifying_group'.tr,
            method: webApiChangeDepartment,
            params: {
              'EmpID': userInfo!.empID,
              'OrganizeID': userInfo!.organizeID,
              'DeptmentID': list[controller.selectedItem].itemID,
            },
          ).then((changeDepartmentCallback) {
            if (changeDepartmentCallback.resultCode == resultSuccess) {
              var json = jsonDecode(changeDepartmentCallback.data);
              //修改用户数据中的部门数据
              userInfo?.departmentID = json['DeptmentID'];
              userInfo?.departmentName = json['DeptmentName'];
              spSave(spSaveUserInfo, jsonEncode(userInfo));
              state.departmentName.value = userInfo?.departmentName ?? '';
            } else {
              errorDialog(
                content: changeDepartmentCallback.message,
              );
            }
          });
        },
        child: Text(
          'dialog_default_confirm'.tr,
          style: const TextStyle(
            color: Colors.blueAccent,
            fontSize: 20,
          ),
        ),
      );
      //创建底部弹窗
      showPopup(Column(
        children: <Widget>[
          //选择器顶部按钮
          Container(
            height: 45,
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [cancel, confirm],
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
    } else {
      errorDialog(content: departmentCallback.message);
    }
  }

  ///修改密码弹窗
  void changePasswordDialog() {
    TextEditingController oldPassword = TextEditingController();
    TextEditingController newPassword = TextEditingController();
    showCupertinoModalPopup<void>(
      context: Get.overlayContext!,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () {
              Get.back();
            },
            child: Text('dialog_default_cancel'.tr,style: const TextStyle(color: Colors.grey),),
          ),
          TextButton(
            onPressed: () {
              if (oldPassword.text.isEmpty) {
                errorDialog(content: 'change_password_dialog_old_password'.tr);
                return;
              }
              if (oldPassword.text.md5Encode().toUpperCase() !=
                  userInfo!.passWord) {
                errorDialog(
                    content: 'change_password_dialog_old_password_error'.tr);
                return;
              }
              if (newPassword.text.isEmpty) {
                errorDialog(content: 'change_password_dialog_new_password'.tr);
                return;
              }

              var phone = '';
              switch (spGet(spSaveLoginType)) {
                case loginTypePhone:
                  phone = spGet(spSaveLoginPhone);
                  break;
                case loginTypeFace:
                  phone = spGet(spSaveLoginFace);
                  break;
              }
              httpPost(
                loading: 'change_password_dialog_submitting'.tr,
                method: webApiChangePassword,
                params: {
                  'OldPassWord': oldPassword,
                  'NewPassWord': newPassword,
                  'PhoneNumber': phone
                },
              ).then((changePasswordCallback) {
                if (changePasswordCallback.resultCode == resultSuccess) {
                  informationDialog(
                      content: changePasswordCallback.message,
                      back: () {
                        Get.back();
                      });
                } else {
                  errorDialog(content: changePasswordCallback.message);
                }
              });
            },
            child: Text('change_password_dialog_submit'.tr),
          ),
        ],
      ),
    );
  }
}
