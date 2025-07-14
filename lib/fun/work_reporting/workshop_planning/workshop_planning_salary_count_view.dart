import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:marquee/marquee.dart';

class WorkshopPlanningSalaryCountPage extends StatefulWidget {
  const WorkshopPlanningSalaryCountPage({super.key});

  @override
  State<WorkshopPlanningSalaryCountPage> createState() =>
      _WorkshopPlanningSalaryCountPageState();
}

class _WorkshopPlanningSalaryCountPageState
    extends State<WorkshopPlanningSalaryCountPage> {
  final WorkshopPlanningLogic logic = Get.put(WorkshopPlanningLogic());
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;
  int index = Get.arguments['index'];
  var dpcDate = DatePickerController(PickerType.date, onChanged: (date) {});

  _workerItem(WorkshopPlanningWorkerInfo data, String flowProcessID) =>
      GestureDetector(
        onTap: () => logic.modifyWorker(flowProcessID,data),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade100,
                Colors.blue.shade100,
              ],
            ),
          ),
          margin: const EdgeInsets.all(5),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${data.name}(${data.number})<${data.typeOfWork}>',
                    ),
                  ),
                  Text(
                    data.attendanceStatus == true ? '已考勤' : '未考勤',
                    style: TextStyle(
                      color: data.attendanceStatus == true
                          ? Colors.green
                          : Colors.red,
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    isBold: false,
                    hint: '系数：',
                    text: data.base.toShowString(),
                  ),
                  textSpan(
                    isBold: false,
                    hint: '工时：',
                    text: data.dayWorkTime.toShowString(),
                  ),
                  textSpan(
                    isBold: false,
                    hint: '金额：',
                    text: data.money.value.toShowString(),
                  ),
                ],
              )
            ],
          ),
        ),
      );

  _addWorkerItem(String flowProcessID) => GestureDetector(
        onTap: () => logic.addWorker(flowProcessID),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.orange,
          ),
          margin: const EdgeInsets.all(5),
          height: 30,
          child: const Center(
            child: Icon(
              Icons.add_circle_outlined,
              color: Colors.white,
            ),
          ),
        ),
      );

  @override
  initState() {
    logic.setReportQuantity(index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logic.getGroupData(index: index, date: dpcDate.getDateFormatYMD());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var data = state.planList[index];
    return pageBody(
      title: '团件计工',
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.save, color: Colors.blue),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.refresh, color: Colors.blue),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Text(
                    '物料：',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Marquee(
                      text: data.materialName ?? '',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700),
                      scrollAxis: Axis.horizontal,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      blankSpace: 50,
                      // pauseAfterRound: const Duration(seconds: 1),
                    ),
                  )
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: '单号：',
                  text: data.planTrackingNumber ?? '',
                  isBold: false,
                  textColor: Colors.blue.shade900,
                ),
                textSpan(
                  hint: '组别：',
                  text: state.groupName,
                  isBold: false,
                  textColor: Colors.blue.shade900,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: '工序：',
                  text: data.processName ?? '',
                  isBold: false,
                  textColor: Colors.blue.shade900,
                ),
                textSpan(
                  hint: '数量：',
                  text: state.reportQuantity.value.toShowString(),
                  isBold: false,
                  textColor: Colors.blue.shade900,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DatePicker(pickerController: dpcDate),
                  ),
                  Expanded(
                    child: Obx(() => CheckBox(
                          onChanged: (v) => state.isDayShift.value = true,
                          name: '昼班',
                          value: state.isDayShift.value,
                        )),
                  ),
                  Expanded(
                    child: Obx(() => CheckBox(
                          onChanged: (v) => state.isDayShift.value = false,
                          name: '夜班',
                          value: !state.isDayShift.value,
                        )),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                ),
                child: Obx(() => ListView(
                      children: [
                        for (var item in state.reportWorkerList)
                          _workerItem(item, data.flowProcessID ?? ''),
                        _addWorkerItem(data.flowProcessID ?? ''),
                      ],
                    )),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    text: '查看工序',
                    click: () {},
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: '报工列表',
                    click: () {},
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    text: '提交报工',
                    click: () {},
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
}
