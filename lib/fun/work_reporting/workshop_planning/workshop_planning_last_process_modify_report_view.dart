import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';

import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class LastProcessModifyReportPage extends StatefulWidget {
  const LastProcessModifyReportPage({super.key});

  @override
  State<LastProcessModifyReportPage> createState() =>
      _LastProcessModifyReportPageState();
}

class _LastProcessModifyReportPageState
    extends State<LastProcessModifyReportPage>
    with SingleTickerProviderStateMixin {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  late TabController tabController = TabController(length: 3, vsync: this);
  var pageController = PageController();

  Widget _materialItem(LastProcessReportMaterialInfo data) =>
      _ModifyReportMaterialItem(data: data, logic: logic);

  Widget _processItem(WorkshopPlanningLastProcessInfo data) =>
      _ModifyReportProcessItem(data: data);

  Widget _workerItem(WorkshopPlanningWorkerInfo data) =>
      _ModifyReportWorkerItem(data: data, logic: logic);

  GestureDetector _addItem({required Function() click}) => GestureDetector(
        onTap: click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.orange,
          ),
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
  Widget build(BuildContext context) {
    return pageBody(
      title: '计工修改',
      popTitle: '确定要退出本次团件计工吗？',
      actions: [
        CombinationButton(
          text: '修改',
          click: () => logic.modifyReportSubmit(),
        )
      ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                expandedTextSpan(hint: '组别：', text: state.groupName),
                expandedTextSpan(
                  hint: '班次：',
                  text: state.lastProcessReportDetail?.workShift == 0
                      ? '昼班'
                      : '夜班',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                expandedTextSpan(
                  hint: '制程：',
                  text: state.lastProcessFlowName,
                ),
                expandedTextSpan(
                  hint: '日期：',
                  text: state.lastProcessReportDetail?.date ?? '',
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
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      children: [
                        for (var item in state.modifyReportMaterialList)
                          _materialItem(item),
                      ],
                    )),
                Obx(() => ListView.builder(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      itemCount: state.modifyReportProductionList.length,
                      itemBuilder: (c, i) =>
                          _processItem(state.modifyReportProductionList[i]),
                    )),
                Obx(() => ListView(
                      padding:
                          const EdgeInsets.only(top: 10, left: 10, right: 10),
                      children: [
                        for (var item in state.modifyReportReportWorkerList)
                          _workerItem(item),
                        _addItem(
                          click: () => logic.modifyReportAddWorker(),
                        ),
                      ],
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => textSpan(
                      hint: '数量：',
                      text:
                          state.modifyReportReportQuantity.value.toShowString(),
                    )),
                Obx(() => textSpan(
                      hint: '总价：',
                      text: state.modifyReportPrice.value.toShowString(),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    tabController.dispose();
    pageController.dispose();
    super.dispose();
  }
}

class _ModifyReportMaterialItem extends StatefulWidget {
  final LastProcessReportMaterialInfo data;
  final WorkshopPlanningLogic logic;

  const _ModifyReportMaterialItem({
    required this.data,
    required this.logic,
  });

  @override
  State<_ModifyReportMaterialItem> createState() =>
      _ModifyReportMaterialItemState();
}

class _ModifyReportMaterialItemState
    extends State<_ModifyReportMaterialItem> {

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
      margin: const EdgeInsets.only(bottom: 10),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  '(${widget.data.number}) ${widget.data.name}'.allowWordTruncation(),
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
                onPressed: (() => widget.logic.modifyReportDeleteMaterial(widget.data)).throttle(),
                icon: const Icon(Icons.delete_forever, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModifyReportProcessItem extends StatelessWidget {
  final WorkshopPlanningLastProcessInfo data;

  const _ModifyReportProcessItem({required this.data});

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
}

class _ModifyReportWorkerItem extends StatefulWidget {
  final WorkshopPlanningWorkerInfo data;
  final WorkshopPlanningLogic logic;

  const _ModifyReportWorkerItem({
    required this.data,
    required this.logic,
  });

  @override
  State<_ModifyReportWorkerItem> createState() =>
      _ModifyReportWorkerItemState();
}

class _ModifyReportWorkerItemState extends State<_ModifyReportWorkerItem> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (() => widget.logic.modifyReportModifyWorker(widget.data)).throttle(),
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
        margin: const EdgeInsets.only(bottom: 10),
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
                            widget.data.attendanceStatus == true ? '已考勤' : '未考勤',
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
                                hint: '系数：',
                                text: widget.data.base.toShowString(),
                              ),
                              textSpan(
                                isBold: false,
                                hint: '工时：',
                                text: widget.data.dayWorkTime.toShowString(),
                              ),
                              textSpan(
                                isBold: false,
                                hint: '金额：',
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
                  onPressed: (() => askDialog(
                    content: '确定要删除该组员数据吗？',
                    confirm: () => widget.logic.modifyReportDeleteReportWorker(widget.data),
                  )).throttle(),
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
