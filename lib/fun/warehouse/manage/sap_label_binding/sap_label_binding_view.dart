import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/sap_label_binding_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_label_binding/sap_label_binding_dialog.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_label_binding_logic.dart';
import 'sap_label_binding_state.dart';

class SapLabelBindingPage extends StatefulWidget {
  const SapLabelBindingPage({super.key});

  @override
  State<SapLabelBindingPage> createState() => _SapLabelBindingPageState();
}

class _SapLabelBindingPageState extends State<SapLabelBindingPage> {
  final SapLabelBindingLogic logic = Get.put(SapLabelBindingLogic());
  final SapLabelBindingState state = Get.find<SapLabelBindingLogic>().state;
  PrintUtil pu=PrintUtil();

  Widget _item(List<SapLabelBindingInfo> labelList) {
    SapLabelBindingInfo? boxLabel;
    try {
      boxLabel = labelList.firstWhere((v) => v.isBoxLabel);
    } on StateError catch (_) {}
    var subItems = labelList.where((v) => !v.isBoxLabel).isEmpty
        ? Container()
        : Container(
            padding: const EdgeInsets.only(left: 10),
            margin: EdgeInsets.only(bottom: boxLabel == null ? 10 : 0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.circular(boxLabel == null ? 10 : 8),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var sub in labelList.where((v) => !v.isBoxLabel)) ...[
                  Row(
                    children: [
                      expandedTextSpan(hint: '件号：', text: sub.pieceNo ?? ''),
                      IconButton(
                        onPressed: () => askDialog(
                            content: '确定要删除标签吗？',
                            confirm: () => logic.deleteLabel(sub)),
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                  if (labelList.last != sub) const Divider(),
                ],
              ],
            ),
          );
    if (boxLabel == null) {
      return subItems;
    } else {
      return Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue.shade200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                expandedTextSpan(hint: '外箱标件号：', text: boxLabel.pieceNo ?? ''),
                IconButton(
                  onPressed: () => askDialog(
                    content: '确定要删除标签吗？',
                    confirm: () => logic.deleteLabel(boxLabel!),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                )
              ],
            ),
            subItems
          ],
        ),
      );
    }
  }


  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanLabel(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        // CombinationButton(
        //   text: 'add',
        //   click: () => logic.scanLabel('00505685E5761FE090E58AE9B8A5E489'),
        // ),
        Obx(() => state.newBoxLabelID.value.isEmpty
            ? Container()
            : CombinationButton(
                combination: Combination.left,
                text: '打印新外箱标',
                click: () => logic.printNewBoxLabel(),
              )),
        Obx(() =>
            state.operationTypeText.value == ScanLabelOperationType.unKnown.text
                ? Container()
                : CombinationButton(
                    combination: state.newBoxLabelID.value.isNotEmpty
                        ? Combination.right
                        : Combination.intact,
                    text: state.operationTypeText.value,
                    click: () => modifyBoxInfo(
                      operationType: state.operationType,
                      targetBoxLabel: logic.getTargetBoxLabel(),
                      modify: (long, width, height, outWeight) =>
                          logic.operationSubmit(
                        long: long,
                        width: width,
                        height: height,
                        outWeight: outWeight,
                      ),
                    ),
                  )),
      ],
      body: Obx(() {
        var list = logic.getLabelList();
        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: list.length,
          itemBuilder: (c, i) => _item(list[i]),
        );
      }),
    );
  }

  @override
  void dispose() {
    Get.delete<SapLabelBindingLogic>();
    super.dispose();
  }
}
