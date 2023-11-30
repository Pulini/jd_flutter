import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils.dart';
import 'molding_scan_bulletin_report_logic.dart';

class MoldingScanBulletinReportMaximize extends StatefulWidget {
  const MoldingScanBulletinReportMaximize({super.key});

  @override
  State<MoldingScanBulletinReportMaximize> createState() =>
      _MoldingScanBulletinReportMaximizeState();
}

class _MoldingScanBulletinReportMaximizeState
    extends State<MoldingScanBulletinReportMaximize> {
  final state = Get.find<MoldingScanBulletinReportLogic>().state;

  _header() {
    return Obx(() {
      var textStyle =
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
      var data = state.reportInfo[0];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'molding_scan_bulletin_report_hint1'.tr + (data.productName ?? ''),
            style: textStyle,
          ),
          Text(
            'molding_scan_bulletin_report_hint2'.tr + (data.mtoNo ?? ''),
            style: textStyle,
          ),
          Text(
            'molding_scan_bulletin_report_hint3'.tr +
                (data.clientOrderNumber ?? ''),
            style: textStyle,
          ),
          Text(
            'molding_scan_bulletin_report_hint4'.tr +
                (userInfo?.departmentName ?? ''),
            style: textStyle,
          ),
        ],
      );
    });
  }

  var whiteColor = MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      return Colors.white;
    },
  );
  var greyColor = MaterialStateProperty.resolveWith<Color?>(
    (Set<MaterialState> states) {
      return Colors.grey.shade200;
    },
  );

  getTable() {
    return Obx(
      () {
        var data = state.reportInfo[0].sizeInfo!;
        return DataTable(
          border: TableBorder.all(color: Colors.black, width: 1),
          showCheckboxColumn: false,
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              return Colors.blueAccent.shade100;
            },
          ),
          columns: [
            DataColumn(
              label: Text('molding_scan_bulletin_report_table_hint1'.tr),
            ),
            for (var i = 0; i < data.length; ++i)
              DataColumn(label: Text(data[i].size ?? ''))
          ],
          rows: [
            DataRow(
              color: whiteColor,
              cells: [
                DataCell(Text('molding_scan_bulletin_report_table_hint2'.tr)),
                for (var i = 0; i < data.length; ++i)
                  DataCell(Text(data[i].qty.toShowString()))
              ],
            ),
            DataRow(
              color: greyColor,
              cells: [
                DataCell(Text('molding_scan_bulletin_report_table_hint3'.tr)),
                for (var i = 0; i < data.length; ++i)
                  DataCell(Text(data[i].todayReportQty.toShowString()))
              ],
            ),
            DataRow(
              color: whiteColor,
              cells: [
                DataCell(Text('molding_scan_bulletin_report_table_hint4'.tr)),
                for (var i = 0; i < data.length; ++i)
                  DataCell(Text(data[i].scannedQty.toShowString()))
              ],
            ),
            DataRow(
              color: greyColor,
              cells: [
                DataCell(Text(
                  'molding_scan_bulletin_report_table_hint5'.tr,
                  style: state.redText,
                )),
                for (var i = 0; i < data.length; ++i)
                  DataCell(Text(
                    data[i].getOwe().toShowString(),
                    style: state.redText,
                  ))
              ],
            ),
            DataRow(
              color: whiteColor,
              cells: [
                DataCell(
                  Text(
                    'molding_scan_bulletin_report_table_hint6'.tr,
                    style: state.greenText,
                  ),
                ),
                for (var i = 0; i < data.length; ++i)
                  DataCell(Text(
                    data[i].getCompletionRate(),
                    style: state.greenText,
                  )),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(backgroundColor: Colors.transparent),
        body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _header(),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Hero(
                    tag: 'MSBR_table',
                    child: getTable(),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
