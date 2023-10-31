import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../http/response/molding_scan_bulletin_report_info.dart';

class MoldingScanBulletinReportState {
  var reportInfo = <MoldingScanBulletinReportInfo>[].obs;

  MoldingScanBulletinReportState() {
    ///Initialize variables
  }
}

tableCard({
  required MoldingScanBulletinReportInfo data,
  required Key key,
  required Color color,
}) {
  var textStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
  return Card(
    key: key,
    color: color,
    child: Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(data.productName ?? '', style: textStyle),
                Text(data.mtoNo ?? '', style: textStyle),
                Text(data.clientOrderNumber ?? '', style: textStyle),
                Text(userInfo?.departmentName ?? '', style: textStyle),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('molding_scan_bulletin_report_hint1'.tr, style: textStyle),
              Text('molding_scan_bulletin_report_hint2'.tr, style: textStyle),
              Text('molding_scan_bulletin_report_hint3'.tr, style: textStyle),
              Text('molding_scan_bulletin_report_hint4'.tr, style: textStyle),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: DataTable(
                    border: TableBorder.all(color: Colors.black, width: 1),
                    showCheckboxColumn: false,
                    headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        return Colors.blueAccent.shade100;
                      },
                    ),
                    columns: [
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint1'.tr),
                      ),
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint2'.tr),
                        numeric: true,
                      ),
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint3'.tr),
                        numeric: true,
                      ),
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint4'.tr),
                        numeric: true,
                      ),
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint5'.tr),
                        numeric: true,
                      ),
                      DataColumn(
                        label:
                            Text('molding_scan_bulletin_report_table_hint6'.tr),
                        numeric: true,
                      ),
                    ],
                    rows: [
                      for (var i = 0; i < data.scWorkCardSizeInfos!.length; ++i)
                        createTableCardDataRow(
                          data.scWorkCardSizeInfos![i],
                          i.isEven ? Colors.white : Colors.grey.shade400,
                        )
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
    ),
  );
}

createTableCardDataRow(ScWorkCardSizeInfos data, Color color) {
  var owe = data.qty! - data.scannedQty! - data.todayReportQty!;
  var completionRate = owe / data.qty! * 100;
  return DataRow(
    color: MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        return color;
      },
    ),
    cells: [
      DataCell(Text(data.size ?? '')),
      DataCell(Text(data.qty.toShowString())),
      DataCell(Text(data.todayReportQty.toShowString())),
      DataCell(Text(data.scannedQty.toShowString())),
      DataCell(Text(owe.toShowString())),
      DataCell(Text('${completionRate.toShowString()}%')),
    ],
  );
}
