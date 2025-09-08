import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
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
    extends State<WorkshopPlanningSalaryCountPage>
    with SingleTickerProviderStateMixin {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;
  late DatePickerController dpcDate;
  late TabController tabController = TabController(length: 2, vsync: this);
  var pageController = PageController();

  _processItemTitle() => Row(
        children: [
          expandedFrameText(
            text: '尺码',
            borderColor: Colors.white,
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.deepPurpleAccent.shade200,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            flex: 2,
            text: '订单数量',
            borderColor: Colors.white,
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.deepPurpleAccent.shade200,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            flex: 2,
            text: '累计报工数',
            borderColor: Colors.white,
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.deepPurpleAccent.shade200,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            flex: 2,
            text: '未报工数',
            borderColor: Colors.white,
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.deepPurpleAccent.shade200,
            alignment: Alignment.center,
          ),
          expandedFrameText(
            flex: 2,
            text: '本次报工数',
            borderColor: Colors.white,
            textColor: Colors.white,
            padding: EdgeInsets.zero,
            backgroundColor: Colors.deepPurpleAccent.shade200,
            alignment: Alignment.center,
          ),
        ],
      );

  _processItem(WorkshopPlanningSizeInfo item) {
    var controller = TextEditingController(text: item.qty.toShowString());
    return Row(
      children: [
        expandedFrameText(
          text: item.size ?? '',
          borderColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700,
          textColor: Colors.white,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          flex: 2,
          text: item.processQty.toShowString(),
          borderColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700,
          textColor: Colors.white,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          flex: 2,
          text: item.finishQty.toShowString(),
          borderColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700,
          textColor: Colors.white,
          alignment: Alignment.center,
        ),
        expandedFrameText(
          flex: 2,
          text: item.unFinishQty.toShowString(),
          borderColor: Colors.white,
          backgroundColor: Colors.deepPurple.shade700,
          textColor: Colors.white,
          alignment: Alignment.center,
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: 35,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              color: Colors.deepPurple.shade700,
            ),
            alignment: Alignment.center,
            child: state.planInfo!.allowEdit == true
                ? TextField(
                    style: TextStyle(color: Colors.deepPurple.shade700),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                    ],
                    controller: controller,
                    onChanged: (v) {
                      if (!v.contains('.')) {
                        controller.text = v.toDoubleTry().toShowString();
                      }
                      if (v.split('.').length > 2 && v.endsWith('.')) {
                        controller.text = v.substring(0, v.length - 1);
                      }
                      if (v.toDoubleTry() > (item.unFinishQty ?? 0)) {
                        controller.text = item.unFinishQty.toShowString();
                      }
                      item.qty = v.toDoubleTry();
                      logic.setWorkerMoney();
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(
                        top: 0,
                        bottom: 0,
                        left: 10,
                        right: 10,
                      ),
                      filled: true,
                      fillColor: Colors.grey[300],
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(color: Colors.transparent),
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                    ),
                  )
                : Text(
                    item.qty.toShowString(),
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
          ),
        )
      ],
    );
  }

  _workerItem(WorkshopPlanningWorkerInfo data) => GestureDetector(
        onTap: () => logic.modifyWorker(data),
        child: Container(
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
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
          ),
          margin: const EdgeInsets.all(5),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
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
                        Obx(() => Row(
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
                            ))
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 30,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(7),
                      bottomRight: Radius.circular(7),
                    ),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => askDialog(
                      content: '确定要删除该组员数据吗？',
                      confirm: () => logic.deleteReportWorker(data),
                    ),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  addWorkerItem({required Function() click}) => GestureDetector(
        onTap: click,
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

  _queryGroupData() {
    logic.getGroupData(date: dpcDate.getDateFormatYMD());
  }

  @override
  initState() {
    state.submitButtonName.value = '提交报工';
    dpcDate = DatePickerController(PickerType.date, onChanged: (date) {
      if (state.planInfo!.planTrackingNumber?.isNotEmpty == true) {
        _queryGroupData();
      }
      if (state.planInfo!.allowEdit == false) {
        state.planInfo!.sizeLists?.forEach((v) => v.qty = 0);
      }
    });
    logic.setWorkerMoney();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queryGroupData();
    });
    logic.getWorkshopPlanningWorkersCache();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '团件计工',
      popTitle: '确定要退出本次团件计工吗？',
      actions: [
        Obx(() => state.workersCache.isNotEmpty
            ? IconButton(
                onPressed: () => logic.useWorkersCache(),
                icon: const Icon(Icons.save, color: Colors.blue),
              )
            : Container()),
        IconButton(
          onPressed: () => _queryGroupData(),
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
                  const Text(
                    '物料：',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Expanded(
                    child: Marquee(
                      text: state.planInfo!.materialName ?? '',
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
                  text: state.planInfo!.planTrackingNumber ?? '',
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
                  text: state.planInfo!.processName ?? '',
                  isBold: false,
                  textColor: Colors.blue.shade900,
                ),
                Obx(() => textSpan(
                      hint: '数量：',
                      text: state.reportQuantity.value.toShowString(),
                      isBold: false,
                      textColor: Colors.blue.shade900,
                    )),
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
            TabBar(
              dividerColor: Colors.blueAccent,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              controller: tabController,
              tabs: const [
                Tab(text: '工序'),
                Tab(text: '报工'),
              ],
              onTap: (i) => pageController.jumpToPage(i),
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                onPageChanged: (i) => tabController.animateTo(i),
                scrollDirection: Axis.horizontal,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      _processItemTitle(),
                      Expanded(
                        child: ListView.builder(
                          itemCount: state.planInfo!.sizeLists!.length,
                          itemBuilder: (c, i) =>
                              _processItem(state.planInfo!.sizeLists![i]),
                        ),
                      )
                    ],
                  ),
                  Obx(() => ListView(
                        children: [
                          for (var item in state.reportWorkerList)
                            _workerItem(item),
                          addWorkerItem(click: () => logic.addWorker()),
                        ],
                      )),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    combination: Combination.left,
                    text: '报工列表',
                    click: () => logic.getGroupPayList(),
                  ),
                ),
                Expanded(
                  child: Obx(() => CombinationButton(
                        text: state.submitButtonName.value,
                        click: () => logic.submitWorkersReport(),
                        combination: Combination.right,
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
