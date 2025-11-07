import 'package:get/get.dart';

import 'message_info.dart';

class MessageCenterState {
  var messageList=<MessageInfo>[].obs;
  MessageCenterState() {
    MessageInfo.getSave(callback: (list)=>messageList.value=list);
  }
}
