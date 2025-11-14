import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/work_order_info.dart';
import 'package:jd_flutter/fun/dispatching/work_order_list/part_pick_view.dart';
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'work_order_list_logic.dart';

class WorkOrderListPage extends StatefulWidget {
  const WorkOrderListPage({super.key});

  @override
  State<WorkOrderListPage> createState() => _WorkOrderListPageState();
}

class _WorkOrderListPageState extends State<WorkOrderListPage> {
  final logic = Get.put(WorkOrderListLogic());
  final state = Get.find<WorkOrderListLogic>().state;
  var tecWorkBarCode = TextEditingController();
  var tecPlanOrderNumber = TextEditingController();

  //组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.sapGroup,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.sapGroup}',
  );

  //日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.workOrderList.name}${PickerType.endDate}',
  );

  Card _item(WorkOrderInfo data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              data.getStateName(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: data.getStateColor(),
              ),
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'work_order_list_dispatch_order_no'.tr,
                  text: data.orderBill ?? '',
                ),
                expandedTextSpan(
                  hint: 'work_order_list_type_body'.tr,
                  text: data.plantBody ?? '',
                )
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'work_order_list_dispatch_date'.tr,
                  text: data.orderDate ?? '',
                ),
                expandedTextSpan(
                  hint: 'work_order_list_total'.tr,
                  text: data.workNumberTotal.toDoubleTry().toShowString(),
                )
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'work_order_list_process'.tr,
                  text: data.processFlowName ?? '',
                ),
                expandedTextSpan(
                  hint: 'work_order_list_group'.tr,
                  text: data.group ?? '',
                )
              ],
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < data.mtonoInfos!.length; ++i)
              Row(
                children: [
                  expandedTextSpan(
                    hint: 'work_order_list_sales_order_no'.tr,
                    text: data.mtonoInfos![i].planBill ?? '',
                    textColor: Colors.green,
                  ),
                  expandedTextSpan(
                    hint: 'work_order_list_qty'.tr,
                    text: data.mtonoInfos![i].workNumberTotal
                        .toDoubleTry()
                        .toShowString(),
                    textColor: Colors.green,
                  )
                ],
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                if (data.codeInfos != null && data.codeInfos!.isNotEmpty)
                  Expanded(
                    child: CombinationButton(
                      text: 'work_order_list_generated_label'.tr,
                      click: () => _labelListDialog(data.codeInfos!),
                      combination: Combination.left,
                    ),
                  ),
                Expanded(
                  child: CombinationButton(
                    text: 'work_order_list_last_label'.tr,
                    click: () {
                      if (checkUserPermission('1051105')) {
                        Get.to(() => const MaintainLabelPage(), arguments: {
                          'materialCode': data.materialCode,
                          'interID': data.interID,
                          'isMaterialLabel': false,
                        });
                      } else {
                        showSnackBar(
                          message:
                              'work_order_list_no_last_label_permission'.tr,
                          isWarning: true,
                        );
                      }
                    },
                    combination:
                        data.codeInfos != null && data.codeInfos!.isNotEmpty
                            ? Combination.middle
                            : Combination.left,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: 'work_order_list_individual_item_label'.tr,
                    click: () {
                      state.orderId = data.orderBill ?? '';
                      if (checkUserPermission('1051107')) {
                        Get.to(const PartPickPage());
                      } else {
                        showSnackBar(
                          message:
                              'work_order_list_no_individual_item_label_permission'
                                  .tr,
                          isWarning: true,
                        );
                      }
                    },
                    combination: Combination.right,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  _labelListDialog(List<CodeInfo> labels) {
    Get.dialog(
      PopScope(
          canPop: false,
          child: AlertDialog(
            title: Text('work_order_list_generated_label'.tr),
            content: SizedBox(
              width: MediaQuery.of(Get.overlayContext!).size.width * 0.8,
              height: MediaQuery.of(Get.overlayContext!).size.height * 0.8,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: labels.length,
                itemBuilder: (context, index) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(child: Text(labels[index].partNames ?? '')),
                        Text(labels[index].codeQty.toShowString())
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'work_order_list_back'.tr,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: 'work_order_list_work_ticket_barcode'.tr,
          controller: tecWorkBarCode,
        ),
        EditText(
          hint: 'work_order_list_plan_track_number'.tr,
          controller: tecPlanOrderNumber,
        ),
        OptionsPicker(pickerController: pcGroup),
        DatePicker(pickerController: pcStartDate),
        DatePicker(pickerController: pcEndDate),
        SwitchButton(
          onChanged: (isSelect) {
            setState(() => state.isOutsourcing = isSelect);
            spSave('${Get.currentRoute}/isOutsourcing', isSelect);
          },
          name: 'work_order_list_outsource'.tr,
          value: state.isOutsourcing,
        ),
        SwitchButton(
          onChanged: (isSelect) {
            setState(() => state.isClosed = isSelect);
            spSave('${Get.currentRoute}/isClosed', isSelect);
          },
          name: 'work_order_list_is_closed'.tr,
          value: state.isClosed,
        )
      ],
      query: () => logic.query(
        startDate: pcStartDate.getDateFormatYMD(),
        endDate: pcEndDate.getDateFormatYMD(),
        group: pcGroup.selectedId.value,
        workBarCode: tecWorkBarCode.text,
        planOrderNumber: tecPlanOrderNumber.text,
      ),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (context, index) => _item(state.dataList[index]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkOrderListLogic>();
    super.dispose();
  }
}
