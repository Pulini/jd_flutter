import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/process_report/process_report_store_modify_view.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ProcessReportStorePage extends StatefulWidget {
  const ProcessReportStorePage({super.key});

  @override
  State<ProcessReportStorePage> createState() => _ProcessReportPageState();
}

class _ProcessReportPageState extends State<ProcessReportStorePage> {
  final logic = Get.put(ProcessReportStoreLogic());
  final state = Get.find<ProcessReportStoreLogic>().state;

  var refreshController = EasyRefreshController(controlFinishRefresh: true);
  var tecCode = TextEditingController();

  Container _item(BarCodeInfo code)  {
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      height: 40,
      padding: const EdgeInsets.only(left: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
              width: 1, color: code.isUsed ? Colors.red : Colors.black)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 9,
            child: Text(
              code.code.toString(),
              style: TextStyle(
                  color: code.isUsed ? Colors.red.shade700 : Colors.black),
            ),
          ),
          Text(
            code.isUsed ? 'production_scan_is_submit'.tr : '',
            style: TextStyle(
                color: code.isUsed ? Colors.red.shade700 : Colors.black),
          ),
          IconButton(
            onPressed: () => askDialog(
              content: 'sale_scan_out_warehouse_delete_tips'.tr,
              confirm: () => logic.deleteCode(code),
            ),
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 10, right: 30),
          child: InkWell(
            child: const Icon(Icons.menu, color: Colors.blueAccent),
            onTap: () {
              state.showClick.value = !state.showClick.value;
            },
          ),
        )
      ],
      body: EasyRefresh(
        controller: refreshController,
        header: const MaterialHeader(),
        onRefresh: () => logic.getBarCodeStatusByDepartmentID(refresh: () {
          refreshController.finishRefresh();
          refreshController.resetFooter();
        }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: EditText(
                    hint: 'process_report_store_manual_input'.tr,
                    controller: tecCode,
                  ),
                ),
                InkWell(
                  child: const Icon(Icons.qr_code_scanner, color: Colors.grey),
                  onTap: () => Get.to(() => const Scanner())
                      ?.then((v) => logic.scanCode(v.toString())),
                ),
                const SizedBox(width: 5)
              ],
            ),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(5),
                  itemCount: state.barCodeList.length,
                  itemBuilder: (BuildContext context, int index) =>
                      _item(state.barCodeList[index]),
                ),
              ),
            ),
            Obx(() => Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      textSpan(
                        hint: 'process_report_is_scan'.tr,
                        text: state.barCodeList.length.toString(),
                      ),
                      textSpan(
                        hint: 'process_report_pallet_no'.tr,
                        text: state.palletNumber.value,
                      ),
                    ],
                  ),
                )),
            Obx(() => Visibility(
                  visible: state.showClick.value,
                  child: Row(
                    children: [
                      Expanded(
                          child: CombinationButton(
                        text: 'process_report_store_change'.tr,
                        click: () {
                          Get.to(() => const ProcessReportModifyPage());
                        },
                        combination: Combination.left,
                      )),
                      Expanded(
                          child: CombinationButton(
                        text: 'process_report_store_clear_list'.tr,
                        click: () {
                          askDialog(
                            content: 'code_list_report_sure_clean'.tr,
                            confirm: () {
                              logic.clearBarCodeList();
                            },
                          );
                        },
                        combination: Combination.right,
                      ))
                    ],
                  ),
                )),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'process_report_store_manually_add'.tr,
                    click: () {
                      if (tecCode.text.isNotEmpty) logic.scanCode(tecCode.text);
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    text: 'process_report_store_submit_barcode'.tr,
                    click: () {
                      checkBarCodeProcessDialog(
                        list: state.barCodeList,
                        submit: (w, p) {
                          logic.submit(worker: w, process: p);
                        },
                      );
                    },
                    combination: Combination.right,
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
  void initState() {
    logic.getBarCodeStatusByDepartmentID(refresh: () {
      refreshController.finishRefresh();
      refreshController.resetFooter();
    });
    pdaScanner(scan: (code) {
      if (code.isNotEmpty && code != 'null') {
        logic.scanCode(code);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<ProcessReportStoreLogic>();
    super.dispose();
  }
}
