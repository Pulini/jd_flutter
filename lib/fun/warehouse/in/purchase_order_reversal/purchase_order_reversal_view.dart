import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_reversal_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'purchase_order_reversal_logic.dart';
import 'purchase_order_reversal_state.dart';

class PurchaseOrderReversalPage extends StatefulWidget {
  const PurchaseOrderReversalPage({super.key});

  @override
  State<PurchaseOrderReversalPage> createState() =>
      _PurchaseOrderReversalPageState();
}

class _PurchaseOrderReversalPageState extends State<PurchaseOrderReversalPage> {
  final PurchaseOrderReversalLogic logic =
      Get.put(PurchaseOrderReversalLogic());
  final PurchaseOrderReversalState state =
      Get.find<PurchaseOrderReversalLogic>().state;

  var opcSupplier = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey:
        '${RouteConfig.purchaseOrderReversal.name}${PickerType.sapSupplier}',
  );
  var factoryWarehouseController = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.purchaseOrderReversal.name}${PickerType.sapFactoryWarehouse}',
  );
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.purchaseOrderReversal.name}${PickerType.startDate}',
  );
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.purchaseOrderReversal.name}${PickerType.endDate}',
  );

  _query() {
    logic.query(
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      supplierNumber: opcSupplier.selectedId.value,
      factory: factoryWarehouseController.getOptionsPicker1().pickerId(),
      warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
    );
  }

  Widget _item(PurchaseOrderReversalInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
              child: Column(
            children: [
              Row(
                children: [
                  expandedTextSpan(
                    flex: 2,
                    hint: 'purchase_order_reversal_material'.tr,
                    text: '(${data.materialCode})${data.materialName}',
                    hintColor: Colors.black54,
                    textColor: Colors.blue.shade800,
                  ),
                  expandedTextSpan(
                    hint: 'purchase_order_reversal_supplier'.tr,
                    text: '(${data.supplier})${data.supplierName}',
                    hintColor: Colors.black54,
                    textColor: Colors.blue.shade800,
                  )
                ],
              ),
              Row(
                children: [
                  expandedTextSpan(
                    hint: 'purchase_order_reversal_sales_order'.tr,
                    text: data.salesOrder ?? '',
                    isBold: false,
                    hintColor: Colors.black54,
                    textColor: Colors.green.shade800,
                  ),
                  expandedTextSpan(
                    hint: 'purchase_order_reversal_purchase_order'.tr,
                    text:
                        '${data.purchaseOrder}(${data.purchaseOrderLineItem})',
                    isBold: false,
                    hintColor: Colors.black54,
                    textColor: Colors.green.shade800,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        expandedTextSpan(
                          hint: 'purchase_order_reversal_receipt_qty'.tr,
                          text:
                              '${data.receiptQty.toShowString()} ${data.unit}',
                          isBold: false,
                          hintColor: Colors.black54,
                          textColor: Colors.green.shade800,
                        ),
                        expandedTextSpan(
                          hint: 'purchase_order_reversal_worker'.tr,
                          text: '${data.userNameCN}(${data.user})',
                          isBold: false,
                          hintColor: Colors.black54,
                          textColor: Colors.green.shade800,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          )),
          Obx(() => Checkbox(
                value: data.isSelect.value,
                onChanged: (v) => data.isSelect.value = v!,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      actions: [
        Obx(
          () => CheckBox(
            onChanged: (c) {
              for (var v in state.orderList) {
                v.isSelect.value = c;
              }
            },
            name: 'purchase_order_reversal_select_all'.tr,
            value: state.orderList.every((v) => v.isSelect.value),
          ),
        ),
        Obx(() => CombinationButton(
              text: 'purchase_order_reversal_reversal'.tr,
              isEnabled: state.orderList.any((v) => v.isSelect.value),
              click: () => logic.reversal(
                (msg) => successDialog(content: msg, back: _query),
              ),
            ))
      ],
      queryWidgets: [
        Obx(() => EditText(
              hint: 'purchase_order_reversal_material_voucher'.tr,
              initStr: state.materialVoucher.value,
              onChanged: (v) => state.materialVoucher.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_reversal_type_body'.tr,
              initStr: state.typeBody.value,
              onChanged: (v) => state.typeBody.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_reversal_sales_order_no'.tr,
              initStr: state.salesOrderNo.value,
              onChanged: (v) => state.salesOrderNo.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_reversal_purchase_order_no'.tr,
              initStr: state.purchaseOrder.value,
              onChanged: (v) => state.purchaseOrder.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_reversal_material_code'.tr,
              initStr: state.materielCode.value,
              onChanged: (v) => state.materielCode.value = v,
            )),
        OptionsPicker(pickerController: opcSupplier),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
      ],
      query: _query,
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(state.orderList[i]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PurchaseOrderReversalLogic>();
    super.dispose();
  }
}
