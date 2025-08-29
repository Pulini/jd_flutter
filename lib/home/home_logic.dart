import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/department_info.dart';
import 'package:jd_flutter/bean/http/response/home_function_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
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
      () => state.userPicUrl.value.isEmpty
          ? const Icon(Icons.flutter_dash, color: Colors.white)
          : AspectRatio(
              aspectRatio: 1 / 1,
              child: ClipOval(
                child: Image.network(
                  userInfo!.picUrl!,
                  cacheHeight: 200,
                  cacheWidth: 200,
                  errorBuilder: (ctx, err, st) => Image.asset(
                    'assets/images/ic_logo.png',
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
    );
  }

  refreshFunList(Function()finish) {
    state.getMenuFunction(success: (json) async {
      spSave(spSaveMenuInfo, textToKey(json.toString()));
      functions = await _jsonToMenuFunction(json);
      finish.call();
      refreshButton();
    }, error: (msg) {
      finish.call();
      errorDialog(content: msg);
    });
  }

  checkFunctionVersion() {
    state.getMenuFunction(
      success: (json) async {
        var menuKey = textToKey(json.toString());
        var saveKey = spGet(spSaveMenuInfo);
        logger.f('Menu Key=$menuKey  Save Key=$saveKey  ${menuKey == saveKey}');
        if (menuKey != saveKey) {
          spSave(spSaveMenuInfo, menuKey);
          functions = await _jsonToMenuFunction(json);
          refreshButton();
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  Future<List<ButtonItem>> _jsonToMenuFunction(dynamic json) async {
    var list = await compute(
      parseJsonToList<HomeFunctions>,
      ParseJsonParams(
        json,
        HomeFunctions.fromJson,
      ),
    );
    var navigationSize = state.navigationBar.length;
    state.navigationBar.value = [
      for (var b in list)
        HomeFunctions(
          className: b.className,
          backGroundColor: b.backGroundColor,
          fontColor: b.fontColor,
          icon: b.icon,
        )
    ];
    if (navigationSize != state.navigationBar.length) {
      state.nBarIndex = 0;
    }
    return formatButton(list);
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
    takePhoto(
        callback: (f) {
          state.changeUserAvatar(
            file: f,
            success: (s) => showSnackBar(
              title: 'home_user_setting_avatar_photo_sheet_title'.tr,
              message: s,
            ),
            error: (s) => errorDialog(content: s),
          );
        },
        title: 'home_user_setting_avatar_photo_sheet_title'.tr);
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
