import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';

import '../../../widget/custom_widget.dart';
import '../../../widget/picker/picker_view.dart';
import 'production_materials_report_logic.dart';

class ProductionMaterialsReportPage extends StatefulWidget {
  const ProductionMaterialsReportPage({super.key});

  @override
  State<ProductionMaterialsReportPage> createState() =>
      _ProductionMaterialsReportPageState();
}

class _ProductionMaterialsReportPageState
    extends State<ProductionMaterialsReportPage> {
  final logic = Get.put(ProductionMaterialsReportLogic());
  final state = Get.find<ProductionMaterialsReportLogic>().state;

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      title: getFunctionTitle(),
      children: [
        EditText(
          hint: '型体',
          controller: logic.textControllerInstruction,
        ),
        EditText(
          hint: '指令',
          controller: logic.textControllerOrderNumber,
        ),
        EditText(
          hint: '生产订单号',
          controller: logic.textControllerTypeBody,
        ),
        EditText(
          hint: '尺码生产订单号',
          controller: logic.textControllerTypeBody,
        ),
        OptionsPicker(pickerController: logic.pickerControllerSapProcessFlow),
        SwitchButton(
            switchController: logic.switchControllerPickingMaterialCompleted),
      ],
      query: () => logic.queryProductionMaterials(),
      body: ListView(
        padding: const EdgeInsets.only(left: 10, right: 10),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => DataTable(
                  border: TableBorder.all(color: Colors.black, width: 1),
                  showCheckboxColumn: false,
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return Colors.blueAccent.shade100;
                    },
                  ),
                  columns: state.tableDataColumn,
                  rows: [
                    for (var i = 0; i < state.tableData.length; ++i)
                      state.createTableDataRow(
                        state.tableData[i],
                        i.isEven ? Colors.transparent : Colors.grey.shade100,
                        (id, no) => {},
                      )
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<ProductionMaterialsReportLogic>();
    super.dispose();
  }
}
