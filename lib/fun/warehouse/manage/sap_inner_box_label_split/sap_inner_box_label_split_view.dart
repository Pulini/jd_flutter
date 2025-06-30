import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_inner_box_label_split_logic.dart';
import 'sap_inner_box_label_split_state.dart';

class SapInnerBoxLabelSplitPage extends StatefulWidget {
  const SapInnerBoxLabelSplitPage({super.key});

  @override
  State<SapInnerBoxLabelSplitPage> createState() =>
      _SapInnerBoxLabelSplitPageState();
}

class _SapInnerBoxLabelSplitPageState extends State<SapInnerBoxLabelSplitPage> {
  final SapInnerBoxLabelSplitLogic logic =
      Get.put(SapInnerBoxLabelSplitLogic());
  final SapInnerBoxLabelSplitState state =
      Get.find<SapInnerBoxLabelSplitLogic>().state;
  var controller = TextEditingController();
  var fn = FocusNode();

  _newLabelItem(SapPrintLabelInfo label) => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.green.shade100, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textSpan(
                          hint: '收货方：',
                          text: label.shipToParty ?? '',
                          textColor: Colors.green.shade800),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textSpan(
                            hint: '件号：',
                            text: label.pieceID ?? '',
                          ),
                          textSpan(
                            hint: '供应商：',
                            text: label.supplierNumber ?? '',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Obx(() => Checkbox(
                      value: label.isSelected.value,
                      onChanged: (v) => label.isSelected.value = v!,
                    ))
              ],
            ),
            const Divider(),
            for (SapPrintLabelSubInfo sub in label.subLabel!) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '(${sub.materialNumber})${sub.materialName}',
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  textSpan(
                    hint: '数量：',
                    text: '${sub.inBoxQty.toShowString()}${sub.unit}',
                  )
                ],
              ),
              const Divider(),
            ],
          ],
        ),
      );

  _splitLabelItem(List<SapLabelSplitInfo> newLabel) => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '待提交标签',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => logic.deletePreSplit(newLabel),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                )
              ],
            ),
            for (SapLabelSplitInfo sub in newLabel) ...[
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '(${sub.materialNumber})${sub.materialName}',
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  textSpan(
                    hint: '数量：',
                    text: '${sub.qty.toShowString()}${sub.unit}',
                  )
                ],
              ),
            ],
          ],
        ),
      );

  _originalLabelItem() => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
                hint: '收货方：',
                text: state.originalLabel!.shipToParty ?? '',
                textColor: Colors.green.shade800),
            Row(
              children: [
                expandedTextSpan(
                  hint: '件号：',
                  text: state.originalLabel!.pieceID ?? '',
                ),
                expandedTextSpan(
                  hint: '供应商：',
                  text: state.originalLabel!.supplierNumber ?? '',
                ),
              ],
            ),
            const Divider(),
            for (SapPrintLabelSubInfo sub
                in state.originalLabel!.subLabel!) ...[
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Text(
                  '(${sub.materialNumber})${sub.materialName}',
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const SizedBox(width: 5),
                  expandedTextSpan(
                    flex: 2,
                    hint: 'sap_wms_split_label_split_qty'.tr,
                    text: '${sub.canSplitQty.value.toShowString()}${sub.unit}',
                    hintColor:
                        sub.canSplitQty.value == 0 ? Colors.grey : Colors.black,
                    textColor:
                        sub.canSplitQty.value == 0 ? Colors.grey : Colors.blue,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 3,
                    child: sub.canSplitQty.value == 0
                        ? Text('已拆出：${sub.inBoxQty.toShowString()}')
                        : Row(
                            children: [
                              Text(
                                '拆出：',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              Expanded(
                                  child: NumberDecimalEditText(
                                max: sub.canSplitQty.value,
                                onChanged: (v) => sub.splitQty.value = v,
                              ))
                            ],
                          ),
                  )
                ],
              ),
              const Divider(),
            ],
            SizedBox(
              width: double.infinity,
              child: Obx(() => CombinationButton(
                    isEnabled: state.originalLabel!.hasSplitQty(),
                    text: '预拆分',
                    click: () => logic.preSplit(),
                  )),
            )
          ],
        ),
      );

  @override
  void initState() {
    pdaScanner(scan: (code) {
      hidKeyboard();
      logic.scanCode(code: code, refresh: () => setState(() {}));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Obx(() => state.splitLabelList.isNotEmpty
            ? CombinationButton(
                text: '提交拆分',
                click: () => askDialog(
                  content: '确定要提交预拆分标签吗？',
                  confirm: () => logic.submitPreSplit(),
                ),
              )
            : Container()),
        Obx(() => state.newLabelList.isNotEmpty &&
                state.newLabelList.any((v) => v.isSelected.value)
            ? CombinationButton(
                text: '打印',
                click: () => logic.printLabel(),
              )
            : Container())
      ],
      popTitle: '确定要退出标签拆分吗？',
      body: Obx(() => ListView(
            children: [
              if (state.originalLabel != null) _originalLabelItem(),
              for (var sLabel in state.splitLabelList) _splitLabelItem(sLabel),
              for (var nLabel in state.newLabelList) _newLabelItem(nLabel),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapInnerBoxLabelSplitLogic>();
    super.dispose();
  }
}
