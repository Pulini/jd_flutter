import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PurchaseOrderWarehousingBindingLabelPage extends StatefulWidget {
  const PurchaseOrderWarehousingBindingLabelPage({super.key});

  @override
  State<PurchaseOrderWarehousingBindingLabelPage> createState() =>
      _PurchaseOrderWarehousingBindingLabelPageState();
}

class _PurchaseOrderWarehousingBindingLabelPageState
    extends State<PurchaseOrderWarehousingBindingLabelPage> {
  final PurchaseOrderWarehousingLogic logic =
      Get.find<PurchaseOrderWarehousingLogic>();
  final PurchaseOrderWarehousingState state =
      Get.find<PurchaseOrderWarehousingLogic>().state;
  var pieceController = TextEditingController();

  Widget _item(DeliveryOrderLabelInfo data) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${data.pieceNo}${data.size?.isNotEmpty == true ? '   ${data.size}#' : ''}',
            ),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: 'purchase_order_warehousing_label_check_delete_tips'.tr,
              confirm: () => logic.deletePiece(pieceInfo: data),
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    state.canAddPiece.value = false;
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) logic.scanLabel(code);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'purchase_order_warehousing_label_check_title'.tr,
      popTitle: 'purchase_order_warehousing_label_check_exit_tips'.tr,
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: 'purchase_order_warehousing_label_check_clear_tips'.tr,
            confirm: () => state.scannedLabelList.clear(),
          ),
          child: Text('purchase_order_warehousing_label_check_clear'.tr),
        )
      ],
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(5),
            height: 40,
            child: TextField(
              controller: pieceController,
              onChanged: (v) => state.canAddPiece.value = v.isNotEmpty,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  top: 0,
                  bottom: 0,
                  left: 15,
                  right: 10,
                ),
                filled: true,
                fillColor: Colors.grey.shade300,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(
                    color: Colors.transparent,
                  ),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                labelText: 'purchase_order_warehousing_label_check_piece_id'.tr,
                prefixIcon: IconButton(
                  onPressed: () {
                    pieceController.clear();
                    state.canAddPiece.value = false;
                  },
                  icon: const Icon(
                    Icons.replay_circle_filled,
                    color: Colors.red,
                  ),
                ),
                suffixIcon: Obx(() => CombinationButton(
                      isEnabled: state.canAddPiece.value,
                      text: 'purchase_order_warehousing_label_check_add_piece'.tr,
                      click: () =>
                          logic.addPiece(pieceNo: pieceController.text),
                    )),
              ),
            ),
          ),
          if (logic.sizeMaterialList().isEmpty)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Obx(() => Row(
                children: [
                  Text(
                    'delivery_order_label_check_progress'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: progressIndicator(
                      max: logic.getMaterialsTotal(),
                      value: logic.getScanProgress(),
                    ),
                  )
                ],
              )),
            ),
          for (var size in logic.sizeMaterialList())
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
              child: Obx(() => Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${size[0]}#',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,

                      ),
                    ),
                  ),
                  Expanded(
                    child: progressIndicator(
                      max: size[1],
                      value: logic.getSizeScanProgress(size[0] ?? ''),
                    ),
                  )
                ],
              )),
            ),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.scannedLabelList.length,
                  itemBuilder: (c, i) => _item(state.scannedLabelList[i]),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Obx(() => textSpan(
                  hint: 'purchase_order_warehousing_label_check_scanned'.tr,
                  text: state.scannedLabelList.length.toString(),
                )),
          ),
          Obx(() => CombinationButton(
                combination: Combination.right,
            isEnabled: logic.isCanSubmitBinding(),
                text: 'purchase_order_warehousing_label_check_submit'.tr,
                click: () =>
                    logic.submitLabelBinding(() => Get.back(result: true)),
              ))
        ],
      ),
    );
  }
}
