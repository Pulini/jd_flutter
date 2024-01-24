import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

import '../../../http/response/production_dispatch_order_info.dart';
import '../../../route.dart';
import '../../../utils.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
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
        controller: logic.textControllerInstruction,
      ),
      DatePicker(pickerController: logic.pickerControllerStartDate),
      DatePicker(pickerController: logic.pickerControllerEndDate),
      SwitchButton(switchController: logic.switchControllerOutsourcing),
      SwitchButton(switchController: logic.switchControllerClosed),
      SwitchButton(switchController: logic.switchControllerMany),
      SwitchButton(switchController: logic.switchControllerMergeOrder),
      Padding(
        padding: const EdgeInsets.all(10),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {},
          child: Text(
            'production_dispatch_query_progress'.tr,
            style: const TextStyle(color: Colors.white),
          ),
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
      onTap: () {
        data.select = !data.select;
        if (!logic.switchControllerMany.isChecked.value) {
          for (var i = 0; i < list.length; ++i) {
            if (i != index && list[i].select) {
              list[i].select = false;
            }
          }
        }
        state.orderList.refresh();
      },
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
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      side: MaterialStateProperty.all(
        BorderSide(
          color: _printTextColor(data.printStatus),
          width: 1,
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
    var buttonsTextStyle = TextStyle(
        color: state.orderList.any((e) => e.select)
            ? Colors.blueAccent
            : Colors.red);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.green.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_material_list'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_instruction'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_color_matching'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_process_instruction'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_process_open'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_delete_downstream'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_delete_last_report'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_label_maintenance'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_update_sap'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_print_material_head'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'production_dispatch_bt_report_sap'.tr,
                    style: buttonsTextStyle,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.orderList.any((e) => e.select)
                  ? Colors.blueAccent
                  : Colors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: () {
              logic.push();
            },
            child: Text(
              'production_dispatch_bt_push'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      title: getFunctionTitle(),
      children: _queryWidgets(),
      query: () => logic.query(),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => logic.switchControllerMergeOrder.isChecked.value
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
          ),
          Obx(() => logic.switchControllerMergeOrder.isChecked.value
              ? Container()
              : _bottomButtons())
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ProductionDispatchLogic>();
    super.dispose();
  }
}
