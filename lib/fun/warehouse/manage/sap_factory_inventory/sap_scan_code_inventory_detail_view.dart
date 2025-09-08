import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_scan_code_inventory_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_factory_inventory_logic.dart';
import 'sap_factory_inventory_state.dart';

class SapScanCodeInventoryDetailPage extends StatefulWidget {
  const SapScanCodeInventoryDetailPage({super.key});

  @override
  State<SapScanCodeInventoryDetailPage> createState() =>
      _SapScanCodeInventoryDetailPageState();
}

class _SapScanCodeInventoryDetailPageState
    extends State<SapScanCodeInventoryDetailPage> {
  final SapScanCodeInventoryLogic logic = Get.find<SapScanCodeInventoryLogic>();
  final SapScanCodeInventoryState state =
      Get.find<SapScanCodeInventoryLogic>().state;
  final index = Get.arguments['index'];

  _item(InventoryPalletInfo data) {
    return InkWell(
      onTap: () {
        data.isSelected.value = !data.isSelected.value;
        state.palletList.refresh();
      },
      child: Container(
        padding: const EdgeInsets.only(
          left: 10,
          top: 5,
          right: 10,
          bottom: 5,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color:
              data.isSelected.value ? Colors.green.shade50 : Colors.red.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: 'sap_inventory_label_qty'.tr,
              isBold: false,
              text: data.labelId ?? '',
              textColor: Colors.green,
            ),
            textSpan(
              hint: 'sap_inventory_material'.tr,
              text: '(${data.materialCode}) ${data.materialName}'
                  .allowWordTruncation(),
              maxLines: 2,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_inventory_qty'.tr,
                  isBold: false,
                  text: data.quantity.toShowString(),
                  textColor: Colors.black87,
                ),
                textSpan(
                  hint: 'sap_inventory_unit'.tr,
                  isBold: false,
                  text: data.basicUnit ?? '',
                  textColor: Colors.black87,
                ),
              ],
            ),
            textSpan(
              hint: 'sap_inventory_status'.tr,
              isBold: false,
              text: data.getStateText(),
              textColor: Colors.black87,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'sap_inventory_pallet_number'.trArgs(
        [state.palletList[index][0].palletNumber ?? ''],
      ),
      actions: [
        Obx(() => Checkbox(
              value: state.palletList[index].every((v) => v.isSelected.value),
              onChanged: (selectAll) {
                for (var v in state.palletList[index]) {
                  v.isSelected.value = selectAll!;
                }
                state.palletList.refresh();
              },
            ))
      ],
      body: Obx(() => ListView.builder(
            itemCount: state.palletList[index].length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (c, i) => _item(state.palletList[index][i]),
          )),
    );
  }
}
