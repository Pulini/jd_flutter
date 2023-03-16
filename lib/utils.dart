//隐藏键盘而不丢失文本字段焦点：
import 'package:flutter/services.dart';

void hideKeyBoard() {
  SystemChannels.textInput.invokeMethod('TextInput.hide');
}