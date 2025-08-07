import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'delivery_order_logic.dart';
import 'delivery_order_state.dart';

class DeliveryOrderLabelBindingPage extends StatefulWidget {
  const DeliveryOrderLabelBindingPage({super.key});

  @override
  State<DeliveryOrderLabelBindingPage> createState() =>
      _DeliveryOrderLabelBindingPageState();
}

class _DeliveryOrderLabelBindingPageState
    extends State<DeliveryOrderLabelBindingPage> {
  final DeliveryOrderLogic logic = Get.find<DeliveryOrderLogic>();
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;
  var pieceController = TextEditingController();

  Widget _materialItem(Map<String, List<dynamic>> map) {
    var materialCode = map.keys.first;
    var list = map.values.first;
    return Obx(() => Container(
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade100, Colors.green.shade50],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  textSpan(hint: '物料：', text: materialCode),
                  const SizedBox(width: 5),
                  Expanded(
                    child: progressIndicator(
                      max: logic.getMaterialsTotal(materialCode),
                      value: logic.getScanProgress(materialCode),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 5),
              for (var size in list) ..._sizeItem(size,materialCode)
            ],
          ),
        ));
  }

  _sizeItem(List<dynamic> size, String materialCode) {
    return [
      if ((size[0] as String).isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: Row(
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
                  color: Colors.blue.shade300,
                  value: logic.getSizeScanProgress(materialCode,size[0] ?? ''),
                ),
              )
            ],
          ),
        ),
      for (DeliveryOrderLabelInfo label in size[2]) _labelItem(label)
    ];
  }

  Widget _labelItem(DeliveryOrderLabelInfo data) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: data.isChecked.value ? Colors.green.shade200 : Colors.white,
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
                content: 'delivery_order_label_check_delete_tips'.tr,
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

  @override
  void initState() {
    state.canAddPiece.value = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getLabelBindingStaging();
    });
    pdaScanner(scan: (code) {
      if (code.isNotEmpty) logic.scanLabel(code);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'delivery_order_label_check_title'.tr,
      popTitle: 'delivery_order_label_check_exit_tips'.tr,
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: 'delivery_order_label_check_clear_tips'.tr,
            confirm: () => state.scannedLabelList.clear(),
          ),
          child: Text('delivery_order_label_check_clear'.tr),
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
                labelText: 'delivery_order_label_check_piece_id'.tr,
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
                      text: 'delivery_order_label_check_add_piece'.tr,
                      click: () =>
                          logic.addPiece(pieceNo: pieceController.text),
                    )),
              ),
            ),
          ),
          // ..._scanProgress(),
          Expanded(
            child: Obx(() {
              var list = logic.getLabelList();
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (c, i) => _materialItem(list[i]),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => textSpan(
                      hint: 'delivery_order_label_check_scanned'.tr,
                      text: state.scannedLabelList.length.toString(),
                    )),
                textSpan(
                  hint: 'delivery_order_label_check_order_no'.tr,
                  text: state.orderItemInfo[0].deliNo ?? '',
                  textColor: Colors.green.shade700,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.scannedLabelList.isNotEmpty,
                      text: 'delivery_order_label_check_temporary'.tr,
                      click: () => logic.stagingLabelBinding(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled:logic.isCanSubmitBinding(),
                      text: 'delivery_order_label_check_submit'.tr,
                      click: () => logic.submitLabelBinding(),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
