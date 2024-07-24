import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/sacn/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/scan_barcode_info.dart';

class PartProcessReport extends StatefulWidget {
  const PartProcessReport({super.key});

  @override
  State<PartProcessReport> createState() => _PartProcessReportState();
}

class _PartProcessReportState extends State<PartProcessReport>
    with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 3, vsync: this);
  final logic = Get.find<PartProcessScanLogic>();
  final state = Get
      .find<PartProcessScanLogic>()
      .state;

  _item(List<ReportInfo> data, List<Distribution> dis, bool isSelect) {
    var total = 0.0;
    for (var v in data) {
      total = total.add(v.qty.toDoubleTry());
    }
    var distributionQty = 0.0;
    for (var v in dis) {
      distributionQty = distributionQty.add(v.distributionQty ?? 0);
    }
    var unDistributionQty = total.sub(distributionQty);
    return Card(
      child: ExpansionTile(
        leading: Checkbox(
          value: isSelect,
          onChanged: (c) => isSelect = c!,
        ),
        title: Row(
          children: [
            expandedTextSpan(hint: '工序：', text: data[0].name ?? ''),
            textSpan(hint: '可报数：', text: total.toShowString()),
          ],
        ),
        subtitle: Row(
          children: [
            expandedTextSpan(
              hint: '分配数：',
              text: distributionQty.toShowString(),
            ),
            expandedTextSpan(
              hint: '未分配数：',
              text: unDistributionQty.toShowString(),
            ),
          ],
        ),
        children: [
          for (var i = 0; i < dis.length; ++i)
            ListTile()
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '部件工序报工',
      body: Scaffold(
        appBar: TabBar(
          controller: tabController,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.greenAccent,
          labelColor: Colors.greenAccent,
          unselectedLabelColor: Colors.white,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [
            Tab(
              icon: Icon(Icons.phone),
              text: '分配',
            ),
            Tab(
              icon: Icon(Icons.precision_manufacturing),
              text: '工序',
            ),
            Tab(
              icon: Icon(Icons.assignment_ind_outlined),
              text: '贴标',
            )
          ],
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.reportProcessList.length,
                      itemBuilder: (context, index) =>
                          _item(
                              state.reportProcessList[index],
                              state.reportDistributionList[index],
                              state.reportSelectList[index]),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: CombinationButton(
                            text: '',
                            click: () {},
                            combination: Combination.left,
                          )),
                      Expanded(
                          child: CombinationButton(
                            text: '',
                            click: () {},
                            combination: Combination.middle,
                          )),
                      Expanded(
                          child: CombinationButton(
                            text: '',
                            click: () {},
                            combination: Combination.right,
                          )),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
