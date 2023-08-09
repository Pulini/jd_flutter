import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/http/request/user_avatar_entity.dart';
import 'package:jd_flutter/http/response/department_entity.dart';
import 'package:jd_flutter/http/response/group_entity.dart';
import 'package:jd_flutter/http/response/user_info.dart';
import 'package:jd_flutter/http/response/version_info_entity.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constant.dart';


/// 手机号码登录
phoneLogin(BuildContext context, String phone, String password, String code,
    {required Function(UserInfo) back}) {
  hideKeyBoard();
  if (phone.isEmpty) {
    errorDialog(context, content: 'login_tips_phone'.tr);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: 'login_tips_password'.tr);
    return;
  }
  if (code.isEmpty) {
    errorDialog(context, content: 'login_tips_verify_code'.tr);
    return;
  }
  loadingDialog(context, 'logging'.tr);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": phone,
    "Password": password,
    "VCode": code,
    "Type": 0,
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypePhone);
      spSave(spSaveLoginPhone, phone);
      spSave(spSaveUserInfo, data.toString());
      var user = UserInfo.fromJson(jsonDecode(data));
      userController.init(user);
      back.call(user);
    } else {
      errorDialog(context, content: msg ?? 'login_failed'.tr);
    }
  });
}

///获取验证码
getVerifyCode(BuildContext context, String account,
    {required Function() sendSuccess}) {
  loadingDialog(context, 'phone_login_getting_verify_code'.tr);
  httpPost(webApiVerificationCode, query: {"phone": account},
      callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      informationDialog(context,
          content: 'phone_login_get_verify_code_success'.tr);
      sendSuccess.call();
    } else {
      errorDialog(context,
          content: msg ?? 'phone_login_get_verify_code_failed'.tr);
    }
  });
}

///根据手机号码获取用户头像
getUserPhotoPath(BuildContext context, String phone, Function(String) url) {
  if (phone.isEmpty) {
    errorDialog(context, content: 'login_tips_phone'.tr);
    return;
  }
  loadingDialog(context, 'face_login_getting_photo_path'.tr);
  httpGet(webApiGetUserPhoto, query: {"Phone": phone},
      callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      url.call(data.toString().replaceAll("\"", ""));
    } else {
      errorDialog(context,
          content: msg ?? 'face_login_get_photo_path_failed'.tr);
    }
  });
}

///人脸登录
faceLogin(BuildContext context, String phone,
    {required Function(UserInfo) back}) {
  loadingDialog(context, 'logging'.tr);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": phone,
    "Password": "",
    "VCode": "",
    "Type": 2,
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeFace);
      spSave(spSaveLoginFace, phone);
      spSave(spSaveUserInfo, data.toString());
      var user = UserInfo.fromJson(jsonDecode(data));
      userController.init(user);
      back.call(user);
    } else {
      errorDialog(context, content: msg ?? 'login_failed'.tr);
    }
  });
}

///机台账号登录
machineLogin(BuildContext context, String machineNumber, String password,
    {required Function(UserInfo) back}) {
  hideKeyBoard();
  if (machineNumber.isEmpty) {
    errorDialog(context, content: 'login_tips_machine'.tr);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: 'login_tips_password'.tr);
    return;
  }
  loadingDialog(context, 'logging'.tr);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": machineNumber,
    "Password": password,
    "VCode": "",
    "Type": 1,
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeMachine);
      spSave(spSaveLoginMachine, machineNumber);
      spSave(spSaveUserInfo, data.toString());
      var user = UserInfo.fromJson(jsonDecode(data));
      userController.init(user);
      back.call(user);
    } else {
      errorDialog(context, content: msg ?? 'login_failed'.tr);
    }
  });
}

