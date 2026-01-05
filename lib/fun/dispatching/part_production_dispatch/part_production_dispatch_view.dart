import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'part_production_dispatch_logic.dart';
import 'part_production_dispatch_state.dart';

class PartProductionDispatchPage extends StatefulWidget {
  const PartProductionDispatchPage({super.key});

  @override
  State<PartProductionDispatchPage> createState() =>
      _PartProductionDispatchPageState();
}

class _PartProductionDispatchPageState
    extends State<PartProductionDispatchPage> {
  final PartProductionDispatchLogic logic =
      Get.put(PartProductionDispatchLogic());
  final PartProductionDispatchState state =
      Get.find<PartProductionDispatchLogic>().state;

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.partProductionDispatch.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.partProductionDispatch.name}${PickerType.endDate}',
  );

  var tecInstruction = TextEditingController();

  void _query() => logic.queryOrders(
        startTime: dpcStartDate.getDateFormatYMD(),
        endTime: dpcEndDate.getDateFormatYMD(),
        instruction: tecInstruction.text,
      );

  Widget _item(PartProductionDispatchOrderInfo data) => GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Row(children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textSpan(hint: '派工单号：', text: data.workCardNo ?? ''),
                  textSpan(hint: '派工日期：', text: data.date ?? ''),
                  textSpan(hint: '型体：', text: data.productName ?? ''),
                  textSpan(hint: '指令：', text: data.instruction ?? ''),
                  textSpan(hint: '部位：', text: data.processName ?? ''),
                  textSpan(hint: '尺码：', text: data.sizesQuantities ?? ''),
                  Row(
                    children: [
                      Text(
                        '生成贴标数量：',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Expanded(
                        child: progressIndicator(
                          max: 100,
                          value: 50,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              flex:3,
              child: Column(
                children: [

                ],
              ),
            ),
          ]),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        EditText(
          hint: '计划跟踪单号、指令、型体',
          controller: tecInstruction,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        Obx(() => SwitchButton(
              onChanged: (isSelect) => logic.changeClosedStatus(isSelect),
              name: '显示已关闭',
              value: state.isSelectedClosed.value,
            )),
      ],
      query: () => _query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(state.orderList[i]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<PartProductionDispatchLogic>();
    super.dispose();
  }
}
