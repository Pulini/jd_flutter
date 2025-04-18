import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_production_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'worker_production_report_logic.dart';

class WorkerProductionReportPage extends StatefulWidget {
  const WorkerProductionReportPage({super.key});

  @override
  State<WorkerProductionReportPage> createState() =>
      _WorkerProductionReportPageState();
}

class _WorkerProductionReportPageState
    extends State<WorkerProductionReportPage> {
  final logic = Get.put(WorkerProductionReportLogic());
  final state = Get.find<WorkerProductionReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        OptionsPicker(pickerController: logic.pickerControllerDepartment),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: () => logic.query(),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: state.dataList.length,
          itemBuilder: (BuildContext context, int index) => Card(
            child: ExpansionTile(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'worker_production_report_item_hint1'.tr,
                    text: state.dataList[index].empName ?? '',
                  ),
                  textSpan(
                    hint: 'worker_production_report_item_hint2'.tr,
                    text: state.dataList[index].empFinishQty.toShowString(),
                    textColor: Colors.green,
                  ),
                ],
              ),
              subtitle: Text(
                  '${'worker_production_report_sub_item_hint1'.tr}${state.dataList[index].processName}'),
              children: [
                for (ItemList item in state.dataList[index].itemList ?? [])
                  Column(
                    children: [
                      const Divider(indent: 20, endIndent: 20),
                      ListTile(
                        title: Text(
                          '${'worker_production_report_sub_item_hint2'.tr}${item.materialName}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        subtitle: Text(
                          '${'worker_production_report_sub_item_hint3'.tr}${item.empFinishQty.toShowString()}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkerProductionReportLogic>();
    super.dispose();
  }
}
