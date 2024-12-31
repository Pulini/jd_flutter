import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_picking_receipt_reversal/sap_picking_receipt_reversal_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_picking_receipt_reversal_logic.dart';
import 'sap_picking_receipt_reversal_state.dart';

class SapPickingReceiptReversalPage extends StatefulWidget {
  const SapPickingReceiptReversalPage({super.key});

  @override
  State<SapPickingReceiptReversalPage> createState() =>
      _SapPickingReceiptReversalPageState();
}

class _SapPickingReceiptReversalPageState
    extends State<SapPickingReceiptReversalPage> {
  final SapPickingReceiptReversalLogic logic =
      Get.put(SapPickingReceiptReversalLogic());
  final SapPickingReceiptReversalState state =
      Get.find<SapPickingReceiptReversalLogic>().state;
  var orderController = TextEditingController();
  var materialCodeController = TextEditingController();
  var orderType = 1.obs;
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.sapPickingReceiptReversal.name}${PickerType.startDate}',
  );
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey:
        '${RouteConfig.sapPickingReceiptReversal.name}${PickerType.endDate}',
  );
  var factoryWarehouseController = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapPickingReceiptReversal.name}${PickerType.sapFactoryWarehouse}',
  );

  _item(int index) {
    return GestureDetector(
      onTap: () => setState(() {
        if (state.select == index) {
          state.select = -1;
        } else {
          state.select = index;
        }
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(left: 5, right: 5),
        decoration: BoxDecoration(
          color: state.select == index ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: state.select == index
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: '物料凭证：',
              text: state.orderList[index].head!.materialVoucherNo ?? '',
              textColor: Colors.red,
            ),
            textSpan(
              hint: '派工日期：',
              text: state.orderList[index].head!.date ?? '',
              textColor: Colors.red,
            ),
            const Divider(height: 10, color: Colors.black),
            for (var dis in state.orderList[index].item!) ...[
              SizedBox(
                height: 5,
              ),
              textSpan(
                hint: '派工单号：',
                text: dis.order ?? '',
                textColor: Colors.lightBlueAccent,
              ),
              for (var material in dis.subItem!) ...[
                textSpan(
                  hint: '物料名称：',
                  isBold: false,
                  text: material.name ?? '',
                  textColor: Colors.blue.shade900,
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      flex: 2,
                      hint: '存储位置：',
                      isBold: false,
                      text: material.locationName ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: '数量：',
                      isBold: false,
                      text:
                          '${material.quantity.toShowString()}${material.unit}',
                      textColor: Colors.blue.shade900,
                    ),
                  ],
                ),
                Divider(height: 5, color: Colors.grey.shade300),
              ]
            ],
            if (state.orderList[index].item?.any((v) =>
                    v.subItem?.any((v2) => (v2.quantity2 ?? 0) > 0) == true) ==
                true)
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [Text('WMS')],
              )
          ],
        ),
      ),
    );
  }

  _query() {
    logic.query(
      order: orderController.text,
      materialCode: materialCodeController.text,
      orderType: orderType.value,
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          controller: orderController,
          hint: '请输入派工单号',
        ),
        EditText(
          controller: materialCodeController,
          hint: '请输入物料编码',
        ),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('生产领料'),
                    Radio(
                      value: 1,
                      onChanged: (v) => orderType.value = v!,
                      groupValue: orderType.value,
                    )
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('生产收货'),
                    Radio(
                      value: 2,
                      onChanged: (v) => orderType.value = v!,
                      groupValue: orderType.value,
                    )
                  ],
                ),
              ],
            )),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        LinkOptionsPicker(pickerController: factoryWarehouseController)
      ],
      query: _query,
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.orderList.length,
                  itemBuilder: (c, i) => _item(i),
                )),
          ),
          if (state.select >= 0)
            SizedBox(
              width: double.infinity,
              child: CombinationButton(
                text: '冲销',
                click: () => askDialog(
                  content: '确定要进行冲销吗？',
                  confirm: () => checkPickingReceiptReversalDialog(
                    orderType: orderType.value,
                    handoverCheck: (ln, ls, un, us, d) =>
                        logic.productionReceiptWriteOff(
                      leaderNumber: ln,
                      leaderSignature: ls,
                      userNumber: un,
                      userSignature: us,
                      postingDate: d,
                      refresh: _query,
                    ),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapPickingReceiptReversalLogic>();
    super.dispose();
  }
}
