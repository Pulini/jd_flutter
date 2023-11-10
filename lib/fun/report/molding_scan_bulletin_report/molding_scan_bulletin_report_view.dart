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

  Widget circleButton(Widget child, Color background, Function onTap) {
    return Container(
      width: 40,
      height: 40,
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
          style: ButtonStyle(
              minimumSize: MaterialStateProperty.all(const Size(1, 1)),
              padding: MaterialStateProperty.all(EdgeInsets.zero),
              backgroundColor: MaterialStateProperty.all(background)),
          child: Center(
            child: child,
          ),
          onPressed: () => onTap.call()),
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
              const Text('刷新间隔(秒)：<'),
              Obx(() => circleButton(
                    const Text('3'),
                    logic.refreshDuration.value == 3
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(3),
                  )),
              Obx(() => circleButton(
                    const Text('4'),
                    logic.refreshDuration.value == 4
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(4),
                  )),
              Obx(() => circleButton(
                    const Text('5'),
                    logic.refreshDuration.value == 5
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(5),
                  )),
              Obx(() => circleButton(
                    const Text('6'),
                    logic.refreshDuration.value == 6
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(6),
                  )),
              Obx(() => circleButton(
                    const Text('7'),
                    logic.refreshDuration.value == 7
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(7),
                  )),
              Obx(() => circleButton(
                    const Text('8'),
                    logic.refreshDuration.value == 8
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(8),
                  )),
              Obx(() => circleButton(
                    const Text('9'),
                    logic.refreshDuration.value == 9
                        ? Colors.greenAccent
                        : Colors.white,
                    () => logic.setRefresh(9),
                  )),
              Obx(() => circleButton(
                    const Text('10'),
                    logic.refreshDuration.value == 10
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
                () => logic.query(),
              ),
            ],
          ),
          // body: Obx(() => Row(
          //       mainAxisSize: MainAxisSize.min,
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         if (state.reportInfo.isNotEmpty)
          //           Padding(
          //             padding: const EdgeInsets.all(40),
          //             child: tableCard(
          //               data: state.reportInfo[0],
          //               key: const Key('mainTable'),
          //               color: Colors.greenAccent,
          //             ),
          //           ),
          //         Expanded(
          //             child: TableList(
          //           reportInfo: state.reportInfo,
          //           changeSort: () => logic.changeSort(),
          //         )),
          //       ],
          //     )),
          body: Obx(() => TableList(
                reportInfo: state.reportInfo.toList(),
                changeSort: () => logic.changeSort(),
              ))),
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
