import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_detail_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'sap_production_picking_logic.dart';
import 'sap_production_picking_state.dart';

class SapProductionPickingPage extends StatefulWidget {
  const SapProductionPickingPage({super.key});

  @override
  State<SapProductionPickingPage> createState() =>
      _SapProductionPickingPageState();
}

class _SapProductionPickingPageState extends State<SapProductionPickingPage> {
  final SapProductionPickingLogic logic = Get.put(SapProductionPickingLogic());
  final SapProductionPickingState state =
      Get.find<SapProductionPickingLogic>().state;

  var noticeNoController = TextEditingController();

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.sapProductionPicking.name}${PickerType.startDate}',
  );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapProductionPicking.name}${PickerType.endDate}',
  );

  var workCenterController = OptionsPickerController(
    PickerType.sapWorkCenterNew,
    saveKey:
        '${RouteConfig.sapProductionPicking.name}${PickerType.sapWorkCenterNew}',
  );
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapProductionPicking.name}${PickerType.sapFactoryWarehouse}',
  );
  var isSupplementOrder = false.obs;

  _item(SapPickingInfo data) {
    return GestureDetector(
      onTap: () => setState(() => data.select = !data.select),
      child: Container(
        margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
        padding: const EdgeInsets.only(left: 4, right: 4),
        decoration: BoxDecoration(
          color: data.select ? Colors.blue.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: data.select
              ? Border.all(color: Colors.green, width: 2)
              : Border.all(color: Colors.white, width: 2),
        ),
        foregroundDecoration: RotatedCornerDecoration.withColor(
          color: data.orderType == '0' ? Colors.yellow : Colors.green,
          badgeCornerRadius: const Radius.circular(8),
          badgeSize: const Size(45, 45),
          textSpan: TextSpan(
            text: data.orderType == '0'
                ? 'sap_production_picking_supplementary_order'.tr
                : 'sap_production_picking_normal_order'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_production_picking_notification_no'.tr,
                  text: data.noticeNo ?? '',
                  textColor: Colors.green,
                ),
                expandedTextSpan(
                  hint: 'sap_production_picking_machine'.tr,
                  isBold: false,
                  text: data.machineNumber ?? '',
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_production_picking_warehouse'.tr,
                  text: data.warehouse ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
                expandedTextSpan(
                  hint: 'sap_production_picking_process'.tr,
                  text: data.process ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: data.orderHint(),
                  text: data.orderNumber(),
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
                expandedTextSpan(
                  hint: 'sap_production_picking_dispatch_date'.tr,
                  text: data.orderDate ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          hint: 'sap_production_picking_notification_no_tips'.tr,
          controller: noticeNoController,
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(25),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'sap_production_picking_normal_order'.tr,
                style: const TextStyle(color: Colors.black),
              ),
              Obx(() => Switch(
                    activeThumbColor: Colors.green,
                    inactiveThumbColor: Colors.blueAccent,
                    inactiveTrackColor: Colors.blue.shade200,
                    thumbIcon: WidgetStateProperty.resolveWith<Icon>(
                      (states) => Icon(
                          states.contains(WidgetState.selected)
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios,
                          color: Colors.white),
                    ),
                    value: isSupplementOrder.value,
                    onChanged: (v) => isSupplementOrder.value = v,
                  )),
              Text(
                'sap_production_picking_supplementary_order'.tr,
                style: const TextStyle(color: Colors.black),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(child: DatePicker(pickerController: dpcStartDate)),
            Expanded(child: DatePicker(pickerController: dpcEndDate)),
          ],
        ),
        OptionsPicker(pickerController: workCenterController),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
      ],
      query: () => _query(),
      body: Obx(() => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.pickOrderList.length,
                  itemBuilder: (c, i) => _item(state.pickOrderList[i]),
                ),
              ),
              if (state.pickOrderList.any((v) => v.select))
                SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: 'sap_production_picking_stock_in'.tr,
                    click: () =>
                        logic.checkPickingSelected((scan) => _goPicking(scan)),
                  ),
                ),
            ],
          )),
    );
  }

  _query() {
    logic.queryOrder(
      noticeNo: noticeNoController.text,
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      workCenter: workCenterController.selectedId.value,
      factory: factoryWarehouseController.getPickItem1().pickerId(),
      warehouse: factoryWarehouseController.getPickItem2().pickerId(),
      isSupplementOrder: isSupplementOrder.value,
    );
  }

  _goPicking(bool scan) {
    Get.to(
      () => const SapProductionPickingDetailPage(),
      arguments: {'scan': scan},
    )?.then((_) {
      if (state.needRefresh) {
        state.needRefresh = false;
        _query();
      }
    });
  }

  @override
  void dispose() {
    Get.delete<SapProductionPickingLogic>();
    super.dispose();
  }
}
