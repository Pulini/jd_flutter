import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:jd_flutter/login/User_info.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/generated/l10n.dart';

/// 手机号码登录
phoneLogin(BuildContext context, String phone, String password, String code,
    {required Function(UserInfo) back}) async {
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

  hideKeyBoard();
  loadingDialog(context, S.current.logging);
  httpPost(webApiLogin, query: {
    "JiGuangID": "",
    "Phone": phone,
    "Password": password,
    "VCode": code,
    "Type": 0,
    "FaceLogin": false,
  }, callBack: (code, data, msg) {
    Navigator.pop(context);
    if (code == resultSuccess) {
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
