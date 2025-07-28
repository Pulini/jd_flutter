import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class WorkshopPlanningReportListPage extends StatefulWidget {
  const WorkshopPlanningReportListPage({super.key});

  @override
  State<WorkshopPlanningReportListPage> createState() =>
      _WorkshopPlanningReportListPageState();
}

class _WorkshopPlanningReportListPageState
    extends State<WorkshopPlanningReportListPage> {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  _item(WorkshopPlanningReportInfo data) => GestureDetector(
        onTap: () => logic.getReportDetailInfo(data.groupPayInterID ?? -1),
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        textSpan(
                          hint: '单据编号：',
                          text: data.number ?? '',
                          textColor: Colors.green.shade700,
                        ),
                        textSpan(
                          hint: '物料：',
                          maxLines: 2,
                          text: data.materialName ?? '',
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '生产单号：${data.planTrackingNumber}',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '报工日期：${data.date}',
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '工序：${data.processName}',
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '完成数量：${data.finishQty.toShowString()}',
                              ),
                            ),
                          ],
                        ),
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
                      content: '确定要删除此报工单吗？',
                      confirm: () =>
                          logic.deleteReportInfo(data.groupPayInterID ?? -1),
                    ),
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      body: Obx(() => ListView.builder(
            itemCount: state.reportList.length,
            itemBuilder: (c, i) => _item(state.reportList[i]),
          )),
    );
  }
}
