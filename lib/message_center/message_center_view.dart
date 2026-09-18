import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'message_center_logic.dart';
import 'message_center_state.dart';

class MessageCenterPage extends StatefulWidget {
  const MessageCenterPage({super.key});

  @override
  State<MessageCenterPage> createState() => _MessageCenterPageState();
}

class _MessageCenterPageState extends State<MessageCenterPage> {
  final MessageCenterLogic logic = Get.put(MessageCenterLogic());
  final MessageCenterState state = Get.find<MessageCenterLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'message_center_title'.tr,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.cleaning_services,
            color: Colors.red,
          ),
          onPressed: () => askDialog(
            content: 'message_center_clear_all_confirm'.tr,
            confirm: () => logic.cleanMessage(),
          ),
        ),
      ],
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: state.messageList.length,
            itemBuilder: (c, i) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(
                  Radius.circular(10),
                ),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              child: ListTile(
                title: Text(state.messageList[i].message ?? ''),
                subtitle: Text(state.messageList[i].getPushTime()),
                trailing: IconButton(
                  onPressed: () => askDialog(
                    content: 'message_center_delete_confirm'.tr,
                    confirm: () => logic.deleteItem(i),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<MessageCenterLogic>();
    super.dispose();
  }
}
