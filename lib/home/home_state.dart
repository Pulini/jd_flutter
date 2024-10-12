import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bean/home_button.dart';
import '../bean/http/response/department_info.dart';
import '../bean/http/response/home_function_info.dart';
import '../constant.dart';
import '../route.dart';
import '../utils/utils.dart';
import '../utils/web_api.dart';

class HomeState {
  var userPicUrl = ''.obs;
  var departmentName = ''.obs;
  String search = '';
  var nBarIndex = 0;
  RxList<ButtonItem> buttons = <ButtonItem>[].obs;
  var selectedItemColor = Colors.white;
  var navigationBar = <HomeFunctions>[].obs;

  HomeState() {
    userPicUrl.value = userInfo?.picUrl ?? '';
    departmentName.value = userInfo?.departmentName ?? '';
  }

  refreshFunList({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMenuFunction,
      params: {'empID': userInfo?.empID ?? 0},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        _formatButtonData([
          for (var item in response.data) HomeFunctions.fromJson(item),
        ]);
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  _formatButtonData(List<HomeFunctions> list) {
    functions.clear();
    for (var navigation in list) {
      var list = <ButtonItem>[];
      for (var fun in navigation.subFunctions ?? <SubFunctions>[]) {
        if (fun.functionGroup != null && fun.functionGroup!.length>1) {
          list.add(HomeButtonGroup(
            name: fun.name ?? '',
            description: fun.description ?? '',
            classify: navigation.className ?? '',
            icon: fun.icon ?? '',
            functionGroup: [
              for (var sub in fun.functionGroup!)
                HomeButton(
                  name: sub.name ?? '',
                  description: sub.description ?? '',
                  classify: navigation.className ?? '',
                  icon: sub.icon ?? '',
                  id: sub.id ?? 0,
                  // version: sub.version ?? 0,
                  version: 98,
                  route: sub.routeSrc ?? '',
                  // hasPermission: sub.hasPermission ?? false,
                  hasPermission: true,
                )
            ],
          ));
        } else {
          list.add(HomeButton(
            name: fun.functionGroup![0].name ?? '',
            description: fun.functionGroup![0].description ?? '',
            classify: navigation.className ?? '',
            icon: fun.functionGroup![0].icon ?? '',
            id: fun.functionGroup![0].id ?? 0,
            // version: fun.functionGroup![0].version ?? 0,
            version: 98,
            route: fun.functionGroup![0].routeSrc ?? '',
            // hasPermission: fun.functionGroup![0].hasPermission ?? false,
            hasPermission: true,
          ));
        }
      }
      functions.addAll(list);
    }
    nBarIndex = 0;
    navigationBar.value = [
      for (var b in list)
        HomeFunctions(
          className: b.className,
          backGroundColor: b.backGroundColor,
          fontColor: b.fontColor,
          icon: b.icon,
        )
    ];
  }

  changeUserAvatar({
    required File file,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'home_user_setting_avatar_photo_submitting'.tr,
      method: webApiChangeUserAvatar,
      body: {
        'imageBase64': File(file.path).toBase64(),
        'empID': userInfo!.empID!,
        'userID': userInfo!.userID!,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getDepartment({
    required Function(List<Department> dep) success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'getting_group'.tr,
      method: webApiPickerSapGroup,
      params: {'EmpID': userInfo!.empID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call([for (var item in response.data) Department.fromJson(item)]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  changeDepartment({
    required int departmentID,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'modifying_group'.tr,
      method: webApiChangeDepartment,
      params: {
        'EmpID': userInfo!.empID,
        'OrganizeID': userInfo!.organizeID,
        'DeptmentID': departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        //修改用户数据中的部门数据
        userInfo?.departmentID = response.data['DeptmentID'];
        userInfo?.departmentName = response.data['DeptmentName'];
        spSave(spSaveUserInfo, jsonEncode(userInfo));
        departmentName.value = userInfo?.departmentName ?? '';
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  changePassword({
    required String oldPassword,
    required String newPassword,
    required String phone,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'change_password_dialog_submitting'.tr,
      method: webApiChangePassword,
      params: {
        'OldPassWord': oldPassword,
        'NewPassWord': newPassword,
        'PhoneNumber': phone
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
