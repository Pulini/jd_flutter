import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

//隐藏键盘而不丢失文本字段焦点：
void hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}

const languageZh=Locale("zh","CN");
const languageEn=Locale("en");

Future<Locale> getLanguage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? language = prefs.get("language") as String?;
  if (language == null) {
    return languageZh;
  } else {
    switch (language) {
      case "zh":
        return languageZh;
      case "en":
        return languageEn;
      default:
        return languageZh;
    }
  }
}
saveLanguage(String language) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("language", language);
}