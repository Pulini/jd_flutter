import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/http/response/molding_scan_bulletin_report_info.dart';
import 'molding_scan_bulletin_report_maximize_view.dart';

class MoldingScanBulletinReportState {
  var reportInfo = <MoldingScanBulletinReportInfo>[].obs;
  var greenText =
      const TextStyle(color: Colors.green, fontWeight: FontWeight.bold);
  var redText = const TextStyle(color: Colors.red, fontWeight: FontWeight.bold);

  tableCard({
    required MoldingScanBulletinReportInfo data,
    required Key key,
    required bool isFirst,
  }) {
    var textStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    var table = DataTable(
      border: TableBorder.all(color: Colors.black, width: 1),
      showCheckboxColumn: false,
      headingRowColor: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return Colors.blueAccent.shade100;
        },
      ),
      columns: [
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint1'.tr),
        ),
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint2'.tr),
          numeric: true,
        ),
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint3'.tr),
          numeric: true,
        ),
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint4'.tr),
          numeric: true,
        ),
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint5'.tr),
          numeric: true,
        ),
        DataColumn(
          label: Text('molding_scan_bulletin_report_table_hint6'.tr),
          numeric: true,
        ),
      ],
      rows: [
        for (var i = 0; i < data.sizeInfo!.length; ++i)
          createTableCardDataRow(
            data.sizeInfo![i],
            i.isEven ? Colors.white : Colors.grey.shade200,
          )
      ],
    );
    return Card(
      key: key,
      color: isFirst ? Colors.greenAccent : Colors.lime.shade100,
      child: Padding(
        padding:
            const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 40),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isFirst)
                    SizedBox(
                      height: 40,
                      child: Center(
                        child: IconButton(
                            onPressed: () => Get.to(() =>
                                const MoldingScanBulletinReportMaximize()),
                            icon: const Icon(Icons.aspect_ratio)),
                      ),
                    ),
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
                if (isFirst) const SizedBox(height: 40),
                Text('molding_scan_bulletin_report_hint1'.tr, style: textStyle),
                Text('molding_scan_bulletin_report_hint2'.tr, style: textStyle),
                Text('molding_scan_bulletin_report_hint3'.tr, style: textStyle),
                Text('molding_scan_bulletin_report_hint4'.tr, style: textStyle),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child:
                        isFirst ? Hero(tag: 'MSBR_table', child: table) : table,
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
    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          return color;
        },
      ),
      cells: [
        DataCell(Text(data.size ?? '')),
        DataCell(Text(data.qty.toShowString())),
        DataCell(Text(data.todayReportQty.toShowString())),
        DataCell(Text(data.scannedQty.toShowString())),
        DataCell(Text(
          data.getOwe().toShowString(),
          style: redText,
        )),
        DataCell(
          Text(
            data.getCompletionRate(),
            style: greenText,
          ),
        ),
      ],
    );
  }
}