import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'part_label_manage_logic.dart';
import 'part_label_manage_state.dart';

class PartLabelManagePage extends StatefulWidget {
  const PartLabelManagePage({super.key});

  @override
  State<PartLabelManagePage> createState() => _PartLabelManagePageState();
}

class _PartLabelManagePageState extends State<PartLabelManagePage> {
  final PartLabelManageLogic logic = Get.put(PartLabelManageLogic());
  final PartLabelManageState state = Get.find<PartLabelManageLogic>().state;

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.queryLabels(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        // IconButton(
        //   onPressed: () =>
        //       logic.queryLabels('570DA244-DCF4-469A-A59C-42987FA06F31'),
        //   icon: Icon(Icons.label),
        // ),
        IconButton(
          onPressed: () => scannerDialog(
            detect: (code) => logic.queryLabels(code),
          ),
          icon: const Icon(Icons.qr_code_scanner, color: Colors.blue),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding:
                      const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                  itemCount: state.labelList.length,
                  itemBuilder: (c, i) => UnconstrainedBox(
                      child: _LabelItem(label: state.labelList[i])),
                )),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      text: 'part_label_manage_print'.tr,
                      isEnabled: logic.printIsEnabled(),
                      combination: Combination.left,
                      click: () => logic.printLabel(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      text: 'part_label_manage_split'.tr,
                      isEnabled: logic.splitIsEnabled(),
                      combination: Combination.middle,
                      backgroundColor: Colors.deepOrangeAccent,
                      click: () => inputSplitQtyDialog(
                        label: state.labelList
                            .firstWhere((v) => v.isSelected.value),
                        split: (label, qty) => logic.splitLabel(label, qty),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      text: 'part_label_manage_merge'.tr,
                      isEnabled: logic.mergeIsEnabled(),
                      combination: Combination.right,
                      backgroundColor: Colors.green,
                      click: () => askDialog(
                        content: 'part_dispatch_merge_label_tips'.tr,
                        confirm: () => logic.mergeLabel(),
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PartLabelManageLogic>();
    super.dispose();
  }
}

class _LabelItem extends StatelessWidget {
  final PartLabelInfo label;

  const _LabelItem({required this.label});

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => label.isSelected.value = !label.isSelected.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(
                color: label.isSelected.value ? Colors.green : Colors.grey,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(10),
              color: label.isSelected.value
                  ? Colors.green.shade200
                  : Colors.grey.shade200,
            ),
            child: createPartLabel(label),
          ),
        ));
  }
}
