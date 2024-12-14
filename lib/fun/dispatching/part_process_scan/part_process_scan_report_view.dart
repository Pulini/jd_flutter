import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/fun/dispatching/part_process_scan/part_process_scan_dispatch_view.dart';
import 'package:jd_flutter/fun/dispatching/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/fun/dispatching/part_process_scan/part_process_scan_quick_dispatch_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';


class PartProcessScanReportPage extends StatefulWidget {
  const PartProcessScanReportPage({super.key});

  @override
  State<PartProcessScanReportPage> createState() =>
      _PartProcessScanReportPageState();
}

class _PartProcessScanReportPageState extends State<PartProcessScanReportPage>
    with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 3, vsync: this);
  final logic = Get.find<PartProcessScanLogic>();
  final state = Get.find<PartProcessScanLogic>().state;

  _distributionItem(int index) {
    ReportItemData data = state.modifyDistributionList[index];
    var style = const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    );
    return Obx(() => Card(
          child: ExpansionTile(
            initiallyExpanded: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            title: Row(
              children: [
                Checkbox(
                  value: data.isSelect.value,
                  onChanged: (c) {
                    data.isSelect.value = c!;
                    logic.refreshSelectedAll(tabController.index);
                  },
                ),
                expandedTextSpan(
                  hint: '工序：',
                  text: data.reportList[0].name ?? '',
                  fontSize: 16,
                )
              ],
            ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  padding: const EdgeInsets.all(0),
                  iconSize: 35,
                  onPressed: () => Get.to(
                    () => const PartProcessScanDispatchPage(),
                    arguments: {'Index': index},
                  ),
                  icon: const Icon(
                    Icons.note_alt_outlined,
                    color: Colors.blue,
                  ),
                ),
                Text('分配情况：', style: style),
                Expanded(
                  child: percentIndicator(
                    max: data.getProcessMax(),
                    value: data.getDistributionMax(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    '${data.getDistributionMax().toShowString()} / ${data.getProcessMax().toShowString()}',
                    style: style,
                  ),
                ),
              ],
            ),
            children: [
              for (var worker in data.distribution)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.only(
                    left: 20,
                    top: 5,
                    right: 20,
                    bottom: 5,
                  ),
                  child: Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: '员工：',
                        text: '${worker.name} < ${worker.number} >',
                      ),
                      expandedTextSpan(
                        hint: '计工：',
                        text: worker.distributionQty.toShowString(),
                      ),
                    ],
                  ),
                )
            ],
          ),
        ));
  }

  _reportItem1(ReportInfo ri) {
    return Card(
      child: ListTile(
        title: Row(
          children: [
            expandedTextSpan(
                flex: 3, hint: '工序：', text: ri.name ?? '', fontSize: 18),
            expandedTextSpan(
              hint: '尺码：',
              text: ri.size ?? '',
              textColor: Colors.grey,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            expandedTextSpan(
              flex: 2,
              hint: '指令号：',
              text: ri.mtono ?? '',
              textColor: Colors.grey,
            ),
            expandedTextSpan(
              hint: '指令数：',
              text: ri.mtonoQty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
            expandedTextSpan(
              hint: '数量：',
              text: ri.qty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  _reportItem2(ReportInfo ri) {
    return Card(
      color: Colors.orange.shade100,
      child: ListTile(
        title: Row(
          children: [
            const Expanded(
              flex: 3,
              child: Text(
                '指令合计',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            expandedTextSpan(
              hint: '尺码：',
              text: ri.size ?? '',
              textColor: Colors.grey,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            expandedTextSpan(
              flex: 2,
              hint: '指令号：',
              text: ri.mtono ?? '',
              textColor: Colors.grey,
            ),
            expandedTextSpan(
              hint: '指令数：',
              text: ri.mtonoQty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
            expandedTextSpan(
              hint: '数量：',
              text: ri.qty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  _reportItem3(ReportInfo ri) {
    return Card(
      color: Colors.greenAccent.shade100,
      child: ListTile(
        title: Row(
          children: [
            const Expanded(
              flex: 3,
              child: Text(
                '部件合计',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            expandedTextSpan(
              hint: '尺码：',
              text: ri.size ?? '',
              textColor: Colors.grey,
            ),
          ],
        ),
        subtitle: Row(
          children: [
            expandedTextSpan(
              flex: 2,
              hint: '指令号：',
              text: ri.mtono ?? '',
              textColor: Colors.grey,
            ),
            expandedTextSpan(
              hint: '指令数：',
              text: ri.mtonoQty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
            expandedTextSpan(
              hint: '数量：',
              text: ri.qty.toDoubleTry().toShowString(),
              textColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  _barCodeItem(BarCodeInfo bci) {
    return Obx(() => Card(
          child: ListTile(
            title: textSpan(
                hint: '工序：', text: bci.processName ?? '', fontSize: 18),
            subtitle: Row(
              children: [
                expandedTextSpan(
                  hint: '条码：',
                  text: bci.barCode ?? '',
                  textColor: Colors.grey,
                ),
                textSpan(
                  hint: '数量：',
                  text: bci.qty.toShowString(),
                  textColor: Colors.grey,
                ),
              ],
            ),
            trailing: Checkbox(
              onChanged: (c) {
                state.modifyBarCodeList
                    .where((v) => v.barCode == bci.barCode)
                    .forEach((v) => v.isSelect.value = c!);
                logic.refreshSelectedAll(tabController.index);
              },
              value: bci.isSelect.value,
            ),
          ),
        ));
  }

  @override
  void initState() {
    tabController.addListener(() {
      logic.refreshSelectedAll(tabController.index);
    });
    state.reportViewGetWorkerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '车间日报工（修改）',
      actions: [
        Obx(
          () => CheckBox(
            onChanged: (c) => logic.setSelectedAll(tabController.index, c),
            name: '全选',
            value: state.isSelectAll.value,
          ),
        )
      ],
      body: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: TabBar(
          controller: tabController,
          dividerColor: Colors.blue,
          indicatorColor: Colors.blue,
          labelColor: Colors.blue,
          indicatorWeight: 5,
          labelPadding: const EdgeInsets.only(bottom: 10),
          unselectedLabelColor: Colors.grey,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: const [Text('分配'), Text('工序'), Text('贴标')],
        ),
        body: Obx(
          () => TabBarView(
            controller: tabController,
            children: [
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: state.modifyDistributionList.length,
                      itemBuilder: (context, index) => _distributionItem(index),
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: CombinationButton(
                          isEnabled: logic.isMultiSelect(tabController.index),
                          text: '快速分配',
                          click: () => Get.to(
                            () => const PartProcessScanQuickDispatchPage(),
                          ),
                          combination: Combination.left,
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          text: '提交',
                          click: () => askDialog(
                            content: '确定要提交本次报工吗？',
                            confirm: () => logic.reportModifySubmit(),
                          ),
                          combination: Combination.right,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  )
                ],
              ),
              ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.modifyReportList.length,
                  itemBuilder: (context, index) {
                    var data = state.modifyReportList[index];
                    if (data.type == '0') {
                      return _reportItem1(data);
                    } else if (data.type == '1') {
                      return _reportItem2(data);
                    } else {
                      return _reportItem3(data);
                    }
                  }),
              ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: state.modifyBarCodeList.length,
                itemBuilder: (context, index) =>
                    _barCodeItem(state.modifyBarCodeList[index]),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.cleanReportData();
    super.dispose();
  }
}
