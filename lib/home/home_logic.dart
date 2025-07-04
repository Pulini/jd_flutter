import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/department_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'home_state.dart';

class HomeLogic extends GetxController {
  final HomeState state = HomeState();

  //用户头像
  late Widget userAvatar;

  @override
  void onInit() {
    super.onInit();
    userAvatar = Obx(
          () =>
      state.userPicUrl.value.isEmpty
          ? const Icon(Icons.flutter_dash, color: Colors.white)
          : AspectRatio(
        aspectRatio: 1 / 1,
        child: ClipOval(
          child: Image.network(
            userInfo!.picUrl!,
            cacheHeight:200,
            cacheWidth: 200,
            errorBuilder: (ctx, err, st) =>
                Image.asset(
                  'assets/images/ic_logo.png',
                  color: Colors.blue,
                ),
          ),
        ),
      ),
    );
  }

  refreshFunList() {
    state.refreshFunList(
      success: () => refreshButton(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  search(String text) {
    state.search = text;
    refreshButton();
  }

  navigationBarClick(int index) {
    state.nBarIndex = index;
    refreshButton();
  }

  refreshButton() {
    var list = <ButtonItem>[];
    if (state.search.isEmpty) {
      list.addAll(
        functions.where((v) =>
        v.classify == state.navigationBar[state.nBarIndex].className),
      );
    } else {
      var bi = <ButtonItem>[];
      for (var fun in functions) {
        if (fun is HomeButtonGroup) {
          bi.addAll(fun.functionGroup);
        } else {
          bi.add(fun);
        }
      }
      list.addAll(
        bi.where((v) =>
        v.name.toUpperCase().contains(state.search.toUpperCase()) ||
            v.description.toUpperCase().contains(state.search.toUpperCase())),
      );
    }
    state.buttons.value = list;
  }

  //底部弹窗
  takeAvatarPhoto() {
    takePhoto(callback: (f) {
      state.changeUserAvatar(
        file: f,
        success: (s) =>
            showSnackBar(
              title: 'home_user_setting_avatar_photo_sheet_title'.tr,
              message: s,
            ),
        error: (s) => errorDialog(content: s),
      );
    }, title: 'home_user_setting_avatar_photo_sheet_title'.tr);
  }

  //部门列表弹窗
  getDepartment(Function(List<Department> list, int index) callback) {
    state.getDepartment(
      success: (list) {
        //查询当前部门下标
        int selected = list.indexWhere((element) {
          return element.name == userInfo?.departmentName;
        });
        if (selected < 0) selected = 0;
        callback.call(list, selected);
      },
      error: (s) => errorDialog(content: s),
    );
  }

  changeDepartment(Department data) {
    state.changeDepartment(
      departmentID: data.itemID ?? 0,
      success: () => Get.back(),
      error: (s) => errorDialog(content: s),
    );
  }

  changePassword(String oldPassword, String newPassword) {
    if (oldPassword.isEmpty) {
      errorDialog(content: 'change_password_dialog_old_password'.tr);
      return;
    }
    if (oldPassword.md5Encode().toUpperCase() != userInfo!.passWord) {
      errorDialog(content: 'change_password_dialog_old_password_error'.tr);
      return;
    }
    if (newPassword.isEmpty) {
      errorDialog(content: 'change_password_dialog_new_password'.tr);
      return;
    }
    var account = '';
    switch (spGet(spSaveLoginType)) {
      case spSaveLoginTypePhone:
        account = spGet(spSaveLoginPhone);
        break;
      case spSaveLoginTypeFace:
        account = spGet(spSaveLoginFace);
        break;
      case spSaveLoginTypeWorkNumber:
        account = spGet(spSaveLoginWork);
        break;
      case spSaveLoginTypeMachine:
        account = spGet(spSaveLoginMachine);
        break;
    }
    state.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      account: account,
      success: (msg) => successDialog(content: msg, back: () => Get.back()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
