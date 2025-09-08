import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_logic.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class LastProcessReportListPage extends StatefulWidget {
  const LastProcessReportListPage({super.key});

  @override
  State<LastProcessReportListPage> createState() =>
      _LastProcessReportListPageState();
}

class _LastProcessReportListPageState extends State<LastProcessReportListPage> {
  final WorkshopPlanningLogic logic = Get.find<WorkshopPlanningLogic>();
  final WorkshopPlanningState state = Get.find<WorkshopPlanningLogic>().state;

  _item(LastProcessGroupPayInfo data) => GestureDetector(
    onTap: ()=>logic.getLastProcessDetails(data.groupPayInterID??-1),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textSpan(hint: '单据编号：', text: data.number ?? ''),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('报工日期：${data.date}'),
                        Text('完成数量：${data.finishQty.toShowString()}'),
                      ],
                    )
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
                  confirm: () => logic.deleteLastProcessReportOrder(
                    id: data.groupPayInterID ?? -1,
                  ),
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
      title: '报工列表',
      body: Obx(() => ListView.builder(
            itemCount: state.lastProcessGroupPayList.length,
            itemBuilder: (c, i) => _item(state.lastProcessGroupPayList[i]),
          )),
    );
  }
}
