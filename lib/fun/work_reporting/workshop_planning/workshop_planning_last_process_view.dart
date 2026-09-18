import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_dialog.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/route.dart';

import 'package:jd_flutter/utils/extension_util.dart';
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

  Widget _materialItem(WorkshopPlanningMaterialInfo data) =>
      _LastProcessMaterialItem(data: data, logic: logic);

  Widget _processItem(WorkshopPlanningLastProcessInfo data) =>
      _LastProcessProcessItem(data: data);

  Widget _workerItem(WorkshopPlanningWorkerInfo data) => _LastProcessWorkerItem(
        data: data,
        logic: logic,
        opcProcessFlow: opcProcessFlow,
        dpcDate: dpcDate,
      );

  GestureDetector _addItem({required Function() click}) => GestureDetector(
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

  void refreshMaterialAndProcessDetails() {
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
    tabController.dispose();
    pageController.dispose();
    materialListener.dispose();
    logic.clearData();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'workshop_planning_last_process'.tr,
      popTitle: 'workshop_planning_exit_last_process_confirm'.tr,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(hint: 'workshop_planning_group_colon'.tr, text: state.groupName),
                Obx(() => CheckBox(
                      onChanged: (v) => state.isDayShift.value = true,
                      name: 'workshop_planning_day_shift'.tr,
                      value: state.isDayShift.value,
                    )),
                Obx(
                  () => CheckBox(
                    onChanged: (v) => state.isDayShift.value = false,
                    name: 'workshop_planning_night_shift'.tr,
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
                Tab(text: 'workshop_planning_tab_material'.tr),
                Tab(text: 'workshop_planning_tab_process'.tr),
                Tab(text: 'workshop_planning_tab_report'.tr),
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
                      hint: 'workshop_planning_quantity_colon'.tr,
                      text: state.reportQuantity.value.toShowString(),
                    )),
                Obx(() => textSpan(
                      hint: 'workshop_planning_total_price_colon'.tr,
                      text: state.price.value.toShowString(),
                    )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    combination: Combination.left,
                    text: 'workshop_planning_report_list'.tr,
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
                    text: 'workshop_planning_submit_report'.tr,
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

class _LastProcessMaterialItem extends StatefulWidget {
  final WorkshopPlanningMaterialInfo data;
  final WorkshopPlanningLogic logic;

  const _LastProcessMaterialItem({
    required this.data,
    required this.logic,
  });

  @override
  State<_LastProcessMaterialItem> createState() =>
      _LastProcessMaterialItemState();
}

class _LastProcessMaterialItemState extends State<_LastProcessMaterialItem> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  '(${widget.data.number}) ${widget.data.name}'
                      .allowWordTruncation(),
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
                onPressed: () =>widget.logic.deleteMaterial(widget.data),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LastProcessProcessItem extends StatelessWidget {
  final WorkshopPlanningLastProcessInfo data;

  const _LastProcessProcessItem({required this.data});

  @override
  Widget build(BuildContext context) {
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
                      hint: 'workshop_planning_order_no_colon'.tr,
                      text: data.planTrackingNumber ?? '',
                    ),
                    Text('${'workshop_planning_size_colon'.tr}${data.size}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'workshop_planning_order_count_colon'.tr}${data.processQty.toShowString()}'),
                    Text('${'workshop_planning_finished_count_colon'.tr}${data.finishQty.toShowString()}'),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${'workshop_planning_unfinished_count_colon'.tr}${data.unFinishQty.toShowString()}'),
                    Text('${'workshop_planning_report_qty_colon'.tr}${data.qty.toShowString()}'),
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
}

class _LastProcessWorkerItem extends StatefulWidget {
  final WorkshopPlanningWorkerInfo data;
  final WorkshopPlanningLogic logic;
  final OptionsPickerController opcProcessFlow;
  final DatePickerController dpcDate;

  const _LastProcessWorkerItem({
    required this.data,
    required this.logic,
    required this.opcProcessFlow,
    required this.dpcDate,
  });

  @override
  State<_LastProcessWorkerItem> createState() => _LastProcessWorkerItemState();
}

class _LastProcessWorkerItemState extends State<_LastProcessWorkerItem> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.logic.lastProcessModifyWorker(
          widget.data,
          widget.opcProcessFlow.getPickItem().pickerId(),
          widget.dpcDate.getDateFormatYMD(),
        );
      },
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
                              '${widget.data.name}(${widget.data.number})<${widget.data.typeOfWork}>',
                            ),
                          ),
                          Text(
                            widget.data.attendanceStatus == true ? 'workshop_planning_attended'.tr : 'workshop_planning_not_attended'.tr,
                            style: TextStyle(
                              color: widget.data.attendanceStatus == true
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
                                hint: 'workshop_planning_coefficient_colon'.tr,
                                text: widget.data.base.toShowString(),
                              ),
                              textSpan(
                                isBold: false,
                                hint: 'workshop_planning_man_hours_colon'.tr,
                                text: widget.data.dayWorkTime.toShowString(),
                              ),
                              textSpan(
                                isBold: false,
                                hint: 'workshop_planning_amount_colon'.tr,
                                text: widget.data.money.value.toShowString(),
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
                  onPressed: () {
                    askDialog(
                      content: 'workshop_planning_delete_member_confirm'.tr,
                      confirm: () =>
                          widget.logic.deleteReportWorker(widget.data),
                    );
                  },
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
