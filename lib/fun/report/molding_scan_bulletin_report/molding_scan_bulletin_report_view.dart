import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/route.dart';

import '../../../http/response/molding_scan_bulletin_report_info.dart';
import '../../../utils.dart';
import 'molding_scan_bulletin_report_logic.dart';
import 'molding_scan_bulletin_report_state.dart';

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
            IconButton(
                onPressed: () => logic.query(),
                icon: const Icon(Icons.refresh, color: Colors.blueAccent))
          ],
        ),
        body: Obx(() => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.reportInfo.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: tableCard(
                      data: state.reportInfo[0],
                      key: const Key('mainTable'),
                      color: Colors.greenAccent,
                    ),
                  ),
                Expanded(
                    child: TableList(
                  reportInfo: state.reportInfo,
                  changeSort: () => logic.changeSort(),
                )),
              ],
            )),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<MoldingScanBulletinReportLogic>();
    super.dispose();
  }
}

class TableList extends StatefulWidget {
  const TableList(
      {super.key, required this.reportInfo, required this.changeSort});

  final List<MoldingScanBulletinReportInfo> reportInfo;
  final Function changeSort;

  @override
  State<TableList> createState() => _TableListState();
}

class _TableListState extends State<TableList> {
  @override
  Widget build(BuildContext context) {
    final List<Card> cards = <Card>[
      for (int i = 0; i < widget.reportInfo.length; i += 1)
        tableCard(
          data: widget.reportInfo[i],
          key: Key('$i'),
          color: widget.reportInfo[i].itemColor ?? Colors.blueAccent,
        ),
    ];
    return ReorderableListView(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 40),
      proxyDecorator: (child, index, animation) => AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          var animValue = Curves.easeInOut.transform(animation.value);
          return Transform.scale(
            scale: lerpDouble(1, 1.05, animValue),
            child: Card(
              elevation: lerpDouble(1, 1.5, animValue),
              color: cards[index].color,
              child: cards[index].child,
            ),
          );
        },
        child: child,
      ),
      scrollDirection: Axis.horizontal,
      onReorder: (int oldIndex, int newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          var item = widget.reportInfo.removeAt(oldIndex);
          widget.reportInfo.insert(newIndex, item);
          widget.changeSort.call();
        });
      },
      children: cards,
    );
  }
}
