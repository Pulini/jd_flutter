import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/daily_report_info.dart';
import 'package:jd_flutter/fun/report/daily_report/daily_report_state.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'daily_report_logic.dart';

class DailyReportPage extends StatefulWidget {
  const DailyReportPage({super.key});

  @override
  State<DailyReportPage> createState() => _DailyReportPageState();
}

class _DailyReportPageState extends State<DailyReportPage> {
  final logic = Get.put(DailyReportLogic());
  final state = Get.find<DailyReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      queryWidgets: [
        OptionsPicker(pickerController: logic.pickerControllerDepartment),
        DatePicker(pickerController: logic.pickerControllerDate),
        Obx(() => CheckBox(
              onChanged: (c) {
                state.isCommand.value = c;
                saveDailyReportCommand(c);
              },
              name: 'page_title_with_drawer_show_command'.tr,
              value: state.isCommand.value,
            )),
      ],
      query: () => logic.query(),
      body: Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: state.isCommand.value ? 800 : 600,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _DailyReportItem.empty(isCommand: state.isCommand.value),
                  for (var data in state.dataList)
                    _DailyReportItem(item: data, isCommand: state.isCommand.value),
                ],
              ),
            ),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<DailyReportLogic>();
    super.dispose();
  }
}

class _DailyReportItem extends StatelessWidget {
  final DailyReport? item;
  final bool isCommand;

  const _DailyReportItem({this.item, required this.isCommand});

  const _DailyReportItem.empty({required this.isCommand}) : item = null;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: item == null ? Colors.greenAccent : item!.getItemColor(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            isCommand
                ? Expanded(
              flex: 2,
              child: Text(
                item == null
                    ? 'page_daily_report_table_title_hint5'.tr
                    : item!.seOrderNo ?? '',
              ),
            ) : const SizedBox.shrink(),
            Expanded(
              flex: 1,
              child: Text(
                item == null
                    ? 'page_daily_report_table_title_hint2'.tr
                    : item!.size ?? '',
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(item == null
                  ? 'page_daily_report_table_title_hint4'.tr
                  : item!.qty.toString()),
            ),
            Expanded(
              flex: 6,
              child: Text(
                item == null
                    ? 'page_daily_report_table_title_hint1'.tr
                    : item!.materialName ?? '',
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                item == null
                    ? 'page_daily_report_table_title_hint3'.tr
                    : item!.processName ?? '',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
