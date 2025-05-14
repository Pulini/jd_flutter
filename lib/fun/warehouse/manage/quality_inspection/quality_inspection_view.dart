import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'quality_inspection_logic.dart';
import 'quality_inspection_state.dart';

class QualityInspectionPage extends StatefulWidget {
  const QualityInspectionPage({super.key});

  @override
  State<QualityInspectionPage> createState() => _QualityInspectionPageState();
}

class _QualityInspectionPageState extends State<QualityInspectionPage> {
  final QualityInspectionLogic logic = Get.put(QualityInspectionLogic());
  final QualityInspectionState state = Get.find<QualityInspectionLogic>().state;

  var queryStartDateController = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.qualityInspection.name}${PickerType.startDate}',
  );

  var queryEndDateController = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.qualityInspection.name}${PickerType.endDate}',
  );

  var reportStartDateController = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.qualityInspection.name}${PickerType.startDate}_report',
  );

  var reportEndDateController = DatePickerController(
    PickerType.endDate,
    saveKey:
        '${RouteConfig.qualityInspection.name}${PickerType.endDate}_report',
  );

  _query() {
    logic.queryOrders(
      startDate: queryStartDateController.getDateFormatSapYMD(),
      endDate: queryEndDateController.getDateFormatSapYMD(),
    );
  }

  Widget _item(QualityInspectionInfo data) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.green.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              expandedTextSpan(
                hint: '生产单位：',
                text: data.inspectionUnit ?? '',
                textColor: Colors.green.shade700,
              ),
              textSpan(
                hint: '异常数：',
                text: data.getAbnormalQty().toString(),
                textColor: Colors.red,
              ),
              const SizedBox(width: 20),
              textSpan(
                hint: '复检数：',
                text: data.getReInspectionQty().toString(),
                textColor: Colors.purple,
              ),
              const SizedBox(width: 20),
            ],
          ),
          const Divider(indent: 10, endIndent: 10),
          for (var order in data.groupOrder!) _subItem(order)
        ],
      ),
    );
  }

  _subItem(QualityInspectionOrderInfo data) {
    var textStyle = const TextStyle(color: Colors.black54);
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 65,
            margin: const EdgeInsets.only(left: 10, bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    expandedTextSpan(
                      hint: '指令号：',
                      hintColor: Colors.black54,
                      text: data.instructionNo ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    expandedTextSpan(
                      hint: 'PO号：',
                      hintColor: Colors.black54,
                      text: data.customerPo ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    expandedTextSpan(
                      hint: '型体：',
                      hintColor: Colors.black54,
                      text: data.typeBody ?? '',
                      textColor: Colors.blue.shade900,
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        data.getFlagText(),
                        style: TextStyle(
                          color: data.getFlagColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '质检日期：${data.inspectionDate}',
                        style: textStyle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '质检员：${data.inspector}',
                        style: textStyle,
                      ),
                    ),
                    expandedTextSpan(
                      hint: '异常数：',
                      hintColor: Colors.black54,
                      isBold: false,
                      text: data.abnormalQty.toString(),
                      textColor: Colors.red,
                    ),
                    SizedBox(
                      width: 80,
                      child: textSpan(
                        hint: '复检数：',
                        hintColor: Colors.black54,
                        isBold: false,
                        text: data.reInspectionQty.toString(),
                        textColor: Colors.purple,
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Container(
          width: 110,
          height: 65,
          margin: const EdgeInsets.only(right: 10, bottom: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            color: data.status == '4'
                ? Colors.green.shade400
                : Colors.blue.shade400,
          ),
          child: TextButton(
            onPressed: () => logic.getOrderDetail(
              workOrderNo: data.workOrderNo ?? '',
              refresh: _query,
            ),
            child: Text(
              data.status == '4' ? '质检完成' : '开始质检',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ],
    );
  }

  var inspectorNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      actions: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(25),
            color: Colors.white,
          ),
          margin: const EdgeInsets.only(right: 10),
          height: 45,
          width: MediaQuery.of(context).size.width * 0.4,
          child: Row(
            children: [
              Expanded(
                child: DatePicker(pickerController: reportStartDateController),
              ),
              Expanded(
                child: DatePicker(pickerController: reportEndDateController),
              ),
              CombinationButton(
                text: '查看质检汇总',
                click: () => logic.getInspectionReport(
                  startDate: reportStartDateController.getDateFormatSapYMD(),
                  endDate: reportEndDateController.getDateFormatSapYMD(),
                ),
              ),
            ],
          ),
        ),
      ],
      queryWidgets: [
        Obx(() => EditText(
              hint: '指令号',
              initStr: state.instructionNo.value,
              onChanged: (v) => state.instructionNo.value = v,
            )),
        Obx(() => EditText(
              hint: '型体',
              initStr: state.typeBody.value,
              onChanged: (v) => state.typeBody.value = v,
            )),
        Obx(() => EditText(
              hint: '客户PO',
              initStr: state.customerPO.value,
              onChanged: (v) => state.customerPO.value = v,
            )),
        DatePicker(pickerController: queryStartDateController),
        DatePicker(pickerController: queryEndDateController),
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
    Get.delete<QualityInspectionLogic>();
    super.dispose();
  }
}
