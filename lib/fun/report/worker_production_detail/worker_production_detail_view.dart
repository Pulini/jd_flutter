import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import '../../../widget/custom_widget.dart';
import 'worker_production_detail_logic.dart';

class WorkerProductionDetailPage extends StatefulWidget {
  const WorkerProductionDetailPage({super.key});

  @override
  State<WorkerProductionDetailPage> createState() =>
      _WorkerProductionDetailPageState();
}

class _WorkerProductionDetailPageState
    extends State<WorkerProductionDetailPage> {
  final logic = Get.put(WorkerProductionDetailLogic());
  final state = Get.find<WorkerProductionDetailLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      
      queryWidgets: [
        DatePicker(pickerController: logic.pickerControllerStartDate),
        DatePicker(pickerController: logic.pickerControllerEndDate),
        OptionsPicker(pickerController: logic.pickerControllerReportType),
        EditText(hint: '请输入工号', onChanged: (v) => state.etWorker = v),
      ],
      query: () => logic.query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(5),
            itemCount: state.dataList.length,
            itemBuilder: (BuildContext context, int index) =>
                logic.getTable(state.dataList[index]),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkerProductionDetailLogic>();
    super.dispose();
  }
}
