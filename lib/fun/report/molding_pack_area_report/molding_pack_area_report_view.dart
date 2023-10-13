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
  State<MoldingPackAreaReportPage> createState() => _MoldingPackAreaReportPageState();
}

class _MoldingPackAreaReportPageState extends State<MoldingPackAreaReportPage> {
  final logic = Get.put(MoldingPackAreaReportPageLogic());

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
       body:Obx(() => ListView(
         children: [
           SingleChildScrollView(
             scrollDirection: Axis.horizontal,
             child: DataTable(
               showCheckboxColumn: false,
               headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                     (Set<MaterialState> states) {
                   return Colors.blueAccent.shade100;
                 },
               ),
               columns: logic.tableDataColumn,
               rows: logic.tableDataRows,
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
