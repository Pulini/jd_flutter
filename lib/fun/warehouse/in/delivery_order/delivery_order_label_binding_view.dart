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

  Widget _item(DeliveryOrderLabelInfo data) => Obx(() => Container(
        margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        padding: const EdgeInsets.only(left: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: data.isChecked.value ? Colors.green.shade200 : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(child: Text(data.pieceNo ?? '')),
            IconButton(
              onPressed: () => askDialog(
                content: '确定要删除本条标签吗？',
                confirm: () => logic.deletePiece(pieceInfo: data),
              ),
              icon: const Icon(
                Icons.delete_forever,
                color: Colors.red,
              ),
            )
          ],
        ),
      ));

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
      title: '送货清点',
      popTitle: '确定要退出送货清点吗？',
      actions: [
        // IconButton(onPressed: ()=>logic.scanLabel('00505685E5761FE095C24B636E12517B'), icon: Icon(Icons.add)),
        TextButton(
          onPressed: () => askDialog(
            content: '确定要清空已扫描钱吗？',
            confirm: () => state.scannedLabelList.clear(),
          ),
          child: Text('清空'),
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
                labelText: '件号',
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
                      text: '添加件',
                      click: () =>
                          logic.addPiece(pieceNo: pieceController.text),
                    )),
              ),
            ),
          ),
          // Obx(() => progressIndicator(
          //   max: state.colorOrderList[index].qty ?? 0,
          //   value: scannedList.isEmpty
          //       ? 0
          //       : scannedList
          //       .map((v) => v.commonQty)
          //       .reduce((a, b) => a.add(b)),
          // )),
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.scannedLabelList.length,
                  itemBuilder: (c, i) => _item(state.scannedLabelList[i]),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => textSpan(
                      hint: '已扫描：',
                      text: state.scannedLabelList.length.toString(),
                    )),
                textSpan(
                  hint: '送货单号：',
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
                      text: '暂存',
                      click: () => logic.stagingLabelBinding(),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.scannedLabelList.isNotEmpty &&
                          (state.scannedLabelList
                                  .every((v) => v.isChecked.value) ||
                              state.scannedLabelList
                                  .every((v) => !v.isChecked.value)),
                      text: '提交',
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
