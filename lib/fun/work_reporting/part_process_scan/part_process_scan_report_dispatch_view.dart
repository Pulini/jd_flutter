import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_dispatch_view.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_logic.dart';
import 'package:jd_flutter/fun/work_reporting/part_process_scan/part_process_scan_quick_dispatch_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartProcessScanReportDispatchView extends StatefulWidget {
  const PartProcessScanReportDispatchView({super.key});

  @override
  State<PartProcessScanReportDispatchView> createState() =>
      _PartProcessScanReportModifyPageState();
}

class _PartProcessScanReportModifyPageState
    extends State<PartProcessScanReportDispatchView>
    with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 2, vsync: this);
  final logic = Get.find<PartProcessScanLogic>();
  final state = Get.find<PartProcessScanLogic>().state;

  Obx _distributionItem(int index) {
    ReportItemData data = state.distributionList[index];
    var style = const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.bold,
    );

    return Obx(() => Container(
          padding: const EdgeInsets.only(left: 5, right: 5),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  expandedTextSpan(
                    hint: 'part_process_scan_report_process'.tr,
                    text: data.reportList[0].name ?? '',
                    fontSize: 16,
                  ),
                  Checkbox(
                    activeColor: Colors.blueAccent,
                    value: data.isSelect.value,
                    onChanged: (c) {
                      data.isSelect.value = c!;
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'part_process_scan_report_allocation_situation'.tr,
                    style: style,
                  ),
                  Expanded(
                    child: CustomProgressIndicator(
                      max: data.getProcessMax(),
                      value: data.getDistributionMax(),
                    ),
                  ),
                  IconButton(
                    padding: const EdgeInsets.all(0),
                    iconSize: 35,
                    onPressed: () {
                      if (data.getProcessMax().sub(data.getDistributionMax()) >
                          0) {
                        Get.to(
                          () => const PartProcessScanDispatchPage(),
                          arguments: {'Index': index},
                        );
                      } else {
                        showSnackBar(
                            message: 'work_reporting_no_remaining_qty'.tr);
                      }
                    },
                    icon: const Icon(
                      Icons.note_alt_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              for (var worker in data.distribution)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  margin: const EdgeInsets.only(
                    left: 5,
                    right: 5,
                    bottom: 10,
                  ),
                  padding: const EdgeInsets.only(left: 5),
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
                          content: 'work_reporting_confirm_delete_person'.tr,
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

  Row _reportItemTitle() => Row(children: [
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 20,
          alignment: Alignment.center,
          text: 'part_process_scan_report_title_process'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 12,
          alignment: Alignment.center,
          text: 'part_process_scan_report_title_ins_number'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 5,
          alignment: Alignment.center,
          text: 'part_process_scan_report_title_size'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: 'part_process_scan_report_title_ins_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: 'part_process_scan_report_title_report_qty'.tr,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          isBold: true,
        ),
      ]);

  Row _reportItem1(ReportInfo item) => Row(children: [
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 20,
          alignment: Alignment.center,
          text: item.name ?? '',
          backgroundColor: Colors.white,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 12,
          alignment: Alignment.center,
          text: item.instruction ?? '',
          backgroundColor: Colors.white,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 5,
          alignment: Alignment.center,
          text: item.size ?? '',
          backgroundColor: Colors.white,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.instructionQty.toShowString(),
          backgroundColor: Colors.white,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.qty.toShowString(),
          backgroundColor: Colors.white,
        ),
      ]);

  Row _reportItem2(ReportInfo item) => Row(children: [
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 20,
          alignment: Alignment.center,
          text: 'part_process_scan_report_ins_total'.tr,
          backgroundColor: Colors.orange.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 12,
          alignment: Alignment.center,
          text: item.instruction ?? '',
          backgroundColor: Colors.orange.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 5,
          alignment: Alignment.center,
          text: '',
          backgroundColor: Colors.orange.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.instructionQty.toShowString(),
          backgroundColor: Colors.orange.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.qty.toShowString(),
          backgroundColor: Colors.orange.shade100,
        ),
      ]);

  Row _reportItem3(ReportInfo item) => Row(children: [
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 20,
          alignment: Alignment.center,
          text: 'part_process_scan_report_part_total'.tr,
          backgroundColor: Colors.greenAccent.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 12,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.greenAccent.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 5,
          text: '',
          alignment: Alignment.center,
          backgroundColor: Colors.greenAccent.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.instructionQty.toShowString(),
          backgroundColor: Colors.greenAccent.shade100,
        ),
        ExpandedFrameText(
          padding: const EdgeInsets.all(0),
          flex: 7,
          alignment: Alignment.center,
          text: item.qty.toShowString(),
          backgroundColor: Colors.greenAccent.shade100,
        ),
      ]);


  @override
  void initState() {
    state.reportViewGetWorkerList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '车间日报工',
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
            Text('分配'),
            Text('工序'),
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
                      itemCount: state.distributionList.length,
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
                            confirm: () => logic.submitDispatch(),
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
                padding: const EdgeInsets.all(5),
                children: [
                  _reportItemTitle(),
                  for (var item in state.reportList)
                    if (item.type == 0)
                      _reportItem1(item)
                    else if (item.type == 1)
                      _reportItem2(item)
                    else
                      _reportItem3(item)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    state.cleanReportData();
    super.dispose();
  }
}