///工号登录
workNumberLogin(BuildContext context, String workNumber, String password,
    {required Function(UserInfo) back}) {
  hideKeyBoard();
  if (workNumber.isEmpty) {
    errorDialog(context, content: 'login_tips_work_number'.tr);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: 'login_tips_password'.tr);
    return;
  }
  loadingDialog(context, 'logging'.tr);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": workNumber,
    "Password": password,
    "VCode": "",
    "Type": 3,
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeMachine);
      spSave(spSaveLoginWork, workNumber);
      spSave(spSaveUserInfo, data.toString());
      var user = UserInfo.fromJson(jsonDecode(data));
      userController.init(user);
      back.call(user);
    } else {
      errorDialog(context, content: msg ?? 'login_failed'.tr);
    }
  });
}

///修改头像
changeUserAvatar(BuildContext context, String photoBase64,
    {required Function() back}) {
  loadingDialog(context, 'home_user_setting_avatar_photo_submitting'.tr);

  var body = UserAvatarEntity()
    ..empID = userController.user.value!.empID!
    ..userID = userController.user.value!.userID!
    ..imageBase64 = photoBase64;
  httpPost(webApiChangeUserAvatar, body: body, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      back.call();
    } else {
      errorDialog(context, content: msg);
    }
  });
}

///修改密码
changePassword(BuildContext context, String oldPassword, String newPassword,
    {required Function(String) back}) {
  loadingDialog(context, 'change_password_dialog_submitting'.tr);
  var phone = "";

  switch (spGet(spSaveLoginType)) {
    case loginTypePhone:
      phone = spGet(spSaveLoginPhone);
      break;
    case loginTypeFace:
      phone = spGet(spSaveLoginFace);
      break;
  }
  httpPost(webApiChangePassword, query: {
    "OldPassWord": oldPassword,
    "NewPassWord": newPassword,
    "PhoneNumber": phone
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      back.call(data.toString());
    } else {
      errorDialog(context, content: msg);
    }
  });
}

///获取部门组别列表
getDepartmentGroupList(BuildContext context,
    {required Function(List<GroupEntity>) back}) {
  loadingDialog(context, 'getting_group'.tr);
  httpGet(webApiGetDepartment,
      query: {"EmpID": userController.user.value!.empID},
      callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      List<GroupEntity> list = [];
      for (var item in jsonDecode(data)) {
        list.add(GroupEntity.fromJson(item));
      }
      back.call(list);
    } else {
      errorDialog(context, content: msg);
    }
  });
}

///修改部门组别
changeDepartmentGroup(BuildContext context, String departmentID) {
  loadingDialog(context, 'modifying_group'.tr);
  httpGet(webApiChangeDepartment, query: {
    "EmpID": userController.user.value!.empID,
    "OrganizeID": userController.user.value!.organizeID,
    "DeptmentID": departmentID
  }, callBack: (code, data, msg) {
    Get.back();
    if (code == resultSuccess) {
      var department = DepartmentEntity.fromJson(jsonDecode(data));
      userController.user.value!.departmentID = department.deptmentID;
      userController.user.value!.departmentName = department.deptmentName;
      userController.user.update((val) => userController.user.value!);
      spSave(spSaveUserInfo, jsonEncode(userController.user.value));
    } else {
      errorDialog(context, content: msg);
    }
  });
}

///获取服务器版本信息
getVersionInfo(BuildContext context, bool isShowLoading,
    {Function()? noUpdate, required Function(VersionInfoEntity) needUpdate}) {
  if (isShowLoading) loadingDialog(context, 'checking_version'.tr);
  httpGet(webApiCheckVersion, callBack: (code, data, msg) {
    if (isShowLoading) Get.back();
    if (code == resultSuccess) {
      PackageInfo.fromPlatform().then((value) {
        logger.f(value);
        var versionInfo = VersionInfoEntity.fromJson(jsonDecode(data));
        // versionInfo.versionName = "2.0.0";
        // versionInfo.force = false;
        if (value.version == versionInfo.versionName) {
          noUpdate?.call();
        } else {
          needUpdate.call(versionInfo);
        }
      });
    } else {
      errorDialog(context, content: msg);
    }
  });
}
