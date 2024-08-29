import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';

import '../../../bean/http/response/molding_scan_bulletin_report_info.dart';
import '../../../utils.dart';
import '../../../widget/custom_widget.dart';
import 'molding_scan_bulletin_report_logic.dart';
import 'molding_scan_bulletin_report_maximize_view.dart';

class MoldingScanBulletinReportPage extends StatefulWidget {
  const MoldingScanBulletinReportPage({super.key});

  @override
  State<MoldingScanBulletinReportPage> createState() =>
      _MoldingScanBulletinReportPageState();
}

class _MoldingScanBulletinReportPageState
    extends State<MoldingScanBulletinReportPage> {
  final logic = Get.put(MoldingScanBulletinReportLogic());
  final state = Get.find<MoldingScanBulletinReportLogic>().state;

  Widget circleButton(Widget child, Color background, Function onTap) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
          style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(1, 1)),
              padding: WidgetStateProperty.all(EdgeInsets.zero),
              backgroundColor: WidgetStateProperty.all(background)),
          child: Center(
            child: child,
          ),
          onPressed: () => onTap.call()),
    );
  }

  subTable(List<ScWorkCardSizeInfos> sizeData) {
    var greenText = const TextStyle(
      color: Colors.green,
      fontWeight: FontWeight.bold,
    );
    var redText = const TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
    return DataTable(
      border: TableBorder.all(color: Colors.black, width: 1),
      showCheckboxColumn: false,
      headingRowColor: WidgetStateProperty.resolveWith<Color?>(
        (states) => Colors.blueAccent.shade100,
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
        for (var i = 0; i < sizeData.length; ++i)
          DataRow(
            color: WidgetStateProperty.resolveWith<Color?>(
              (states) => i.isEven ? Colors.white : Colors.grey.shade200,
            ),
            cells: [
              DataCell(Text(sizeData[i].size ?? '')),
              DataCell(Text(sizeData[i].qty.toShowString())),
              DataCell(Text(sizeData[i].todayReportQty.toShowString())),
              DataCell(Text(sizeData[i].scannedQty.toShowString())),
              DataCell(Text(
                sizeData[i].getOwe().toShowString(),
                style: redText,
              )),
              DataCell(
                Text(
                  sizeData[i].getCompletionRate(),
                  style: greenText,
                ),
              ),
            ],
          )
      ],
    );
  }

  tableCard({
    required MoldingScanBulletinReportInfo data,
    required Key key,
    required bool isFirst,
  }) {
    var textStyle = const TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
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
                    child: isFirst
                        ? Hero(
                            tag: 'MSBR_table',
                            child: subTable(data.sizeInfo ?? []),
                          )
                        : subTable(data.sizeInfo ?? []),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(getFunctionTitle()),
          actions: [
            Text('${'molding_scan_bulletin_report_refresh_interval'.tr}：<'),
            Obx(() => circleButton(
                  const Text('3'),
                  state.refreshDuration.value == 3
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(3),
                )),
            Obx(() => circleButton(
                  const Text('4'),
                  state.refreshDuration.value == 4
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(4),
                )),
            Obx(() => circleButton(
                  const Text('5'),
                  state.refreshDuration.value == 5
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(5),
                )),
            Obx(() => circleButton(
                  const Text('6'),
                  state.refreshDuration.value == 6
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(6),
                )),
            Obx(() => circleButton(
                  const Text('7'),
                  state.refreshDuration.value == 7
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(7),
                )),
            Obx(() => circleButton(
                  const Text('8'),
                  state.refreshDuration.value == 8
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(8),
                )),
            Obx(() => circleButton(
                  const Text('9'),
                  state.refreshDuration.value == 9
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(9),
                )),
            Obx(() => circleButton(
                  const Text('10'),
                  state.refreshDuration.value == 10
                      ? Colors.greenAccent
                      : Colors.white,
                  () => logic.setRefresh(10),
                )),
            const Text('>'),
            const SizedBox(width: 50),
            circleButton(
              const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              Colors.blueAccent,
              () => logic.refreshTable(isRefresh: false),
            ),
          ],
        ),
        body: Obx(
          () {
            var cards = <Card>[
              for (int i = 0; i < state.reportInfo.length; i += 1)
                tableCard(
                  data: state.reportInfo[i],
                  key: Key('$i'),
                  isFirst: i == 0,
                ),
            ];
            return ReorderableListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 40),
              proxyDecorator: (child, index, animation) => AnimatedBuilder(
                animation: animation,
                builder: (context, child) => Transform.scale(
                  scale: lerpDouble(
                    1,
                    1.05,
                    Curves.easeInOut.transform(animation.value),
                  ),
                  child: Card(
                    elevation: lerpDouble(
                      1,
                      1.5,
                      Curves.easeInOut.transform(animation.value),
                    ),
                    color: cards[index].color,
                    child: cards[index].child,
                  ),
                ),
                child: child,
              ),
              scrollDirection: Axis.horizontal,
              onReorder: (oldIndex, newIndex) {
                setState(() => logic.changeSort(
                      oldIndex: oldIndex,
                      newIndex: newIndex,
                    ));
              },
              children: cards,
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MoldingScanBulletinReportLogic>();
    super.dispose();
  }
}
