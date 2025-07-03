import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_carton_label_binding/sap_carton_label_binding_dialog.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_carton_label_binding_logic.dart';
import 'sap_carton_label_binding_state.dart';

class SapCartonLabelBindingPage extends StatefulWidget {
  const SapCartonLabelBindingPage({super.key});

  @override
  State<SapCartonLabelBindingPage> createState() => _SapCartonLabelBindingPageState();
}

class _SapCartonLabelBindingPageState extends State<SapCartonLabelBindingPage> {
  final SapCartonLabelBindingLogic logic = Get.put(SapCartonLabelBindingLogic());
  final SapCartonLabelBindingState state = Get.find<SapCartonLabelBindingLogic>().state;
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
                      expandedTextSpan(hint: 'carton_label_binding_piece_no'.tr, text: sub.pieceNo ?? ''),
                      IconButton(
                        onPressed: () => askDialog(
                            content: 'carton_label_binding_delete_label_tips'.tr,
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
                expandedTextSpan(hint: 'carton_label_binding_out_box_label_piece_no'.tr, text: boxLabel.pieceNo ?? ''),
                IconButton(
                  onPressed: () => askDialog(
                    content: 'carton_label_binding_delete_label_tips'.tr,
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
        Obx(() => state.newBoxLabelID.value.isEmpty
            ? Container()
            : CombinationButton(
                combination: Combination.left,
                text: 'carton_label_binding_print_out_box_label'.tr,
                click: () => logic.printNewBoxLabel(),
              )),
        Obx(() =>
            state.operationTypeText.value == getOperationTypeText(ScanLabelOperationType.unKnown)
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
    Get.delete<SapCartonLabelBindingLogic>();
    super.dispose();
  }
}
