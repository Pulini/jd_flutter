import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../route.dart';
import '../../../utils.dart';
import '../../../widget/picker/picker_view.dart';
import 'production_day_report_logic.dart';

class ProductionDayReportPage extends StatefulWidget {
  const ProductionDayReportPage({Key? key}) : super(key: key);

  @override
  State<ProductionDayReportPage> createState() =>
      _ProductionDayReportPageState();
}

class _ProductionDayReportPageState extends State<ProductionDayReportPage> {
  final logic = Get.put(ProductionDayReportLogic());
  final state = Get.find<ProductionDayReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      title:getFunctionTitle(),
      children: [
        Spinner(controller: logic.spinnerControllerWorkShop),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: () => logic.query(),
      body: Obx(() => ListView(
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
    Get.delete<ProductionDayReportLogic>();
    super.dispose();
  }
}
