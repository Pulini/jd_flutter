import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_dialog.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_modify_label_worker_view.dart';
import 'package:jd_flutter/fun/dispatching/process_dispatch_register/process_dispatch_register_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'process_dispatch_register_logic.dart';

class ProcessDispatchRegisterPage extends StatefulWidget {
  const ProcessDispatchRegisterPage({super.key});

  @override
  State<ProcessDispatchRegisterPage> createState() =>
      _ProcessDispatchRegisterPageState();
}

class _ProcessDispatchRegisterPageState
    extends State<ProcessDispatchRegisterPage> {
  final ProcessDispatchRegisterLogic logic =
      Get.put(ProcessDispatchRegisterLogic());
  final ProcessDispatchRegisterState state =
      Get.find<ProcessDispatchRegisterLogic>().state;

  TextEditingController controller = TextEditingController();

  itemList1() {
    var listWidget = <Widget>[];
    var totalDayMustQty = 0.0;
    var totalMustQty = 0.0;
    var totalQty = 0.0;
    listWidget.add(Row(
      children: [
        expandedFrameText(
          text: 'process_dispatch_register_sales_order_no'.tr,
          flex: 3,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_size'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.center,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_daily_dispatch_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_dispatched'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_quantity'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
      ],
    ));
    for (var list in state.orderList) {
      for (var data in list) {
        totalDayMustQty = totalDayMustQty.add(data.dayMustQty ?? 0);
        totalMustQty = totalMustQty.add(data.mustQty ?? 0);
        totalQty = totalQty.add(data.qty.sub(data.mustQty ?? 0));
        listWidget.add(Row(
          children: [
            expandedFrameText(
              text: data.instructions ?? '',
              flex: 3,
              isBold: true,
              backgroundColor: Colors.white,
            ),
            expandedFrameText(
              text: data.size ?? '',
              isBold: true,
              alignment: Alignment.center,
              backgroundColor: Colors.white,
            ),
            expandedFrameText(
              text: data.dayMustQty.toShowString(),
              alignment: Alignment.centerRight,
              isBold: true,
              backgroundColor: Colors.white,
            ),
            expandedFrameText(
              text: data.mustQty.toShowString(),
              alignment: Alignment.centerRight,
              isBold: true,
              backgroundColor: Colors.white,
            ),
            expandedFrameText(
              text: data.qty.sub(data.mustQty ?? 0).toShowString(),
              alignment: Alignment.centerRight,
              isBold: true,
              backgroundColor: Colors.white,
            ),
          ],
        ));
      }
    }
    listWidget.add(Row(
      children: [
        expandedFrameText(
          text: 'process_dispatch_register_total'.tr,
          flex: 4,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalDayMustQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalMustQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
      ],
    ));
    return listWidget;
  }

  itemList2() {
    var listWidget = <Widget>[];
    var totalDayMustQty = 0.0;
    var totalMustQty = 0.0;
    var totalQty = 0.0;
    listWidget.add(Row(
      children: [
        expandedFrameText(
          text: 'process_dispatch_register_report'.tr,
          flex: 3,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_size'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.center,
          isBold: true,
        ),
        expandedFrameText(
          padding: const EdgeInsets.only(bottom: 5, top: 5),
          text: 'process_dispatch_register_daily_dispatch_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_dispatched'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
        expandedFrameText(
          text: 'process_dispatch_register_quantity'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          alignment: Alignment.centerRight,
          isBold: true,
        ),
      ],
    ));

    for (var list in state.orderList) {
      var salesOrderList = <String>[];
      var dayMustQty = 0.0;
      var mustQty = 0.0;
      var qty = 0.0;
      for (var data in list) {
        dayMustQty = dayMustQty.add(data.dayMustQty ?? 0);
        mustQty = mustQty.add(data.mustQty ?? 0);
        qty = qty.add(data.qty.sub(data.mustQty ?? 0));
        salesOrderList.add(data.instructions ?? '');
      }
      listWidget.add(Row(
        children: [
          expandedFrameText(
            text: salesOrderList.join(','),
            flex: 3,
            isBold: true,
            backgroundColor: Colors.white,
            click: () => showSalesOrderListDialog(salesOrderList),
          ),
          expandedFrameText(
            text: list[0].size ?? '',
            isBold: true,
            alignment: Alignment.center,
            backgroundColor: Colors.white,
          ),
          expandedFrameText(
            text: dayMustQty.toShowString(),
            alignment: Alignment.centerRight,
            isBold: true,
            backgroundColor: Colors.white,
          ),
          expandedFrameText(
            text: mustQty.toShowString(),
            alignment: Alignment.centerRight,
            isBold: true,
            backgroundColor: Colors.white,
          ),
          expandedFrameText(
            text: qty.toShowString(),
            alignment: Alignment.centerRight,
            isBold: true,
            backgroundColor: Colors.white,
          ),
        ],
      ));
      totalDayMustQty = totalDayMustQty.add(dayMustQty);
      totalMustQty = totalMustQty.add(mustQty);
      totalQty = totalQty.add(qty);
    }
    listWidget.add(Row(
      children: [
        expandedFrameText(
          text: 'process_dispatch_register_total'.tr,
          flex: 4,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalDayMustQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalMustQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
        expandedFrameText(
          text: totalQty.toShowString(),
          alignment: Alignment.centerRight,
          isBold: true,
          textColor: Colors.blue,
          backgroundColor: Colors.blue.shade50,
        ),
      ],
    ));
    return listWidget;
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) {controller.text = code; logic.queryOrder(code);},
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () => state.isDetails.value = !state.isDetails.value,
          child: Text('process_dispatch_register_report'.tr),
        )
      ],
      body: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EditText(
              hint:
                  'process_dispatch_register_work_ticket_or_production_dispatch_order'
                      .tr,
              controller: controller,
            ),
            if (state.typeBody.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8),
                child: textSpan(
                    hint: 'process_dispatch_register_type_body'.tr,
                    text: state.typeBody.value),
              ),
            if (state.progress.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(left: 8, right: 8),
                child: textSpan(
                    hint: 'process_dispatch_register_process'.tr,
                    text: state.progress.value),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: state.isDetails.value ? itemList1() : itemList2(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    text: 'process_dispatch_register_query'.tr,
                    isEnabled: controller.text.isNotEmpty,
                    click: () => logic.queryOrder(controller.text),
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: 'process_dispatch_register_replace'.tr,
                    click: () =>
                        Get.to(() => const ModifyLabelWorkerPage())?.then(
                      (v) => pdaScanner(
                        scan: (code) =>
                            {controller.text = code, logic.queryOrder(code)},
                      ),
                    ),
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: state.isDetails.value
                        ? 'process_dispatch_register_summary'.tr
                        : 'process_dispatch_register_detail'.tr,
                    click: () => state.isDetails.value = !state.isDetails.value,
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: 'process_dispatch_register_print_label'.tr,
                    click: () => logic.goPrintLabel(),
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

  @override
  void dispose() {
    Get.delete<ProcessDispatchRegisterLogic>();
    super.dispose();
  }
}
