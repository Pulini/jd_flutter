import 'package:get/get.dart';
import 'package:jd_flutter/message_center/message_info.dart';

import 'message_center_state.dart';

class MessageCenterLogic extends GetxController {
  final MessageCenterState state = MessageCenterState();

  void cleanMessage() {
    MessageInfo.clean(callback: (v) => state.messageList.clear());
  }

  void deleteItem(int i) {
    state.messageList[i].delete(callback: () => state.messageList.removeAt(i));
  }
}
