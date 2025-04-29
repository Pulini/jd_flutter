import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/show_handover_info.dart';
import 'package:jd_flutter/fun/report/component_handover/component_handover_logic.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/signature_page.dart';

import 'component_handover_summary_view.dart';

class ComponentHandoverPage extends StatefulWidget {
  const ComponentHandoverPage({super.key});

  @override
  State<ComponentHandoverPage> createState() => _ComponentHandoverPageState();
}

class _ComponentHandoverPageState extends State<ComponentHandoverPage> {
  final logic = Get.put(ComponentHandoverLogic());
  final state = Get.find<ComponentHandoverLogic>().state;

  _item1(ShowHandoverInfo data, int position) {
    return Row(
      children: [
        const SizedBox(width: 5),
        Expanded(
          child: _text(mes: (position + 1).toString(), head: false),
        ),
        Expanded(
            flex: 2,
            child: _text(
              mes: data.code ?? '',
              head: false,
            )),
        Expanded(
            child: _text(
          mes: data.size ?? '',
          head: false,
        )),
        Expanded(
            child: _text(
          mes: data.qty.toString(),
          head: false,
        )),
        const SizedBox(width: 5),
      ],
    );
  }

  _text({
    required String mes,
    required bool head,
  }) {
    var textColor = Colors.white;
    Color backColor = Colors.blue;
    if (head) {
      textColor = Colors.white;
      backColor = Colors.blue;
    } else {
      textColor = Colors.black;
      backColor = Colors.white;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.black, // 边框颜色
          width: 1.0, // 边框宽度
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5, bottom: 5),
        child: Center(
          child: Text(
            maxLines: 1,
            mes,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }

  _title() {
    return Row(
      children: [
        const SizedBox(width: 5),
        Expanded(
          child: _text(mes: 'component_handover_index'.tr, head: true),
        ),
        Expanded(
            flex: 2,
            child: _text(
              mes: 'component_handover_barcode'.tr,
              head: true,
            )),
        Expanded(
            child: _text(
          mes: 'component_handover_size'.tr,
          head: true,
        )),
        Expanded(
            child: _text(
          mes: 'component_handover_qty'.tr,
          head: true,
        )),
        const SizedBox(width: 5),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'component_handover_title'.tr,
        actions: [
          TextButton(
              //清空
              onPressed: () => {},
              child: Text('component_handover_clean'.tr))
        ],
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: NumberEditText(
                    hasFocus: true,
                    hint: 'process_report_input_people_number'.tr,
                    onClear: () {
                      logic.clearPeople();
                    },
                    onChanged: (s) {
                      if (s.length >= 6) {
                        logic.getWorkerInfo(
                          number: s,
                          workers: (list) {
                            if (list.isNotEmpty) {
                              state.empName.value = list[0].empName.toString();
                              state.empCode = list[0].empCode.toString();
                              state.departmentId =
                                  list[0].empDepartID.toString();
                              state.empId = list[0].empID.toString();
                            }
                          },
                          error: (msg) => showSnackBar(message: msg),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Obx(
                  () => Expanded(child: Text(state.empName.value)),
                ),
              ],
            ),
            Obx(
              () => Row(
                //型体和制程
                children: [
                  const SizedBox(width: 10),
                  expandedTextSpan(
                      flex: 5,
                      fontSize: 16,
                      hint: 'component_handover_type_body'.tr,
                      text: state.typeBody.value),
                  expandedTextSpan(
                      flex: 5,
                      fontSize: 16,
                      hint: 'component_handover_process'.tr,
                      text: state.process.value),
                  Expanded(
                      child: InkWell(
                          onTap: () => logic.getHandoverProcessFlow(),
                          child: const Icon(
                            Icons.ads_click_sharp,
                            color: Colors.blueAccent,
                          ))),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Obx(
              () => Row(
                //转出部件
                children: [
                  const SizedBox(width: 10),
                  expandedTextSpan(
                      fontSize: 16,
                      flex: 10,
                      hint: 'component_handover_out_part'.tr,
                      text: state.outPart.value),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Obx(
              () => Row(
                //转出工序
                children: [
                  const SizedBox(width: 10),
                  expandedTextSpan(
                      flex: 10,
                      fontSize: 16,
                      hint: 'component_handover_out_procedure'.tr,
                      text: state.outProcess.value),
                  Expanded(
                      child: InkWell(
                          onTap: () => {logic.getProcessList()},
                          child: const Icon(
                            Icons.ads_click_sharp,
                            color: Colors.blueAccent,
                          ))),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            Obx(
              () => Row(
                //转出部门到转入部门
                children: [
                  const SizedBox(width: 10),
                  Expanded(
                      child: InkWell(
                    child: Text(state.upDepartmentToDown.value,
                        maxLines: 1,
                        style: TextStyle(color: Colors.redAccent.shade100)),
                    onTap: () =>
                        {showSnackBar(message: state.upDepartmentToDown.value)},
                  )),
                  const SizedBox(width: 10),
                ],
              ),
            ),
            _title(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: state.dataList.length,
                    itemBuilder: (context, index) =>
                        _item1(state.dataList[index], index),
                  )),
            ),
            SizedBox(
              width: double.maxFinite,
              child: CombinationButton(
                //查看汇总
                text: 'component_handover_view_summary'.tr,
                click: () => {
                  if (state.summaryDataList.isNotEmpty)
                    {
                      Get.to(() => const ComponentHandoverSummaryPage())?.then(
                        (v) {
                          if (v == null) {
                            showSnackBar(
                                message: 'component_handover_not_handover'.tr);
                            //没有去提交条码
                          } else if (v == true) {
                            //进行交接
                            Get.to(() => SignaturePage(
                                  name: state.empName.value,
                                  callback: (userBase64) =>
                                      logic.submitHandoverInfo(
                                          success: (mes) {
                                            successDialog(
                                                content: mes,
                                                back: () =>
                                                    {logic.clearAllData()});
                                          },
                                          basePhoto: base64Encode(
                                              userBase64.buffer.asUint8List())),
                                ));
                          }
                        },
                      ),
                    }
                  else
                    {
                      showSnackBar(
                          message: 'component_handover_summary_empty'.tr)
                    }
                },
                combination: Combination.intact,
              ),
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

  @override
  void dispose() {
    Get.delete<ComponentHandoverLogic>();
    super.dispose();
  }
}
