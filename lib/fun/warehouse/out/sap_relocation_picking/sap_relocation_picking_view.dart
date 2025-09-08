import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_dialog.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_relocation_picking/sap_relocation_picking_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_relocation_picking_logic.dart';
import 'sap_relocation_picking_state.dart';

class SapRelocationPickingPage extends StatefulWidget {
  const SapRelocationPickingPage({super.key});

  @override
  State<SapRelocationPickingPage> createState() =>
      _SapRelocationPickingPageState();
}

class _SapRelocationPickingPageState extends State<SapRelocationPickingPage> {
  final SapRelocationPickingLogic logic = Get.put(SapRelocationPickingLogic());
  final SapRelocationPickingState state =
      Get.find<SapRelocationPickingLogic>().state;

  _item(SapPalletDetailInfo data) {
    return GestureDetector(
      onTap: () {
        modifyPickingQty(
          quantity: data.pickQty,
          coefficient: 1,
          basicUnit: data.unit ?? '',
          commonUnit: data.unit ?? '',
          callback: (v) => setState(() => data.pickQty = v),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(hint: 'sap_relocation_pick_material'.tr, text: data.materialName ?? ''),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      textSpan(
                        hint: 'sap_relocation_pick_type_body'.tr,
                        isBold: false,
                        text: data.typeBody ?? '',
                        textColor: Colors.blue.shade700,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          textSpan(
                            hint: 'sap_relocation_pick_box_capacity'.tr,
                            isBold: false,
                            text: '${data.quantity.toShowString()}${data.unit}',
                            textColor: Colors.blue.shade700,
                          ),
                          textSpan(
                            hint: 'sap_relocation_pick_pick_qty'.tr,
                            isBold: false,
                            text: '${data.pickQty.toShowString()} ${data.unit}',
                            textColor: Colors.green.shade700,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => state.materialList.remove(data),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) {
      logic.scanCode(code);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
          actions: [
            if (state.materialList.isNotEmpty)
              TextButton(
                onPressed: () => state.materialList.clear(),
                child: Text('sap_relocation_pick_clean'.tr),
              ),
          ],
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.materialList.length,
                  itemBuilder: (c, i) => _item(state.materialList[i]),
                ),
              ),
              if (state.materialList.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: 'sap_relocation_pick_submit_pick'.tr,
                    click: () => checkPickerAndWarehouseDialog(
                      pickerCheck: (pn, ps, un, us, w) => logic.submitPicking(
                        pickerNumber: pn,
                        pickerSignature: ps,
                        userNumber: un,
                        userSignature: us,
                        warehouse: w,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    Get.delete<SapRelocationPickingLogic>();
    super.dispose();
  }
}
