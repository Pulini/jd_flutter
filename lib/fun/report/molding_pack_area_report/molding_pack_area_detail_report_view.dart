import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils.dart';
import 'molding_pack_area_report_logic.dart';

class MoldingPackAreaDetailReportPage extends StatefulWidget {
  const MoldingPackAreaDetailReportPage({Key? key}) : super(key: key);

  @override
  State<MoldingPackAreaDetailReportPage> createState() =>
      _MoldingPackAreaDetailReportPageState();
}

class _MoldingPackAreaDetailReportPageState
    extends State<MoldingPackAreaDetailReportPage> {
  final logic = Get.find<MoldingPackAreaReportPageLogic>();
  final state = Get.find<MoldingPackAreaReportPageLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.only(left: 10, right: 10),
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Obx(
                  () => DataTable(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    showCheckboxColumn: false,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.blueAccent.shade100;
                      },
                    ),
                    columns: state.detailTableDataColumn,
                    rows: [
                      for (var i = 0; i < state.detailTableData.length; ++i)
                        state.createDetailTableDataRow(
                          state.detailTableData[i],
                          i.isEven ? Colors.transparent : Colors.grey.shade100,
                        )
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
