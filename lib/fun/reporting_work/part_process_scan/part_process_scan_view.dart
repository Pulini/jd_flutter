import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'part_process_scan_logic.dart';

class PartProcessScanPage extends StatefulWidget {
  const PartProcessScanPage({super.key});

  @override
  State<PartProcessScanPage> createState() => _PartProcessScanPageState();
}

class _PartProcessScanPageState extends State<PartProcessScanPage> {
  final logic = Get.put(PartProcessScanLogic());
  final state = Get.find<PartProcessScanLogic>().state;
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.addBarCode(code: code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: 'part_process_scan_clean_tips'.tr,
            confirm: () => state.barCodeList.clear(),
          ),
          child: Text(
            'part_process_scan_clean'.tr,
            style: const TextStyle(color: Colors.blueAccent),
          ),
        ),
      ],
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => scannerDialog(
                  detect: (code) => logic.addBarCode(code: code),
                ),
                icon: const Icon(
                  Icons.qr_code_scanner,
                  size: 40,
                ),
              ),
              Expanded(child: EditText(controller: controller)),
              IconButton(
                onPressed: () => logic.addBarCode(
                  code: controller.text,
                  callback: () => controller.clear(),
                ),
                icon: const Icon(
                  Icons.add_box_rounded,
                  size: 40,
                ),
              )
            ],
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.barCodeList.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(state.barCodeList[index])),
                        IconButton(
                          onPressed: () => askDialog(
                            content: 'part_process_scan_delete_tips'.tr,
                            confirm: () => logic.deleteItem(index),
                          ),
                          icon: const Icon(
                            Icons.delete_forever,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: 'part_process_scan_modify'.tr,
                  click: () => logic.barCodeModify(),
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'part_process_scan_submit'.tr,
                  click: () {},
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartProcessScanLogic>();
    super.dispose();
  }
}
