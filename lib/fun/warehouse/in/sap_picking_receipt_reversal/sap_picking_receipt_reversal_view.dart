import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_picking_receipt_reversal/sap_picking_receipt_reversal_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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

  GestureDetector _item(int index) {
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
              hint: 'sap_picking_receipt_reversal_material_voucher'.tr,
              text: state.orderList[index].head!.materialVoucherNo ?? '',
              textColor: Colors.red,
            ),
            textSpan(
              hint: 'sap_picking_receipt_reversal_dispatch_date'.tr,
              text: state.orderList[index].head!.date ?? '',
              textColor: Colors.red,
            ),
            const Divider(height: 10, color: Colors.black),
            for (var dis in state.orderList[index].item!) ...[
              const SizedBox(height: 5),
              textSpan(
                hint: 'sap_picking_receipt_reversal_dispatch_no'.tr,
                text: dis.order ?? '',
                textColor: Colors.lightBlueAccent,
              ),
              for (var material in dis.subItem!) ...[
                textSpan(
                  hint: 'sap_picking_receipt_reversal_material_name'.tr,
                  isBold: false,
                  text: material.name ?? '',
                  textColor: Colors.blue.shade900,
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      flex: 2,
                      hint: 'sap_picking_receipt_reversal_storage_location'.tr,
                      isBold: false,
                      text: material.locationName ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    textSpan(
                      hint: 'sap_picking_receipt_reversal_quantity'.tr,
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

  void _query() {
    logic.query(
      order: orderController.text,
      materialCode: materialCodeController.text,
      orderType: orderType.value,
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      warehouse: factoryWarehouseController.getPickItem2().pickerId(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          controller: orderController,
          hint: 'sap_picking_receipt_reversal_input_dispatch_no_tips'.tr,
        ),
        EditText(
          controller: materialCodeController,
          hint: 'sap_picking_receipt_reversal_input_material_code_tips'.tr,
        ),
        Obx(() => RadioGroup(
              groupValue: orderType.value,
              onChanged: (v) => orderType.value = v!,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: RadioListTile(
                      title: Text(
                          'sap_picking_receipt_reversal_produce_picking'.tr),
                      value: 1,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile(
                      title:
                          Text('sap_picking_receipt_reversal_produce_take'.tr),
                      value: 2,
                    ),
                  ),
                ],
              ),
            )),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        LinkOptionsPicker(pickerController: factoryWarehouseController)
      ],
      query: () => _query(),
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
                text: 'sap_picking_receipt_reversal_reverse'.tr,
                click: () => askDialog(
                  content: 'sap_picking_receipt_reversal_reverse_tips'.tr,
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
