import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_info.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_dialogs.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:jd_flutter/widget/web_page.dart';
import 'package:marquee/marquee.dart';

import 'production_dispatch_logic.dart';
import 'package:jd_flutter/route.dart';

class ProductionDispatchPage extends StatefulWidget {
  const ProductionDispatchPage({super.key});

  @override
  State<ProductionDispatchPage> createState() => _ProductionDispatchPageState();
}

class Person {
  String name;
  double height;

  Person(this.name, this.height);
}

class _ProductionDispatchPageState extends State<ProductionDispatchPage> {
  final logic = Get.put(ProductionDispatchLogic());
  final state = Get.find<ProductionDispatchLogic>().state;

  var itemTitleStyle = const TextStyle(color: Colors.white, fontSize: 16);

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.productionDispatch.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.productionDispatch.name}${PickerType.endDate}',
  );

  var tecInstruction = TextEditingController();

  List<Widget> _queryWidgets() {
    return [
      EditText(
        hint: 'production_dispatch_instruction_hint'.tr,
        controller: tecInstruction,
      ),
      DatePicker(pickerController: dpcStartDate),
      DatePicker(pickerController: dpcEndDate),
      Obx(() => state.isSelectedMergeOrder.value
          ? Container()
          : SwitchButton(
              onChanged: (bool isSelect) {
                state.isSelectedOutsourcing.value = isSelect;
                spSave('${Get.currentRoute}/isSelectedOutsourcing', isSelect);
              },
              name: 'production_dispatch_query_show_outsourcing'.tr,
              value: state.isSelectedOutsourcing.value,
            )),
      Obx(() => SwitchButton(
            onChanged: (bool isSelect) {
              state.isSelectedClosed.value = isSelect;
              spSave('${Get.currentRoute}/isSelectedClosed', isSelect);
            },
            name: 'production_dispatch_query_show_close'.tr,
            value: state.isSelectedClosed.value,
          )),
      Obx(() => state.isSelectedMergeOrder.value
          ? Container()
          : SwitchButton(
              onChanged: (bool isSelect) {
                if (!isSelect && state.orderList.isNotEmpty) {
                  for (var value in state.orderList) {
                    value.select.value = false;
                  }
                }
                logic.refreshBottomButtons();
                state.isSelectedMany.value = isSelect;
                spSave('${Get.currentRoute}/isSelectedMany', isSelect);
              },
              name: 'production_dispatch_query_many_select'.tr,
              value: state.isSelectedMany.value,
            )),
      Obx(() => SwitchButton(
            onChanged: (bool isSelect) {
              if (isSelect) {
                state.isSelectedOutsourcing.value = false;
                state.isSelectedMany.value = false;
              }
              state.isSelectedMergeOrder.value = isSelect;
              spSave('${Get.currentRoute}/isSelectedMergeOrder', isSelect);
            },
            name: 'production_dispatch_query_merge_orders'.tr,
            value: state.isSelectedMergeOrder.value,
          )),
      Padding(
        padding: const EdgeInsets.all(10),
        child: CombinationButton(
          text: 'production_dispatch_query_progress'.tr,
          backgroundColor: Colors.green,
          click: () => logic.queryProgress(
            startTime: dpcStartDate.getDateFormatYMD(),
            endTime: dpcEndDate.getDateFormatYMD(),
            instruction: tecInstruction.text,
          ),
        ),
      )
    ];
  }

  Widget _item1(List<ProductionDispatchOrderInfo> list, int index) {
    var data = list[index];
    return GestureDetector(
      onTap: () => logic.item1click(index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: data.select.value ? Colors.green : Colors.blue.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'production_dispatch_dispatch_order_no'.trArgs([
                      data.sapOrderBill.ifEmpty(data.orderBill ?? ''),
                    ]),
                    style: itemTitleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_plan_tracking_number'.trArgs([
                      data.planBill ?? '',
                    ]),
                    style: itemTitleStyle,
                  ),
                ),
                if (data.plantBody?.isNotEmpty == true)
                  Expanded(
                    child: Text(
                      'production_dispatch_factory_type_body'.trArgs([
                        data.plantBody ?? '',
                      ]),
                      style: itemTitleStyle,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'production_dispatch_material'.trArgs([
                      data.materialCode ?? '',
                      data.materialName ?? '',
                    ]),
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (data.pastDay == true)
                  Text('production_dispatch_timeout'.tr,
                      style: const TextStyle(color: Colors.red)),
                Text(
                  _printStatusText(data.printStatus ?? ''),
                  style: TextStyle(color: _printTextColor(data.printStatus)),
                )
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'production_dispatch_total_order'.trArgs([
                      data.workNumberTotal.toShowString(),
                    ]),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_dispatch_date'.trArgs([
                      data.orderDate ?? '',
                    ]),
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_plan_start_date'.trArgs([
                      data.planStartTime ?? '',
                    ]),
                  ),
                ),
                Expanded(
                  child: Text('production_dispatch_plan_end_date'.trArgs([
                    data.planEndTime ?? '',
                  ])),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'production_dispatch_stock_in_qty'.trArgs([
                      data.stockInQty.toShowString(),
                    ]),
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_report_qty'.trArgs([
                      data.reportedNumber.toShowString(),
                    ]),
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_reported_not_record_working'.trArgs([
                      data.reportedUnscheduled.toShowString(),
                    ]),
                  ),
                ),
                Expanded(
                  child: Text(
                    'production_dispatch_record_working_not_stock_in'.trArgs([
                      data.reportedUnentered.toShowString(),
                    ]),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Text('production_dispatch_group'.trArgs([
                  data.group ?? '',
                ])),
                if (data.size?.isNotEmpty == true)
                  Expanded(
                    child: SizedBox(
                      height: 20,
                      child: Marquee(
                        text: data.getSizeText(),
                        scrollAxis: Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        blankSpace: 20,
                        startPadding: 200,
                        pauseAfterRound: const Duration(seconds: 1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Expanded _text(String text, Color backgroundColor) {
    return Expanded(
      child: Container(
        height: 30,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          color: backgroundColor,
        ),
        child: Text(text),
      ),
    );
  }

  Color _printTextColor(String? printStatus) {
    return printStatus == null
        ? Colors.red
        : printStatus == '1'
            ? Colors.orange
            : printStatus == '2'
                ? Colors.green
                : printStatus == '3'
                    ? Colors.blue
                    : Colors.red;
  }

  String _printStatusText(String printStatus) => printStatus == '1'
      ? 'production_dispatch_print_type_printed'.tr
      : printStatus == '2'
          ? 'production_dispatch_print_type_unprinted'.tr
          : printStatus == '3'
              ? 'production_dispatch_print_type_partial_printed'.tr
              : 'production_dispatch_print_type_error'.tr;

  Widget _item2(List<ProductionDispatchOrderInfo> list) {
    var data = list[0];
    var buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      side: WidgetStateProperty.all(
        BorderSide(
          color: _printTextColor(data.printStatus),
          width: 2,
        ),
      ),
    );

    var sumOfStockInQty = list
        .map((item) => item.stockInQty)
        .reduce((value, current) => value! + current!)
        .toShowString();

    var sumOfWorkNumberTotal = list
        .map((item) => item.workNumberTotal)
        .reduce((value, current) => value! + current!)
        .toShowString();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.blue.shade900,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'production_dispatch_dispatch_order_no'.trArgs([
                    data.sapOrderBill?.ifEmpty(data.orderBill ?? '') ?? '',
                  ]),
                  style: itemTitleStyle,
                ),
              ),
              if (data.plantBody?.isNotEmpty == true)
                Text(
                  'production_dispatch_type_body'.trArgs([
                    data.plantBody ?? '',
                  ]),
                  style: itemTitleStyle,
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          color: Colors.white,
          height: 40,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'production_dispatch_material'.trArgs([
                    data.materialCode ?? '',
                    data.materialName ?? '',
                  ]),
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => logic.materialLabelMaintenance(data),
                style: buttonStyle,
                child: Text(
                  _printStatusText(data.printStatus ?? ''),
                  style: TextStyle(color: _printTextColor(data.printStatus)),
                ),
              )
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 5, top: 5, right: 5),
          color: Colors.white,
          child: Row(
            children: [
              _text('production_dispatch_plan_tracking_number_tips'.tr,
                  Colors.blue.shade100),
              _text('production_dispatch_dispatch_date_tips'.tr,
                  Colors.blue.shade100),
              _text('production_dispatch_plan_start_date_tips'.tr,
                  Colors.blue.shade100),
              _text('production_dispatch_plan_end_date_tips'.tr,
                  Colors.blue.shade100),
              _text('production_dispatch_completed_tips'.tr,
                  Colors.blue.shade100),
            ],
          ),
        ),
        for (var i = 0; i < list.length; ++i)
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            color: Colors.white,
            child: Row(
              children: [
                _text(list[i].planBill ?? '', Colors.white),
                _text(list[i].orderDate ?? '', Colors.white),
                _text(list[i].planStartTime ?? '', Colors.white),
                _text(list[i].planEndTime ?? '', Colors.white),
                _text(list[i].getProgress(), Colors.white),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  'production_dispatch_group'.trArgs([
                    data.group ?? '',
                  ]),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Text('$sumOfStockInQty/$sumOfWorkNumberTotal'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomButtons() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      height: 40,
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.left,
                          isEnabled: state.cbIsEnabledMaterialList.value,
                          text: 'production_dispatch_bt_material_list'.tr,
                          click: () => logic.orderMaterialList(),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledInstruction.value,
                          text: 'production_dispatch_bt_instruction'.tr,
                          click: () => logic.instructionList(
                            (url) => Get.to(() => WebPage(url: url)),
                          ),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledProcessInstruction.value,
                          text: 'production_dispatch_bt_process_instruction'.tr,
                          click: () => logic.processSpecification(
                              manufactureInstructionsDialog),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledColorMatching.value,
                          text: 'production_dispatch_bt_color_matching'.tr,
                          click: () => logic.colorMatching(
                            (list, id) => colorListDialog(
                              list,
                              (s) => logic.getColorPdf(
                                s,
                                id,
                                (url) => Get.to(() => WebPage(url: url)),
                              ),
                            ),
                          ),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledProcessOpen.value,
                          text: state.cbNameProcess.value,
                          click: () =>
                              logic.offOnProcess(refresh: () => _query()),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledDeleteDownstream.value,
                          text: 'production_dispatch_bt_delete_downstream'.tr,
                          click: () =>
                              logic.deleteDownstream(refresh: () => _query()),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledDeleteLastReport.value,
                          text: 'production_dispatch_bt_delete_last_report'.tr,
                          click: () =>
                              logic.deleteLastReport(refresh: () => _query()),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledLabelMaintenance.value,
                          text: 'production_dispatch_bt_label_maintenance'.tr,
                          click: () => logic.labelMaintenance(),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledUpdateSap.value,
                          text: 'production_dispatch_bt_update_sap'.tr,
                          click: () => logic.updateSap(refresh: () => _query()),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.middle,
                          isEnabled: state.cbIsEnabledPrintMaterialHead.value,
                          text: 'production_dispatch_bt_print_material_head'.tr,
                          click: () => logic.getSurplusMaterial(
                            print: (list) => showSelectMaterialPopup(
                              surplusMaterialList: list,
                              print: (data) => logic.printSurplusMaterial(data),
                            ),
                          ),
                        ),
                  state.isSelectedMany.value
                      ? Container()
                      : CombinationButton(
                          combination: Combination.right,
                          isEnabled: state.cbIsEnabledReportSap.value,
                          text: 'production_dispatch_bt_report_sap'.tr,
                          click: () => sapReportDialog(
                            initQty: logic.getReportMax(),
                            callback: (qty) => logic.reportToSap(
                              qty: qty,
                              refresh: () => () => _query(),
                            ),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            CombinationButton(
              isEnabled: state.cbIsEnabledPush.value,
              text: 'production_dispatch_bt_push'.tr,
              click: () => logic.push(),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }

  dynamic _query() => logic.query(
      startTime: dpcStartDate.getDateFormatYMD(),
      endTime: dpcEndDate.getDateFormatYMD(),
      instruction: tecInstruction.text);

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: _queryWidgets(),
      query: () => _query(),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: state.isSelectedMergeOrder.value
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderGroupList.length,
                      itemBuilder: (c, i) => _item2(
                        state.orderGroupList.entries.elementAt(i++).value,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderList.length,
                      itemBuilder: (c, i) => _item1(state.orderList, i),
                    ),
            ),
            state.isSelectedMergeOrder.value
                ? Container()
                : state.orderList.isEmpty
                    ? Container()
                    : _bottomButtons()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ProductionDispatchLogic>();
    super.dispose();
  }
}
