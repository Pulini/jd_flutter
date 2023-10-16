import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';

import '../../../utils.dart';
import '../../../widget/custom_text.dart';
import '../../../widget/picker/picker_view.dart';
import 'molding_pack_area_report_logic.dart';

class MoldingPackAreaReportPage extends StatefulWidget {
  const MoldingPackAreaReportPage({Key? key}) : super(key: key);

  @override
  State<MoldingPackAreaReportPage> createState() =>
      _MoldingPackAreaReportPageState();
}

class _MoldingPackAreaReportPageState extends State<MoldingPackAreaReportPage> {
  final logic = Get.put(MoldingPackAreaReportPageLogic());
  final state = Get.find<MoldingPackAreaReportPageLogic>().state;
  var textColor = const TextStyle(color: Colors.blueAccent);

  @override
  Widget build(BuildContext context) {
    return titleWithDrawer(
      title: getFunctionTitle(),
      children: [
        EditText(
          hint: '请输入指令单号',
          controller: logic.textControllerInstruction,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: '请输入采购订单号',
          controller: logic.textControllerOrderNumber,
        ),
        const SizedBox(height: 10),
        EditText(
          hint: '请输入型体',
          controller: logic.textControllerTypeBody,
        ),
        DatePicker(pickerController: logic.dateControllerStart),
        DatePicker(pickerController: logic.dateControllerEnd),
        CheckBox(checkBoxController: logic.checkBoxController)
      ],
      query: () => logic.query(),
      body: Obx(() => ListView(
            children: [
              Expanded(
                  child: Row(
                children: [
                  Text('page_molding_pack_area_report_detail_line'.tr),
                  Text(state.line.value, style: textColor),
                  Text('page_molding_pack_area_report_detail_type_body'.tr),
                  Text(state.typeBody.value, style: textColor),
                  Text('page_molding_pack_area_report_detail_color'.tr),
                  Text(state.color.value, style: textColor),
                ],
              )),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  showCheckboxColumn: false,
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return Colors.blueAccent.shade100;
                    },
                  ),
                  columns: state.tableDataColumn,
                  rows: state.tableDataRows,
                ),
              )
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<MoldingPackAreaReportPageLogic>();
    super.dispose();
  }
}
