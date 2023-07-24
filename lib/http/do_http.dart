import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/generated/l10n.dart';
import 'package:jd_flutter/http/request/user_avatar_entity.dart';
import 'package:jd_flutter/http/response/department_entity.dart';
import 'package:jd_flutter/http/response/group_entity.dart';
import 'package:jd_flutter/http/response/user_info.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../constant.dart';

/// 手机号码登录
phoneLogin(BuildContext context, String phone, String password, String code,
    {required Function(UserInfo) back}) async {
  hideKeyBoard();
  if (phone.isEmpty) {
    errorDialog(context, content: S.current.login_tips_phone);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: S.current.login_tips_password);
    return;
  }
  if (code.isEmpty) {
    errorDialog(context, content: S.current.login_tips_verify_code);
    return;
  }
  loadingDialog(context, S.current.logging);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": phone,
    "Password": password,
    "VCode": code,
    "Type": 0,
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypePhone);
      spSave(spSaveLoginPhone, phone);
      spSave(spSaveUserInfo, data.toString());
      back.call(UserInfo.fromJson(jsonDecode(data)));
    } else {
      errorDialog(context, content: msg ?? S.current.login_failed);
    }
  });
}

///获取验证码
getVerifyCode(BuildContext context, String account,
    {required Function() sendSuccess}) async {
  loadingDialog(context, S.current.phone_login_getting_verify_code);
  httpPost(webApiVerificationCode, query: {"phone": account},
      callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      informationDialog(context,
          content: S.current.phone_login_get_verify_code_success);
      sendSuccess.call();
    } else {
      errorDialog(context,
          content: msg ?? S.current.phone_login_get_verify_code_failed);
    }
  });
}

///根据手机号码获取用户头像
getUserPhotoPath(BuildContext context, String phone, Function(String) url) {
  if (phone.isEmpty) {
    errorDialog(context, content: S.current.login_tips_phone);
    return;
  }
  loadingDialog(context, S.current.face_login_getting_photo_path);
  httpGet(webApiGetUserPhoto, query: {"Phone": phone},
      callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      url.call(data.toString().replaceAll("\"", ""));
    } else {
      errorDialog(context,
          content: msg ?? S.current.face_login_get_photo_path_failed);
    }
  });
}

///人脸登录
faceLogin(BuildContext context, String phone,
    {required Function(UserInfo) back}) async {
  loadingDialog(context, S.current.logging);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": phone,
    "Password": "",
    "VCode": "",
    "Type": 2,
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeFace);
      spSave(spSaveLoginFace, phone);
      spSave(spSaveUserInfo, data.toString());
      back.call(UserInfo.fromJson(jsonDecode(data)));
    } else {
      errorDialog(context, content: msg ?? S.current.login_failed);
    }
  });
}

///机台账号登录
machineLogin(BuildContext context, String machineNumber, String password,
    {required Function(UserInfo) back}) async {
  hideKeyBoard();
  if (machineNumber.isEmpty) {
    errorDialog(context, content: S.current.login_tips_machine);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: S.current.login_tips_password);
    return;
  }
  loadingDialog(context, S.current.logging);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": machineNumber,
    "Password": password,
    "VCode": "",
    "Type": 1,
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeMachine);
      spSave(spSaveLoginMachine, machineNumber);
      spSave(spSaveUserInfo, data.toString());
      back.call(UserInfo.fromJson(jsonDecode(data)));
    } else {
      errorDialog(context, content: msg ?? S.current.login_failed);
    }
  });
}

///工号登录
workNumberLogin(BuildContext context, String workNumber, String password,
    {required Function(UserInfo) back}) async {
  hideKeyBoard();
  if (workNumber.isEmpty) {
    errorDialog(context, content: S.current.login_tips_work_number);
    return;
  }
  if (password.isEmpty) {
    errorDialog(context, content: S.current.login_tips_password);
    return;
  }
  loadingDialog(context, S.current.logging);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": workNumber,
    "Password": password,
    "VCode": "",
    "Type": 3,
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      spSave(spSaveLoginType, loginTypeMachine);
      spSave(spSaveLoginWork, workNumber);
      spSave(spSaveUserInfo, data.toString());
      back.call(UserInfo.fromJson(jsonDecode(data)));
    } else {
      errorDialog(context, content: msg ?? S.current.login_failed);
    }
  });
}

///修改头像
changeUserAvatar(BuildContext context, String photoBase64,
    {required Function(String) back}) async {
  loadingDialog(context, S.current.home_user_setting_avatar_photo_submitting);
  userInfo().then((user) {
    var body = UserAvatarEntity()
      ..empID = user.empID!
      ..userID = user.userID!
      ..imageBase64 = photoBase64;
    httpPost(webApiChangeUserAvatar, body: body, callBack: (code, data, msg) {
      Navigator.pop(context);
      if (code == resultSuccess) {
        back.call(data.toString());
      } else {
        errorDialog(context, content: msg);
      }
    });
  });
}

///修改密码
changePassword(BuildContext context, String oldPassword, String newPassword,
    {required Function(String) back}) async {
  loadingDialog(context, S.current.change_password_dialog_submitting);
  var phone = "";
  String type = await spGet(spSaveLoginType);
  switch (type) {
    case loginTypePhone:
      phone = await spGet(spSaveLoginPhone);
      break;
    case loginTypeFace:
      phone = await spGet(spSaveLoginFace);
      break;
  }
  httpPost(webApiChangePassword, query: {
    "OldPassWord": oldPassword,
    "NewPassWord": newPassword,
    "PhoneNumber": phone
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
      back.call(data.toString());
    } else {
      errorDialog(context, content: msg);
    }
  });
}

///获取部门组别列表
getDepartmentGroupList(BuildContext context,
    {required Function(List<GroupEntity>) back}) async {
  loadingDialog(context, S.current.getting_group);
  userInfo().then((user) => httpGet(webApiGetDepartment,
          query: {"EmpID": user.empID}, callBack: (code, data, msg) {
        Navigator.pop(context);
        if (code == resultSuccess) {
          List<GroupEntity> list = [];
          for (var item in jsonDecode(data)) {
            list.add(GroupEntity.fromJson(item));
          }
          back.call(list);
        } else {
          errorDialog(context, content: msg);
        }
      }));
}

///修改部门组别
changeDepartmentGroup(BuildContext context, String departmentID,
    {required Function() back}) async {
  loadingDialog(context, S.current.modifying_group);
  userInfo().then((user) => httpGet(webApiChangeDepartment, query: {
        "EmpID": user.empID,
        "OrganizeID": user.organizeID,
        "DeptmentID": departmentID
      }, callBack: (code, data, msg) {
        Navigator.pop(context);
        if (code == resultSuccess) {
          back.call();
          var department = DepartmentEntity.fromJson(jsonDecode(data));
          user.departmentID = department.deptmentID;
          user.departmentName = department.deptmentName;
          spSave(spSaveUserInfo, jsonEncode(user));
        } else {
          errorDialog(context, content: msg);
        }
      }));
}
