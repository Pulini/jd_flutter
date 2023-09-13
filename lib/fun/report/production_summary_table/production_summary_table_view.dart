import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils.dart';
import '../../../widget/picker/picker_view.dart';
import 'production_summary_table_logic.dart';

class ProductionSummaryTablePage extends StatefulWidget {
  const ProductionSummaryTablePage({Key? key}) : super(key: key);

  @override
  State<ProductionSummaryTablePage> createState() =>
      _ProductionSummaryTablePageState();
}

class _ProductionSummaryTablePageState
    extends State<ProductionSummaryTablePage> {
  final logic = Get.put(ProductionSummaryTableLogic());
  final state = Get.find<ProductionSummaryTableLogic>().state;

  @override
  Widget build(BuildContext context) {
    return titleWithDrawer(
      title: '产量汇总表',
      children: [
        Spinner(controller: logic.spinnerControllerWorkShop),
        DatePicker(pickerController: logic.pickerControllerDate),
      ],
      query: ()=>logic.query(),
      body: Obx(() => ListView(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
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
    Get.delete<ProductionSummaryTableLogic>();
    super.dispose();
  }
}
