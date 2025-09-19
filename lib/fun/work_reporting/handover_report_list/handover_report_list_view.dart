import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/show_handover_report_list.dart';
import 'package:jd_flutter/fun/work_reporting/handover_report_list/handover_report_list_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/spinner_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class HandoverReportListPage extends StatefulWidget {
  const HandoverReportListPage({super.key});

  @override
  State<HandoverReportListPage> createState() => _HandoverReportListPageState();
}

class _HandoverReportListPageState extends State<HandoverReportListPage> {
  final logic = Get.put(HandoverReportListLogic());
  final state = Get.find<HandoverReportListLogic>().state;

  _text({
    required String mes,
    required bool head,
    required bool judge,
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
    if (judge) {
      backColor = Colors.yellow.shade200;
    }
    return Container(
      height: 35,
      decoration: BoxDecoration(
        color: backColor, // 背景颜色
        border: Border.all(
          color: Colors.grey, // 边框颜色
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
        Expanded(
            child: _text(
          mes: 'handover_report_size'.tr,
          head: true,
          judge: false,
        )),
        Expanded(
            child: _text(
          mes: 'handover_report_box_capacity'.tr,
          head: true,
          judge: false,
        )),
        Expanded(
            child: _text(
          mes: 'handover_report_box_number'.tr,
          head: true,
          judge: false,
        )),
        Expanded(
            child: _text(
          mes: 'handover_report_last_number'.tr,
          head: true,
          judge: false,
        )),
        Expanded(
            child: _text(
          mes: 'handover_report_now_number'.tr,
          head: true,
          judge: false,
        )),
        Expanded(
            child: _text(
          mes: 'handover_report_single_subtotal'.tr,
          head: true,
          judge: false,
        )),
      ],
    );
  }

  _subTitle(SubList sub, bool judge) {
    return Row(
      children: [
        Expanded(
            child: _text(
          mes: sub.subSize ?? '',
          head: false,
          judge: judge,
        )),
        Expanded(
            child: _text(
          mes: sub.subCapacity.toShowString(),
          head: false,
          judge: judge,
        )),
        Expanded(
            child: _text(
          mes: sub.subBox.toShowString(),
          head: false,
          judge: judge,
        )),
        Expanded(
            child: _text(
          mes: sub.subLastMantissa.toShowString(),
          head: false,
          judge: judge,
        )),
        Expanded(
            child: _text(
          mes: sub.subMantissa.toShowString(),
          head: false,
          judge: judge,
        )),
        Expanded(
            child: _text(
          mes: sub.subQty.toShowString(),
          head: false,
          judge: judge,
        )),
      ],
    );
  }

  _item1(ShowHandoverReportList data, int position) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: data.select == true
                ? [Colors.red.shade100, Colors.white]
                : [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        foregroundDecoration: RotatedCornerDecoration.withColor(
          color: data.status == true ? Colors.green : Colors.red,
          badgeCornerRadius: const Radius.circular(8),
          badgeSize: const Size(45, 45),
          textSpan: TextSpan(
            text: data.status == true
                ? 'handover_report_reported'.tr
                : 'handover_report_unreported'.tr,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                expandedTextSpan(
                    //机台
                    hint: 'handover_report_machine'.tr,
                    text: data.machine ?? '',
                    textColor: Colors.blue.shade500,
                    hintColor: Colors.black),
                expandedTextSpan(
                  //班次
                  hint: 'handover_report_shift'.tr,
                  text: data.shift ?? '',
                  hintColor: Colors.black,
                  textColor: Colors.blue.shade500,
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                    //型体
                    hint: 'handover_report_type_body'.tr,
                    text: data.factoryType ?? '',
                    textColor: Colors.blue.shade500,
                    hintColor: Colors.black),
                expandedTextSpan(
                  //派工单号
                  hint: 'handover_report_dispatch_number'.tr,
                  text: data.dispatchNumber ?? '',
                  textColor: Colors.blue.shade500,
                  hintColor: Colors.black,
                ),
              ],
            ),
            Text(data.processName.toString()),
            _title(),
            for (var i = 0; i < data.subList!.length; ++i)
              _subTitle(data.subList![i], data.changeColor!),
          ],
        ),
      ),
      onTap: () => logic.selectPosition(position),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        title: 'handover_report_title'.tr,
        actions: [
          TextButton(
              onPressed: () => logic.getInstructionDetailsFile(),
              child: Text('handover_report_query'.tr))
        ],
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DatePicker(pickerController: logic.pickerControllerDate),
                Obx(() => CheckBox(
                      onChanged: (c) =>
                          {state.isChecked.value = c, logic.selectAll(c)},
                      name: '',
                      value: state.isChecked.value,
                    ))
              ],
            ),
            SizedBox(
              child: Row(
                children: [
                  Expanded(
                    child: Spinner(controller: logic.reportType),
                  ),
                  Expanded(child: Spinner(controller: logic.shiftType))
                ],
              ),
            ),
            Expanded(
              child: Obx(() => ListView.builder(
                    shrinkWrap: true,
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
                    //提交汇报
                    text: 'handover_report_submit_report'.tr,
                    click: () {
                      if (logic.haveSelect()) {
                        askDialog(
                            content: '确定要提交汇报吗?',
                            confirm: () {
                              logic.checkWork(success: (s) {
                                successDialog(
                                    content: s,
                                    back: () {
                                      logic.getInstructionDetailsFile();
                                    });
                              });
                            });
                      }
                    },
                    combination: Combination.left,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //取消报工
                    text: 'handover_report_cancel_report'.tr,
                    click: () {
                      if (logic.haveSelect()) {
                        askDialog(
                          content: 'handover_report_sure_reverse'.tr,
                          confirm: () {
                            logic.reverseWork(success: (s) {
                              successDialog(
                                content: s,
                                back: () => logic.getInstructionDetailsFile(),
                              );
                            });
                          },
                        );
                      }
                    },
                    combination: Combination.middle,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CombinationButton(
                    //删除报工
                    text: 'handover_report_delete_report'.tr,
                    click: () {
                      if (logic.haveSelect()) {
                        askDialog(
                          content: 'handover_report_sure_delete'.tr,
                          confirm: () {
                            logic.deleteWork(success: (s) {
                              successDialog(
                                content: s,
                                back: () => logic.getInstructionDetailsFile(),
                              );
                            });
                          },
                        );
                      }
                    },
                    combination: Combination.right,
                  ),
                )
              ],
            )
          ],
        ));
  }

  @override
  void dispose() {
    Get.delete<HandoverReportListLogic>();
    super.dispose();
  }
}
