import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/daily_report_data.dart';
import '../../../utils.dart';
import '../../../widget/picker/picker_view.dart';
import 'daily_report_logic.dart';

class DailyReportPage extends StatefulWidget {

  const DailyReportPage({Key? key}) : super(key: key);

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final logic = Get.put(DailyReportLogic());
  final state = Get.find<DailyReportLogic>().state;

  _item(DailyReportData item, int index) {
    return Container(
      color: item.getItemColor(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(flex: 1, child: Text(item.size ?? '')),
            Expanded(flex: 2, child: Text(item.qty.toString())),
            Expanded(flex: 6, child: Text(item.materialName ?? '')),
            Expanded(flex: 2, child: Text(item.processName ?? '')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return titleWithDrawer(
      title: 'page_daily_report_title'.tr,
      children: [
        OptionsPicker(pickerController: logic.pickerControllerDepartment),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query:()=> logic.query(),
      body: Obx(() => ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: state.dataList.length,
            itemBuilder: (BuildContext context, int index) =>
                _item(state.dataList[index], index),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<DailyReportLogic>();
    super.dispose();
  }
}
