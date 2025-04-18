import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/component_code_info.dart';
import 'package:jd_flutter/fun/report/part_report_scan/part_report_scan_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PartReportScanPage extends StatefulWidget {
  const PartReportScanPage({super.key});

  @override
  State<PartReportScanPage> createState() => _PartReportScanPageState();
}

class _PartReportScanPageState extends State<PartReportScanPage> {
  final logic = Get.put(PartReportScanLogic());
  final state = Get.find<PartReportScanLogic>().state;

  _item1(ComponentCodeInfo info) {
    return GestureDetector(
        onLongPress: () => {
          logic.deleteCode(info),
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.only(bottom: 5),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                  width: 1, color: info.use ? Colors.red : Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                info.barCode?? '',
                style: const TextStyle(
                    color: Colors.blue),
              ),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'part_report_title'.tr,
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: EditText(
                    hint: 'process_report_store_manual_input'.tr,
                    onChanged: (v) => state.modifyCode = v,
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () => {
                      Get.to(() => const Scanner())?.then((v) {
                        if (v != null) {
                          logic.addCode(v);
                        }
                      }),
                    },
                    icon: const Icon(
                      Icons.qr_code_scanner_outlined,
                      color: Colors.grey,
                    ),
                  ),
                )
              ],
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: state.dataList.length,
                    itemBuilder: (context, index) =>
                        _item1(state.dataList[index]),
                  )),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //手动添加
                    text: 'process_report_manually_add'.tr,
                    click: () => {
                      Get.to(() => const Scanner())?.then((v) {
                        if (v != null) {
                          logic.addCode(state.modifyCode);
                        }
                      }),
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Obx(() => CombinationButton(
                        //提交
                        text: state.buttonType.value
                            ? 'part_report_add'.tr
                            : 'part_report_delete'.tr,
                        click: () =>
                            {state.buttonType.value = !state.buttonType.value},
                        combination: Combination.middle,
                      )),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //提交
                    text: 'part_report_submit'.tr,
                    click: () => {
                      askDialog(
                        content: 'part_report_select_summary_type'.tr,
                        confirmText: 'part_report_select_instruction'.tr,
                        confirm: () {
                          logic.getBarCodeReportDetails('1');
                        },
                        cancelText: 'part_report_select_size'.tr,
                        cancel: () {
                          logic.getBarCodeReportDetails('2');
                        },
                      ),
                    },
                    combination: Combination.middle,
                  ),
                )
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => {logic.addCode(code)},
    );
    super.initState();
  }
}
