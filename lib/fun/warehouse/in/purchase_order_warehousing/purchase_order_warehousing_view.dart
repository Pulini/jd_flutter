import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_warehousing_info.dart';
import 'package:jd_flutter/fun/warehouse/in/purchase_order_warehousing/purchase_order_warehousing_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'purchase_order_warehousing_logic.dart';
import 'purchase_order_warehousing_state.dart';

class PurchaseOrderWarehousingPage extends StatefulWidget {
  const PurchaseOrderWarehousingPage({super.key});

  @override
  State<PurchaseOrderWarehousingPage> createState() =>
      _PurchaseOrderWarehousingPageState();
}

class _PurchaseOrderWarehousingPageState
    extends State<PurchaseOrderWarehousingPage> {
  final PurchaseOrderWarehousingLogic logic =
      Get.put(PurchaseOrderWarehousingLogic());
  final PurchaseOrderWarehousingState state =
      Get.find<PurchaseOrderWarehousingLogic>().state;

  var opcSupplier = OptionsPickerController(
    PickerType.sapSupplier,
    saveKey:
        '${RouteConfig.purchaseOrderWarehousing.name}${PickerType.sapSupplier}',
  );
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.purchaseOrderWarehousing.name}${PickerType.sapFactoryWarehouse}',
  );
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.purchaseOrderWarehousing.name}${PickerType.startDate}',
  );
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey:
        '${RouteConfig.purchaseOrderWarehousing.name}${PickerType.endDate}',
  );
  var distributionController = TextEditingController();

  _query() {
    logic.query(
      startDate: dpcStartDate.getDateFormatYMD(),
      endDate: dpcEndDate.getDateFormatYMD(),
      supplierNumber: opcSupplier.selectedId.value,
      factory: factoryWarehouseController.getOptionsPicker1().pickerId(),
      warehouse: factoryWarehouseController.getOptionsPicker2().pickerId(),
    );
  }

  Widget _item(PurchaseOrderInfo data) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.green.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '(${data.materialCode})${data.materialName}',
            maxLines: 2,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'purchase_order_warehousing_type_body'.trArgs(
                    [data.typeBody ?? ''],
                  ),
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              Expanded(
                child: Text(
                  'purchase_order_warehousing_original_sales_order'.trArgs(
                    [data.salesOrder ?? ''],
                  ),
                  style: const TextStyle(color: Colors.black54),
                ),
              )
            ],
          ),
          Row(
            children: [
              expandedFrameText(
                flex: 3,
                text: 'purchase_order_warehousing_item_purchase_order'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 5,
                text: 'purchase_order_warehousing_item_customer_po'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
              ),
              expandedFrameText(
                flex: 2,
                text: 'purchase_order_warehousing_item_track_no'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 2,
                text: 'purchase_order_warehousing_item_purchase_order_line'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 1,
                text: 'purchase_order_warehousing_item_size'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 2,
                text: 'purchase_order_warehousing_item_order_qty'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 2,
                text: 'purchase_order_warehousing_item_received_qty'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              expandedFrameText(
                flex: 2,
                text: 'purchase_order_warehousing_item_qty'.tr,
                alignment: Alignment.center,
                backgroundColor: Colors.green.shade50,
                textColor: Colors.black54,
                borderColor: Colors.black,
                isBold: true,
              ),
              Expanded(
                child: Container(
                  height: 35,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.green.shade50,
                  ),
                  alignment: Alignment.center,
                  child:
                      data.details!.every((v) => v.underNum.toDoubleTry() == 0)
                          ? null
                          : Obx(() => Checkbox(
                                value: data.isSelectAll(),
                                onChanged: (v) {
                                  data.selectAll(v!);
                                  distributionController.text =
                                      logic.refreshQty().toShowString();
                                },
                              )),
                ),
              )
            ],
          ),
          for (PurchaseOrderDetailsInfo sub in data.details ?? []) _subItem(sub)
        ],
      ),
    );
  }

  _subItem(PurchaseOrderDetailsInfo data) {
    return Row(
      children: [
        expandedFrameText(
          flex: 3,
          text: data.purchaseOrder ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        expandedFrameText(
          flex: 5,
          text: data.customerPO ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
        ),
        expandedFrameText(
          flex: 2,
          text: data.trackNo ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        expandedFrameText(
          flex: 2,
          text: data.purchaseOrderLineItem ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        expandedFrameText(
          flex: 1,
          text: data.size ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        expandedFrameText(
          flex: 2,
          text: data.orderQty ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        expandedFrameText(
          flex: 2,
          text: data.receivedQty ?? '',
          alignment: Alignment.center,
          backgroundColor: Colors.white,
          textColor: Colors.black54,
          borderColor: Colors.black,
          isBold: true,
        ),
        Expanded(
          flex: 2,
          child: data.underNum.toDoubleTry() == 0
              ? Container(
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Text(
                      data.underNum ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                )
              : Container(
                  height: 35,
                  padding: const EdgeInsets.only(
                      left: 5, top: 2, right: 5, bottom: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  child: Obx(() {
                    var controller = TextEditingController(
                        text: data.qty.value.toShowString());
                    return TextField(
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                      ],
                      onChanged: (v) {
                        if (v.toDoubleTry() > data.underNum.toDoubleTry()) {
                          data.qty.value = data.underNum.toDoubleTry();
                          controller.text = data.underNum ?? '0';
                        } else {
                          data.qty.value = v.toDoubleTry();
                        }
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 10,
                          right: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade300,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                    );
                  }),
                ),
        ),
        Expanded(
          child: Container(
            height: 35,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            child: data.underNum.toDoubleTry() == 0
                ? null
                : Obx(() => Checkbox(
                      value: data.isSelected.value,
                      onChanged: (v) {
                        data.isSelected.value = v!;
                        distributionController.text =
                            logic.refreshQty().toShowString();
                      },
                    )),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      actions: [
        Obx(() {
          var hasSelect = state.orderList
              .any((v) => v.details!.any((v2) => v2.isSelected.value));
          return hasSelect
              ? Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    textSpan(
                      hint: 'purchase_order_warehousing_order_qty'.tr,
                      text: state.orderQty.value.toShowString(),
                      isBold: false,
                    ),
                    const SizedBox(width: 10),
                    textSpan(
                      hint: 'purchase_order_warehousing_received_qty'.tr,
                      text: state.receivedQty.value.toShowString(),
                      isBold: false,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 300,
                      margin: const EdgeInsets.all(5),
                      height: 40,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                        ],
                        controller: distributionController,
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
                          labelText: 'purchase_order_warehousing_qty'.tr,
                          prefixIcon: IconButton(
                            onPressed: () => distributionController.clear(),
                            icon: const Icon(
                              Icons.replay_circle_filled,
                              color: Colors.red,
                            ),
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CombinationButton(
                                combination: Combination.left,
                                text: 'purchase_order_warehousing_distribution'.tr,
                                click: () => logic.distribution(
                                  qty:
                                      distributionController.text.toDoubleTry(),
                                  refresh: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    showSnackBar(message: 'purchase_order_warehousing_distribution_finish'.tr);
                                  },
                                ),
                              ),
                              CombinationButton(
                                combination: Combination.right,
                                text: 'purchase_order_warehousing_warehousing'.tr,
                                click: () => stockInDialog(
                                  factoryNumber: state.factoryNumber,
                                  dataList: state.orderList,
                                  refresh: () => _query(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox();
        }),
        Obx(() => CheckBox(
              name: 'purchase_order_warehousing_select_all'.tr,
              value: state.orderList.every((v) => v.isSelectAll()),
              onChanged: (v) {
                logic.selectAll(v);
                distributionController.text = logic.refreshQty().toShowString();
              },
            )),
        const SizedBox(width: 20),
      ],
      queryWidgets: [
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_type_body'.tr,
              initStr: state.typeBody.value,
              onChanged: (v) => state.typeBody.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_instruction'.tr,
              initStr: state.instruction.value,
              onChanged: (v) => state.instruction.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_purchase_order'.tr,
              initStr: state.purchaseOrder.value,
              onChanged: (v) => state.purchaseOrder.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_material_code'.tr,
              initStr: state.materielCode.value,
              onChanged: (v) => state.materielCode.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_customer_po'.tr,
              initStr: state.customerPO.value,
              onChanged: (v) => state.customerPO.value = v,
            )),
        Obx(() => EditText(
              hint: 'purchase_order_warehousing_input_track_no'.tr,
              initStr: state.trackNo.value,
              onChanged: (v) => state.trackNo.value = v,
            )),
        OptionsPicker(pickerController: opcSupplier),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
      ],
      query: _query,
      body: Obx(() => ListView.builder(
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(state.orderList[i]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PurchaseOrderWarehousingLogic>();
    super.dispose();
  }
}
