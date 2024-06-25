import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/worker_production_info.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
import 'worker_production_report_logic.dart';

class WorkerProductionReportPage extends StatefulWidget {
  const WorkerProductionReportPage({Key? key}) : super(key: key);

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
      title: getFunctionTitle(),
      children: [
        OptionsPicker(pickerController: logic.pickerControllerDepartment),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: () => logic.query(),
      body: Obx(() => ListView.builder(
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
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '员工姓名：'),
                          TextSpan(
                            text: state.dataList[index].empName,
                            style: const TextStyle(color: Colors.blueAccent),
                          ),
                        ],
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: '总产量:'),
                          TextSpan(
                            text: state.dataList[index].empFinishQty
                                .toShowString(),
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                subtitle: Text('工序名称：${state.dataList[index].processName}'),
                children: [
                  for (ItemList item in state.dataList[index].itemList ?? [])
                    Column(
                      children: [
                        const Divider(indent: 20, endIndent: 20),
                        ListTile(
                          title: Text(
                            '物料：${item.materialName}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          subtitle: Text(
                            '数量：${item.empFinishQty.toShowString()}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkerProductionReportLogic>();
    super.dispose();
  }
}
