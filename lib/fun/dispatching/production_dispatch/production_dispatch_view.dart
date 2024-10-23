import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_dialogs.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:marquee/marquee.dart';

import '../../../bean/http/response/production_dispatch_order_info.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/edit_text_widget.dart';
import '../../../widget/picker/picker_view.dart';
import '../../../widget/switch_button_widget.dart';
import '../../../widget/web_page.dart';
import 'production_dispatch_logic.dart';

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

  _queryWidgets() {
    return [
      EditText(
        hint: 'production_dispatch_instruction_hint'.tr,
        onChanged: (v) => state.etInstruction = v,
      ),
      DatePicker(pickerController: logic.dpcStartDate),
      DatePicker(pickerController: logic.dpcEndDate),
      if (!state.isSelectedMergeOrder)
        SwitchButton(
          onChanged: (bool isSelect) {
            setState(() => state.isSelectedOutsourcing = isSelect);
            spSave('${Get.currentRoute}/isSelectedOutsourcing', isSelect);
          },
          name: 'production_dispatch_query_show_outsourcing'.tr,
          value: state.isSelectedOutsourcing,
        ),
      SwitchButton(
        onChanged: (bool isSelect) {
          setState(() => state.isSelectedClosed = isSelect);
          spSave('${Get.currentRoute}/isSelectedClosed', isSelect);
        },
        name: 'production_dispatch_query_show_close'.tr,
        value: state.isSelectedClosed,
      ),
      if (!state.isSelectedMergeOrder)
        SwitchButton(
          onChanged: (bool isSelect) {
            if (!isSelect && state.orderList.isNotEmpty) {
              for (var value in state.orderList) {
                value.select = false;
              }
              state.orderList.refresh();
            }
            logic.refreshBottomButtons();
            setState(() => state.isSelectedMany = isSelect);
            spSave('${Get.currentRoute}/isSelectedMany', isSelect);
          },
          name: 'production_dispatch_query_many_select'.tr,
          value: state.isSelectedMany,
        ),
      SwitchButton(
        onChanged: (bool isSelect) {
          if (isSelect) {
            state.isSelectedOutsourcing = false;
            state.isSelectedMany = false;
          }
          setState(() {
            state.isSelectedMergeOrder = isSelect;
          });
          spSave('${Get.currentRoute}/isSelectedMergeOrder', isSelect);
        },
        name: 'production_dispatch_query_merge_orders'.tr,
        value: state.isSelectedMergeOrder,
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: CombinationButton(
          text: 'production_dispatch_query_progress'.tr,
          backgroundColor: Colors.green,
          click: () {},
        ),
      )
    ];
  }

  _item1(List<ProductionDispatchOrderInfo> list, int index) {
    var data = list[index];
    String printText = data.printStatus == '1'
        ? '已打印'
        : data.printStatus == '2'
            ? '未打印'
            : data.printStatus == '3'
                ? '部分打印'
                : '状态异常';
    return GestureDetector(
      onTap: () => logic.item1click(index),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: data.select ? Colors.green : Colors.blue.shade900,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '派工单号：${data.sapOrderBill ?? data.orderBill}',
                    style: itemTitleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    '计划跟踪单号：${data.planBill}',
                    style: itemTitleStyle,
                  ),
                ),
                if (data.plantBody?.isNotEmpty == true)
                  Expanded(
                    child: Text(
                      '工厂型体：${data.plantBody}',
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
                    '物料描述：(${data.materialCode})${data.materialName}',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (data.pastDay == true)
                  const Text('超时', style: TextStyle(color: Colors.red)),
                Text(
                  printText,
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
                    '订单总量：${data.workNumberTotal.toShowString()}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                Expanded(
                  child: Text(
                    '派工日期：${data.orderDate}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '计划开工日期：${data.planStartTime}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '计划完工日期：${data.planEndTime}',
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
                    '已入库数：${data.stockInQty.toShowString()}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '已汇报数：${data.reportedNumber.toShowString()}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '已汇报未计工数：${data.reportedUnscheduled.toShowString()}',
                  ),
                ),
                Expanded(
                  child: Text(
                    '已计工未入库数：${data.reportedUnentered.toShowString()}',
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
                Text('所属课组：${data.group}'),
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

  _text(String text, Color backgroundColor) {
    return Expanded(
      child: Container(
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

  _printTextColor(String? printStatus) {
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

  _item2(List<ProductionDispatchOrderInfo> list) {
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

    String printText = data.printStatus == '1'
        ? '已打印'
        : data.printStatus == '2'
            ? '未打印'
            : data.printStatus == '3'
                ? '部分打印'
                : '状态异常';

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
                  '派工单号：${data.sapOrderBill ?? data.orderBill}',
                  style: itemTitleStyle,
                ),
              ),
              if (data.plantBody?.isNotEmpty == true)
                Text(
                  '型体：${data.plantBody}',
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
                  '物料描述：(${data.materialCode})${data.materialName}',
                  style: TextStyle(
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                style: buttonStyle,
                child: Text(
                  printText,
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
              _text('计划跟踪单号', Colors.blue.shade100),
              _text('派工日期', Colors.blue.shade100),
              _text('计划开工日期', Colors.blue.shade100),
              _text('计划完工日期', Colors.blue.shade100),
              _text('完成量', Colors.blue.shade100),
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
              Expanded(flex: 4, child: Text('所属课组:${data.group}')),
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

  _bottomButtons() {
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
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.left,
                      isEnabled: state.cbIsEnabledMaterialList.value,
                      text: 'production_dispatch_bt_material_list'.tr,
                      click: () => logic.orderMaterialList(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledInstruction.value,
                      text: 'production_dispatch_bt_instruction'.tr,
                      click: () => logic.instructionList(
                        (url) => Get.to(()=>WebPage(title: '', url: url)),
                      ),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledProcessInstruction.value,
                      text: 'production_dispatch_bt_process_instruction'.tr,
                      click: () => logic
                          .processSpecification(manufactureInstructionsDialog),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledColorMatching.value,
                      text: 'production_dispatch_bt_color_matching'.tr,
                      click: () => logic.colorMatching(
                        (list, id) => colorListDialog(
                          list,
                          (s) => logic.getColorPdf(
                            s,
                            id,
                            (url) => Get.to(()=>WebPage(title: '', url: url)),
                          ),
                        ),
                      ),
                    ),
                  if (state.orderList.any((e) => e.select) &&
                      !state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledProcessOpen.value,
                      text: state.cbNameProcess.value,
                      click: () => logic.offOnProcess(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledDeleteDownstream.value,
                      text: 'production_dispatch_bt_delete_downstream'.tr,
                      click: () => logic.deleteDownstream(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledDeleteLastReport.value,
                      text: 'production_dispatch_bt_delete_last_report'.tr,
                      click: () => logic.deleteLastReport(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledLabelMaintenance.value,
                      text: 'production_dispatch_bt_label_maintenance'.tr,
                      click: () => logic.labelMaintenance(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledUpdateSap.value,
                      text: 'production_dispatch_bt_update_sap'.tr,
                      click: () => logic.updateSap(),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.middle,
                      isEnabled: state.cbIsEnabledPrintMaterialHead.value,
                      text: 'production_dispatch_bt_print_material_head'.tr,
                      click: () =>
                          logic.getSurplusMaterial(showSelectMaterialPopup),
                    ),
                  if (!state.isSelectedMany)
                    CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.cbIsEnabledReportSap.value,
                      text: 'production_dispatch_bt_report_sap'.tr,
                      click: () => sapReportDialog(
                        logic.getReportMax(),
                        logic.reportToSap,
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

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: _queryWidgets(),
      query: () => logic.query(),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: state.isSelectedMergeOrder
                  ? ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderGroupList.length,
                      itemBuilder: (BuildContext context, int index) => _item2(
                          state.orderGroupList.entries
                              .elementAt(index++)
                              .value),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.orderList.length,
                      itemBuilder: (BuildContext context, int index) =>
                          _item1(state.orderList, index),
                    ),
            ),
            state.isSelectedMergeOrder ? Container() : _bottomButtons()
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
