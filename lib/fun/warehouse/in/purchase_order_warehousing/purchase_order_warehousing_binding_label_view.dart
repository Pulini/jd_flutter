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
      title: '标签绑定',
      popTitle: '确定要退出标签绑定吗？',
      actions: [
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
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.scannedLabelList.length,
                  itemBuilder: (c, i) => _item(state.scannedLabelList[i]),
                )),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Obx(() => textSpan(
                  hint: '已扫描：',
                  text: state.scannedLabelList.length.toString(),
                )),
          ),
          Obx(() => CombinationButton(
                combination: Combination.right,
                isEnabled: state.scannedLabelList.isNotEmpty,
                text: '提交',
                click: () =>
                    logic.submitLabelBinding(() => Get.back(result: true)),
              ))
        ],
      ),
    );
  }
}
