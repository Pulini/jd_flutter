import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/daily_report_data.dart';
import '../../../utils.dart';
import '../../../widget/picker/picker_view.dart';
import 'daily_report_logic.dart';

class DailyReport extends StatefulWidget {
  const DailyReport({Key? key}) : super(key: key);

  @override
  State<DailyReport> createState() => _DailyReportState();
}

class _DailyReportState extends State<DailyReport> {
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
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('扫码日产量报表'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            )
          ],
        ),
        endDrawer: Drawer(
          child: Column(children: [
            const SizedBox(height: 30),
            OptionsPicker(
              saveKey: state.pickerSaveDepartment,
              pickerController: logic.pickerControllerDepartment,
            ),
            DatePicker(
              saveKey: state.pickerSaveDate,
              pickerController: logic.pickerControllerDate,
            ),
            const Expanded(child: SizedBox()),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onPressed: () {
                logic.query();
                Get.back();
              },
              child: const Text(
                '查询',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ),
        body: Obx(() => ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.dataList.length,
              itemBuilder: (BuildContext context, int index) =>
                  _item(state.dataList[index], index),
            )),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<DailyReportLogic>();
    super.dispose();
  }
}
