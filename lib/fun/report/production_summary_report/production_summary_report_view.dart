import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
import 'production_summary_report_logic.dart';

class ProductionSummaryReportPage extends StatefulWidget {
  const ProductionSummaryReportPage({super.key});

  @override
  State<ProductionSummaryReportPage> createState() =>
      _ProductionSummaryReportPageState();
}

class _ProductionSummaryReportPageState
    extends State<ProductionSummaryReportPage> {
  final logic = Get.put(ProductionSummaryReportLogic());
  final state = Get.find<ProductionSummaryReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      
      queryWidgets: [
        Spinner(controller: logic.spinnerControllerWorkShop),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: ()=>logic.query(),
      body: Obx(() => ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
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
    Get.delete<ProductionSummaryReportLogic>();
    super.dispose();
  }
}
