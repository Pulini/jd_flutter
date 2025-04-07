import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_posting_view.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_progress_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'picking_material_order_logic.dart';
import 'picking_material_order_state.dart';

class PickingMaterialOrderPage extends StatefulWidget {
  const PickingMaterialOrderPage({super.key});

  @override
  State<PickingMaterialOrderPage> createState() =>
      _PickingMaterialOrderPageState();
}

class _PickingMaterialOrderPageState extends State<PickingMaterialOrderPage> {
  final PickingMaterialOrderLogic logic = Get.put(PickingMaterialOrderLogic());
  final PickingMaterialOrderState state =
      Get.find<PickingMaterialOrderLogic>().state;
  var tecInstruction = TextEditingController();
  var tecPickingMaterialOrder = TextEditingController();

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.pickingMaterialOrder.name}${PickerType.startDate}',
  );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.pickingMaterialOrder.name}${PickerType.endDate}',
  );

  var opcSupplier = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey:
        '${RouteConfig.pickingMaterialOrder.name}${PickerType.sapSupplier}',
  );
  var lopcFactoryWarehouse = LinkOptionsPickerController(
    hasAll: true,
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.pickingMaterialOrder.name}${PickerType.sapFactoryWarehouse}',
    buttonName: 'picking_material_order_factory_warehouse'.tr,
  );

  _query() {
    logic.queryPickingMaterialOrder(
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      instruction: tecInstruction.text,
      pickingMaterialOrder: tecPickingMaterialOrder.text,
      sapSupplier: opcSupplier.selectedId.value,
      sapFactory: lopcFactoryWarehouse.getOptionsPicker1().pickerId(),
      sapWarehouse: lopcFactoryWarehouse.getOptionsPicker2().pickerId(),
    );
  }

  Widget _item(int index) {
    var data = state.orderList[index];
    var printButton = CombinationButton(
      text: 'picking_material_order_print_material'.tr,
      combination:
          data.pickedStatus() == 1 ? Combination.intact : Combination.left,
      click: () =>logic.printMaterialList(data.orderNumber??''),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade100, Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: ExpansionTile(
        expandedCrossAxisAlignment: CrossAxisAlignment.end,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: textSpan(hint: 'picking_material_order_picking_number'.tr, text: data.orderNumber ?? ''),
        subtitle: Row(
          children: [
            expandedTextSpan(
              flex: 3,
              hint: 'picking_material_order_supplier'.tr,
              text: data.supplierName ?? '',
              isBold: false,
              textColor: Colors.green.shade700,
            ),
            expandedTextSpan(
              flex: 2,
              hint: 'picking_material_order_create'.tr,
              text: '${data.date} ${data.created}',
              textColor: Colors.black54,
              isBold: false,
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    data.colorFlg == 'X' ? 'picking_material_order_have_color_system'.tr : 'picking_material_order_not_have_color_system'.tr,
                    style: TextStyle(
                      color: data.colorFlg == 'X'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                  Text(
                    data.preparedMaterialsStatusText(),
                    style: TextStyle(
                      color: data.preparedMaterialsStatusColor(),
                    ),
                  ),
                  Text(
                    data.pickedStatusText(),
                    style: TextStyle(
                      color: data.pickedStatusColor(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                expandedFrameText(
                  flex: 7,
                  text: 'picking_material_order_material'.tr,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                ),
                expandedFrameText(
                  flex: 3,
                  text: 'picking_material_order_instruction'.tr,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                ),
                expandedFrameText(
                  flex: 3,
                  text: 'picking_material_order_demand_qty'.tr,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                ),
                expandedFrameText(
                  text: 'picking_material_order_picking_status'.tr,
                  alignment: Alignment.center,
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  borderColor: Colors.black54,
                ),
              ],
            ),
          ),
          for (var sub in data.materialList ?? []) _subItem(sub),
          data.pickedStatus() == 1
              ? printButton
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    printButton,
                    CombinationButton(
                      text: 'picking_material_order_report_preparing_materials_info'.tr,
                      combination: Combination.middle,
                      click: () => Get.to(
                        () => const PickingMaterialOrderProgressPage(),
                        arguments: {'index': index},
                      )?.then((v) {
                        if (v != null && v == true) _query();
                      }),
                    ),
                    CombinationButton(
                      text: 'picking_material_order_posting'.tr,
                      combination: Combination.right,
                      click: () => Get.to(
                        () => const PickingMaterialOrderPostingPage(),
                        arguments: {'index': index},
                      )?.then((v) {
                        if (v != null && v == true) _query();
                      }),
                    ),
                  ],
                )
        ],
      ),
    );
  }

  _subItem(PickingMaterialOrderMaterialInfo data) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10),
      child: Row(
        children: [
          expandedFrameText(
            flex: 7,
            text: data.getMaterial(),
            borderColor: Colors.black54,
          ),
          expandedFrameText(
            flex: 3,
            text: data.instructionNo ?? '',
            borderColor: Colors.black54,
          ),
          expandedFrameText(
            flex: 3,
            text: data.isOnlyOneUnit()
                ? data.getBasicDemandQtyText()
                : '${data.getBasicDemandQtyText()}/${data.getCommonDemandQtyText()}',
            alignment: Alignment.centerRight,
            borderColor: Colors.black54,
          ),
          expandedFrameText(
            text: data.pickedStatusText(),
            alignment: Alignment.center,
            textColor: data.pickedStatus() == 0
                ? Colors.red
                : data.pickedStatus() == 1
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
            borderColor: Colors.black54,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      popTitle: 'picking_material_order_exit_tips'.tr,
      queryWidgets: [
        EditText(
          hint: 'picking_material_order_sales_order'.tr,
          controller: tecInstruction,
        ),
        EditText(
          hint: 'picking_material_order_picking_no'.tr,
          controller: tecPickingMaterialOrder,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        OptionsPicker(pickerController: opcSupplier),
        LinkOptionsPicker(pickerController: lopcFactoryWarehouse),
        Row(
          children: [
            Obx(() => CheckBox(
                  onChanged: (v) => state.isPosted.value = 0,
                  name: 'picking_material_order_all'.tr,
                  value: state.isPosted.value == 0,
                )),
            Obx(() => CheckBox(
                  onChanged: (v) => state.isPosted.value = 1,
                  name: 'picking_material_order_not_deliver'.tr,
                  value: state.isPosted.value == 1,
                )),
            Obx(() => CheckBox(
                  onChanged: (v) => state.isPosted.value = 2,
                  name: 'picking_material_order_delivered'.tr,
                  value: state.isPosted.value == 2,
                )),
          ],
        )
      ],
      query: _query,
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.only(left: 7, right: 7, bottom: 7),
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(i),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PickingMaterialOrderLogic>();
    super.dispose();
  }
}
