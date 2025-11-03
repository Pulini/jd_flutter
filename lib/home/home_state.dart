import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/department_info.dart';
import 'package:jd_flutter/bean/http/response/home_function_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/translation.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class HomeState {

  var userPicUrl = ''.obs;
  var departmentName = ''.obs;
  var language = ''.obs;
  String search = '';
  var nBarIndex = 0;
  var buttons = <ButtonItem>[].obs;
  var selectedItemColor = Colors.white;
  var navigationBar = <HomeFunctions>[].obs;

  HomeState() {
    userPicUrl.value = userInfo?.picUrl ?? '';
    departmentName.value = userInfo?.departmentName ?? '';
    refreshLanguage();
  }
  refreshLanguage() {
    language.value=languages[locales.indexWhere((v)=>v.languageCode==Get.locale!.languageCode)];
  }

  getMenuFunction({
    required Function(dynamic) success,
    required Function(String) error,
  }) {
    httpGet(
      method: webApiGetMenuFunction,
      params: {'empID': userInfo?.empID, 'userID': userInfo?.userID},
    ).then((response) async {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
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
    required String account,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'change_password_dialog_submitting'.tr,
      method: webApiChangePassword,
      params: {
        'OldPassWord': oldPassword,
        'NewPassWord': newPassword,
        'PhoneNumber': account
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
