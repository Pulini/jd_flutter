import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_report_ticket_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_cancel/part_report_cancel_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

class PartReportCancelPage extends StatefulWidget {
  const PartReportCancelPage({super.key});

  @override
  State<PartReportCancelPage> createState() => _PartReportCancelPageState();
}

class _PartReportCancelPageState extends State<PartReportCancelPage> {
  final logic = Get.put(PartReportCancelLogic());
  final state = Get.find<PartReportCancelLogic>().state;

  var controller = TextEditingController();

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
    return InkWell(
      child: Container(
        height: 35,
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
      ),
      onTap: () => showSnackBar(message: mes),
    );
  }

  _item1(TicketItem sub) {
    return Row(
      children: [
        Expanded(
            child: _text(
          mes: sub.processName ?? '',
          head: false,
        )),
        Expanded(
            child: _text(
          mes: sub.mtono ?? '',
          head: false,
        )),
        Expanded(
            child: _text(
          mes: sub.size ?? '',
          head: false,
        )),
        Expanded(
            child: _text(
          mes: sub.qty.toShowString(),
          head: false,
        )),
      ],
    );
  }

  _title() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: _text(
              mes: 'part_report_cancel_title_process'.tr,
              head: true,
            )),
        Expanded(
            flex: 2,
            child: _text(
              mes: 'part_report_cancel_title_instruction'.tr,
              head: true,
            )),
        Expanded(
            child: _text(
          mes: 'part_report_cancel_title_size'.tr,
          head: true,
        )),
        Expanded(
            child: _text(
          mes: 'part_report_cancel_title_qty'.tr,
          head: true,
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'part_report_cancel_title'.tr,
        body: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5), // 左右 5 像素
                    child:  CupertinoSearchTextField( //工票
                      prefixIcon: const SizedBox.shrink(),
                      controller: controller,
                      suffixIcon:const Icon(CupertinoIcons.search),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onChanged: (s){
                        state.workTicket = s;
                      },
                      onSuffixTap:(){
                        logic.getReportSummary(controller.text.toString());
                      },
                      placeholder: 'part_report_cancel_scan_ticket'.tr,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    onPressed: () => {
                      Get.to(() => const Scanner())?.then((v) {
                        if (v != null) {
                          controller.text = v;
                          logic.getReportSummary(v);
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
            textSpan(
                hint: 'part_report_cancel_type_body'.tr,
                text: state.factory.value),
            textSpan(
                hint: 'part_report_cancel_part'.tr, text: state.part.value),
            textSpan(
                hint: 'part_report_cancel_process'.tr,
                text: state.processName.value),
            Row(
              children: [
                expandedTextSpan(
                    hint: 'part_report_cancel_qty'.tr, text: state.qty.value),
                expandedTextSpan(
                    hint: 'part_report_cancel_personal'.tr,
                    text: '${userInfo?.name}(${userInfo?.number})')
              ],
            ),
            _title(),
            Expanded(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.dataList.length,
                    itemBuilder: (context, index) =>
                        _item1(state.dataList[index]),
                  )),
            ),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    //查询
                    text: 'part_report_cancel_query'.tr,
                    click: () => logic.getReportSummary(controller.text),
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  //取消报工
                  child: CombinationButton(
                    text: 'part_report_cancel_cancel_job'.tr,
                    click: () => {
                      askDialog(
                        content: 'part_report_cancel_sure_cancel'.tr,
                        confirm: () {
                          logic.cancelPart(success: (s)=> successDialog(content: s,back: ()=>{
                              logic.cleanData()
                          }));
                        },
                      )
                    },
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    //提交
                    text: 'part_report_cancel_cancel_submit'.tr,
                    click: () => {
                      if (logic.checkPeople())
                        logic.submitPart(success: (s) {
                          successDialog(
                              content: s, back: () => logic.cleanData());
                        })
                      else
                        {
                          askDialog(
                            content: 'part_report_cancel_confirm_job'.tr,
                            confirm: () {
                              logic.submitPart(success: (s) {
                                successDialog(
                                    content: s, back: () => logic.cleanData());
                              });
                            },
                          )
                        }
                    },
                    combination: Combination.right,
                  ),
                ),
              ],
            )
          ],
        ));
  }

  @override
  void initState() {
    pdaScanner(
      scan: (code) => {controller.text = code, logic.getReportSummary(code)},
    );
    super.initState();
  }

  @override
  void dispose() {
    Get.delete<PartReportCancelLogic>();
    super.dispose();
  }
}
