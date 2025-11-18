import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/work_reporting/process_report/process_report_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class ProcessReportPage extends StatefulWidget {
  const ProcessReportPage({super.key});

  @override
  State<ProcessReportPage> createState() => _ProcessReportPageState();
}

class _ProcessReportPageState extends State<ProcessReportPage> {
  final logic = Get.put(ProcessReportLogic());
  final state = Get.find<ProcessReportLogic>().state;

  void addWorkerDialog({
    required Function(WorkerInfo wi) callback,
  }) {
    var name = ''.obs;
    WorkerInfo? newWorker;
    Get.dialog(PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text('process_report_change_people'.tr),
        content: SizedBox(
          width: 200,
          height: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      name.value,
                      style: const TextStyle(color: Colors.blueAccent,fontSize: 18),
                    ),
                  )),
              NumberEditText(
                hasFocus: true,
                hint: 'process_report_input_people_number'.tr,
                onChanged: (s) {
                  if (s.length >= 6) {
                    getWorkerInfo(
                      number: s,
                      workers: (list) {
                        newWorker = list[0];
                        name.value = list[0].empName ?? '';
                      },
                      error: (msg) => errorDialog(content: msg),
                    );
                  }
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (newWorker != null) {
                callback.call(newWorker!);
                Get.back();
              }
            },
            child: Text('dialog_default_confirm'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'dialog_default_cancel'.tr,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    ));
  }

  InkWell _item1(DispatchInfo data, int position) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                    //单号
                    hint: 'process_report_order_number'.tr,
                    text: data.cardNo ?? '',
                    textColor: Colors.blue.shade500,
                    hintColor: Colors.black),
                expandedTextSpan(
                  //数量
                  hint: 'process_report_qty'.tr,
                  text: data.qty.toShowString(),
                  hintColor: Colors.black,
                  textColor: Colors.blue.shade500,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                    //姓名
                    hint: 'process_report_name'.tr,
                    text: data.empName ?? '',
                    textColor: Colors.blue.shade500,
                    hintColor: Colors.black),
                expandedTextSpan(
                  //工号
                  hint: 'process_report_work_number'.tr,
                  text: data.empNumber ?? '',
                  hintColor: Colors.black,
                  textColor: Colors.blue.shade500,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('process_report_click_to_modify'.tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    )),
                Text('process_report_long_click_delete'.tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    )),
              ],
            ),
          ],
        ),
      ),
      onLongPress: () {
        askDialog(
            content: 'process_report_sure_delete_data'.tr,
            confirm: () {
              logic.removeItem(position);
            });
      },
      onTap: () {
        addWorkerDialog(callback: (WorkerInfo wi) {
            logic.setPeople(wi,position);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        body: Column(
      children: [
        Obx(
          () => Row(
            children: [
              const SizedBox(width: 10),
              expandedTextSpan(
                flex: 1,
                hint: 'process_report_number_of_barcodes'.tr,
                text: state.dataList.isNullOrEmpty()
                    ? '0'
                    : state.dataList.length.toString(),
              ),
              expandedTextSpan(
                flex: 1,
                hint: 'process_report_total_products'.tr,
                text: state.allQty.value.toShowString(),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() => ListView.builder(
                itemCount: state.dataList.length,
                itemBuilder: (context, index) =>
                    _item1(state.dataList[index], index),
              )),
        ),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: CombinationButton(
                //摄像头扫码
                text: 'process_report_scan'.tr,
                click: () {
                  Get.to(() => const Scanner())?.then((v) {
                    if (v != null) {
                      logic.getDispatchInfo(v.toString());
                    }
                  });
                },
                combination: Combination.left,
              ),
            ),
            Expanded(
              flex: 1,
              child: CombinationButton(
                //提交
                text: 'process_report_submit'.tr,
                click: ()  {
                  askDialog(
                      content: 'process_report_sure_to_submit'.tr,
                      confirm: () {
                        logic.submitProcess(success: (String msg) {
                          logic.cleanData();
                        });
                      });
                },
                combination: Combination.right,
              ),
            )
          ],
        )
      ],
    ));
  }
}
