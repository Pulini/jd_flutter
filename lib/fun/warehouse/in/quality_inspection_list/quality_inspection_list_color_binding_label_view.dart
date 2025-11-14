import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/stuff_quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/quality_inspection_list/quality_inspection_list_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ColorBindingLabelPage extends StatefulWidget {
  const ColorBindingLabelPage({super.key});

  @override
  State<ColorBindingLabelPage> createState() => _ColorBindingLabelPageState();
}

class _ColorBindingLabelPageState extends State<ColorBindingLabelPage> {
  final QualityInspectionListLogic logic =
      Get.find<QualityInspectionListLogic>();
  final QualityInspectionListState state =
      Get.find<QualityInspectionListLogic>().state;
  var index = Get.arguments['index'];

  Obx _item(QualityInspectionLabelBindingInfo data) => Obx(() => Container(
        height: 40,
        padding: const EdgeInsets.only(left: 10, right: 5),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: data.isScanned.value
              ? Colors.green.shade100
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: data.isScanned.value ? Colors.blue : Colors.grey,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            expandedTextSpan(
              hint: 'quality_inspection_binding_piece_id'.tr,
              hintColor: data.isScanned.value ? Colors.black : Colors.grey,
              text: data.pieceNo,
              textColor: data.isScanned.value ? Colors.blueAccent : Colors.grey,
            ),
            textSpan(
              hint: 'quality_inspection_binding_qty'.tr,
              text: data.commonQty.toShowString(),
            ),
            if (data.isScanned.value)
              IconButton(
                onPressed: () => askDialog(
                  content:
                      'quality_inspection_binding_delete_label_tips'
                          .tr,
                  confirm: () {
                    state.colorOrderList[index].bindingLabels.removeWhere(
                      (v) => v.dataId() == data.dataId(),
                    );
                    data.isScanned.value = false;
                  },
                ),
                icon: const Icon(Icons.delete_forever, color: Colors.red),
              )
          ],
        ),
      ));

  @override
  void initState() {
    pdaScanner(
      scan: (code) => logic.scanLabel(code, state.colorOrderList[index]),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var scannedList = state.colorOrderList[index].bindingLabels;
    return pageBody(
      title: 'quality_inspection_binding_title'
          .trArgs([state.colorOrderList[index].batchNo ?? '']),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            child: Row(
              children: [
                Text(
                  'quality_inspection_binding_scanned_material_qty'
                      .tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Obx(() => progressIndicator(
                        max: state.colorOrderList[index].qty ?? 0,
                        value: scannedList.isEmpty
                            ? 0
                            : scannedList
                                .map((v) => v.commonQty)
                                .reduce((a, b) => a.add(b)),
                      )),
                ),
                const SizedBox(width: 30),
                Obx(() => textSpan(
                      hint:
                          'quality_inspection_binding_label_qty'
                              .tr,
                      text: scannedList.length.toString(),
                    )),
              ],
            ),
          ),
          Expanded(
              child: Obx(() => ListView.builder(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    itemCount: state.scanList.length,
                    itemBuilder: (c, i) => _item(state.scanList[i]),
                  )))
        ],
      ),
    );
  }
}
