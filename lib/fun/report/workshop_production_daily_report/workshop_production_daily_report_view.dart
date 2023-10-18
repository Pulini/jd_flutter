import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route.dart';
import '../../../utils.dart';
import 'workshop_production_daily_report_logic.dart';

class WorkshopProductionDailyReportPage extends StatefulWidget {
  const WorkshopProductionDailyReportPage({Key? key}) : super(key: key);

  @override
  State<WorkshopProductionDailyReportPage> createState() =>
      _WorkshopProductionDailyReportPageState();
}

class _WorkshopProductionDailyReportPageState
    extends State<WorkshopProductionDailyReportPage> {
  final logic = Get.put(WorkshopProductionDailyReportLogic());
  final state = Get.find<WorkshopProductionDailyReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(getFunctionTitle()),
          actions: [
            Obx(() => TextButton(
                  onPressed: () => logic.changeTable(),
                  child: Text(state.buttonName.value),
                ))
          ],
        ),
        body: ListView(
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => DataTable(
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.blueAccent.shade100;
                      },
                    ),
                    columns: state.tableDataColumn,
                    rows: state.tableDataRows,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<WorkshopProductionDailyReportLogic>();
    super.dispose();
  }
}
