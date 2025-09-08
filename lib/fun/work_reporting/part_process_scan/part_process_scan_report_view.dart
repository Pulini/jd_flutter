import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_dispatch_view.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_quick_dispatch_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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
                  hint: 'part_process_scan_report_process'.tr,
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
                Text('part_process_scan_report_allocation_situation'.tr,
                    style: style),
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
                    right: 20,
                  ),
                  child: Row(
                    children: [
                      expandedTextSpan(
                        flex: 2,
                        hint: 'part_process_scan_report_worker'.tr,
                        text: '${worker.name} < ${worker.number} >',
                      ),
                      expandedTextSpan(
                        hint: 'part_process_scan_report_record_working'.tr,
                        text: worker.distributionQty.toShowString(),
                      ),
                      IconButton(
                        onPressed: () => askDialog(
                          content: '确定要删除该人员吗？',
                          confirm: () => data.distribution.remove(worker),
                        ),
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                      )
                    ],
                  ),
                )
            ],
          ),
        ));
  }

  _reportItemTitle() => Row(children: [
        expandedFrameText(
          flex: 20,
          text: 'part_process_scan_report_title_process'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          flex: 10,
          text: 'part_process_scan_report_title_ins_number'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          flex: 5,
          text: 'part_process_scan_report_title_size'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          flex: 7,
          text: 'part_process_scan_report_title_ins_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        expandedFrameText(
          flex: 7,
          text: 'part_process_scan_report_title_report_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
      ]);

  _reportItem1(ReportInfo item) => Row(children: [
        expandedFrameText(
          flex: 20,
          text: item.name ?? '',
          backgroundColor: Colors.white,
        ),
        expandedFrameText(
          flex: 10,
          text: item.mtono ?? '',
          backgroundColor: Colors.white,
        ),
        expandedFrameText(
          flex: 5,
          text: item.size ?? '',
          backgroundColor: Colors.white,
        ),
        expandedFrameText(
          flex: 7,
          text: item.mtonoQty.toShowString(),
          backgroundColor: Colors.white,
        ),
        expandedFrameText(
          flex: 7,
          text: item.qty.toShowString(),
          backgroundColor: Colors.white,
        ),
      ]);

  _reportItem2(ReportInfo item) => Row(children: [
        expandedFrameText(
          flex: 20,
          text: 'part_process_scan_report_ins_total'.tr,
          backgroundColor: Colors.orange.shade100,
        ),
        expandedFrameText(
          flex: 10,
          text: item.mtono ?? '',
          backgroundColor: Colors.orange.shade100,
        ),
        expandedFrameText(
          flex: 5,
          text: '',
          backgroundColor: Colors.orange.shade100,
        ),
        expandedFrameText(
          flex: 7,
          text: item.mtonoQty.toShowString(),
          backgroundColor: Colors.orange.shade100,
        ),
        expandedFrameText(
          flex: 7,
          text: item.qty.toShowString(),
          backgroundColor: Colors.orange.shade100,
        ),
      ]);

  _reportItem3(ReportInfo item) => Row(children: [
        expandedFrameText(
          flex: 20,
          text: 'part_process_scan_report_part_total'.tr,
          backgroundColor: Colors.greenAccent.shade100,
        ),
        expandedFrameText(
          flex: 10,
          text: '',
          backgroundColor: Colors.greenAccent.shade100,
        ),
        expandedFrameText(
          flex: 5,
          text: '',
          backgroundColor: Colors.greenAccent.shade100,
        ),
        expandedFrameText(
          flex: 7,
          text: item.mtonoQty.toShowString(),
          backgroundColor: Colors.greenAccent.shade100,
        ),
        expandedFrameText(
          flex: 7,
          text: item.qty.toShowString(),
          backgroundColor: Colors.greenAccent.shade100,
        ),
      ]);

  _barCodeItem(BarCodeInfo bci) {
    return Obx(() => Card(
          child: ListTile(
            title: textSpan(
                hint: 'part_process_scan_report_process'.tr,
                text: bci.processName ?? '',
                fontSize: 18),
            subtitle: Row(
              children: [
                expandedTextSpan(
                  hint: 'part_process_scan_report_bar_code'.tr,
                  text: bci.barCode ?? '',
                  textColor: Colors.grey,
                ),
                textSpan(
                  hint: 'part_process_scan_report_quantity'.tr,
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
      title: 'part_process_scan_report_day_report'.tr,
      actions: [
        Obx(
          () => CheckBox(
            onChanged: (c) => logic.setSelectedAll(tabController.index, c),
            name: 'part_process_scan_report_all'.tr,
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
          tabs: [
            Text('part_process_scan_report_tab_allocation'.tr),
            Text('part_process_scan_report_tab_process'.tr),
            Text('part_process_scan_report_tab_label'.tr),
          ],
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
                          text: 'part_process_scan_report_quick_allocation'.tr,
                          click: () => Get.to(
                            () => const PartProcessScanQuickDispatchPage(),
                          ),
                          combination: Combination.left,
                        ),
                      ),
                      Expanded(
                        child: CombinationButton(
                          text: 'part_process_scan_report_submit'.tr,
                          click: () => askDialog(
                            content: 'part_process_scan_report_submit_tips'.tr,
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
              ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _reportItemTitle(),
                  for (var item in state.modifyReportList)
                    if (item.type == 0)
                      _reportItem1(item)
                    else if (item.type == 1)
                      _reportItem2(item)
                    else
                      _reportItem3(item)
                ],
              ),
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
