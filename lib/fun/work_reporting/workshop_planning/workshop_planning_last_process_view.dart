import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_dialog.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

class WorkshopPlanningLastProcessPage extends StatefulWidget {
  const WorkshopPlanningLastProcessPage({super.key});

  @override
  State<WorkshopPlanningLastProcessPage> createState() =>
      _WorkshopPlanningLastProcessPageState();
}

class _WorkshopPlanningLastProcessPageState
    extends State<WorkshopPlanningLastProcessPage>
    with SingleTickerProviderStateMixin {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;
  late OptionsPickerController opcProcessFlow;

  late DatePickerController dpcDate;
  late TabController tabController = TabController(length: 3, vsync: this);
  var pageController = PageController();
  late Worker materialListener;

  _materialItem(WorkshopPlanningMaterialInfo data) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade100, Colors.blue.shade100],
          ),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        margin: const EdgeInsets.all(5),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    '(${data.number}) ${data.name}'.allowWordTruncation(),
                    maxLines: 4,
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
                  onPressed: () => logic.deleteMaterial(data),
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );

  _processItem(WorkshopPlanningLastProcessInfo data) {
    var width = getScreenSize().width - 20;
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: Colors.white,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    textSpan(
                      hint: '单号：',
                      text: data.planTrackingNumber ?? '',
                    ),
                    Text('尺码：${data.size}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('订单数：${data.processQty.toShowString()}'),
                    Text('已报工数：${data.finishQty.toShowString()}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('未报工数：${data.unFinishQty.toShowString()}'),
                    Text('报工数：${data.qty.toShowString()}'),
                  ],
                ),
              ],
            )),
        Row(
          children: [
            AnimatedContainer(
              margin: const EdgeInsets.only(bottom: 10),
              height: 5,
              width: width * (data.finishQty! / data.processQty!),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(5),
                  bottomRight: data.processQty == data.finishQty
                      ? const Radius.circular(5)
                      : Radius.zero,
                ),
                color: Colors.blue,
              ),
            ),
            AnimatedContainer(
              margin: const EdgeInsets.only(bottom: 10),
              height: 5,
              width: width *
                  ((data.processQty! - data.finishQty!) / data.processQty!),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: data.finishQty == 0
                      ? const Radius.circular(5)
                      : Radius.zero,
                  bottomRight: const Radius.circular(5),
                ),
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _workerItem(WorkshopPlanningWorkerInfo data) => GestureDetector(
        onTap: () => logic.lastProcessModifyWorker(
          data,
          opcProcessFlow.getPickItem().pickerId(),
          dpcDate.getDateFormatYMD(),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomRight,
              colors: [Colors.green.shade100, Colors.blue.shade100],
            ),
            border: Border.all(color: Colors.blue, width: 2),
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

  _addItem({required Function() click}) => GestureDetector(
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

  refreshMaterialAndProcessDetails() {
    Future.delayed(const Duration(milliseconds: 500), () {
      logic.refreshMaterialAndProcessDetails(
        date: dpcDate.getDateFormatYMD(),
        processFlow: opcProcessFlow.getPickItem().pickerId(),
      );
    });
  }

  @override
  void initState() {
    dpcDate = DatePickerController(
      PickerType.date,
      onChanged: (date) => refreshMaterialAndProcessDetails(),
    );
    opcProcessFlow = OptionsPickerController(
      PickerType.mesProcessFlow,
      saveKey:
          '${RouteConfig.workshopPlanning.name}${PickerType.mesProcessFlow}',
      onSelected: (v) => refreshMaterialAndProcessDetails(),
    );
    materialListener = ever(state.lastProcessMaterialList, (v) {
      logic.getLastProcessProduction(
        date: dpcDate.getDateFormatYMD(),
        processFlow: opcProcessFlow.getPickItem().pickerId(),
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    materialListener.dispose();
    logic.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '末道计工',
      popTitle: '确定要退出本次末道计工吗？',
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(hint: '组别：', text: state.groupName),
                Obx(() => CheckBox(
                      onChanged: (v) => state.isDayShift.value = true,
                      name: '昼班',
                      value: state.isDayShift.value,
                    )),
                Obx(
                  () => CheckBox(
                    onChanged: (v) => state.isDayShift.value = false,
                    name: '夜班',
                    value: !state.isDayShift.value,
                  ),
                ),
              ],
            ),
            OptionsPicker(pickerController: opcProcessFlow),
            DatePicker(pickerController: dpcDate),
            TabBar(
              dividerColor: Colors.blueAccent,
              indicatorColor: Colors.blueAccent,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.grey,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              controller: tabController,
              tabs: [
                Tab(text: '物料'),
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
                  Obx(() => ListView(
                        children: [
                          for (var item in state.lastProcessMaterialList)
                            _materialItem(item),
                          _addItem(
                            click: () => materialDialog(
                              addedList: state.lastProcessMaterialList,
                              materialList: state.lastProcessMaterialsData,
                              addMaterial: (list) => logic.addMaterial(list),
                            ),
                          ),
                        ],
                      )),
                  Obx(() => ListView.builder(
                        padding: const EdgeInsets.only(top: 10),
                        itemCount: state.lastProcessProductionList.length,
                        itemBuilder: (c, i) =>
                            _processItem(state.lastProcessProductionList[i]),
                      )),
                  Obx(() => ListView(
                        children: [
                          for (var item in state.reportWorkerList)
                            _workerItem(item),
                          _addItem(
                            click: () => logic.lastProcessAddWorker(
                              opcProcessFlow.getPickItem().pickerId(),
                              dpcDate.getDateFormatYMD(),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => textSpan(
                      hint: '数量：',
                      text: state.reportQuantity.value.toShowString(),
                    )),
                Obx(() => textSpan(
                      hint: '总价：',
                      text: state.price.value.toShowString(),
                    )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    combination: Combination.left,
                    text: '报工列表',
                    click: () => logic.getGroupPayEndingProcessList(
                      date: dpcDate.getDateFormatYMD(),
                      processFlowID: opcProcessFlow.getPickItem().pickerId(),
                      processFlowName: opcProcessFlow.getPickItem().pickerName(),
                    ),
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    combination: Combination.right,
                    text: '提交报工',
                    click: () => logic.submitLastProcessReport(
                      dpcDate.getDateFormatYMD(),
                    ),
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
