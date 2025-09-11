import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/machine_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/feishu_authorize.dart';
import 'machine_dispatch_logic.dart';

class MachineDispatchPage extends StatefulWidget {
  const MachineDispatchPage({super.key});

  @override
  State<MachineDispatchPage> createState() => _MachineDispatchPageState();
}

class _MachineDispatchPageState extends State<MachineDispatchPage> {
  final logic = Get.put(MachineDispatchLogic());
  final state = Get.find<MachineDispatchLogic>().state;

  refreshOrder() => logic.getWorkCardList((list) {
        if (list.length > 1) {
          showWorkCardListDialog(
            list,
            (mdi) {
              state.nowDispatchNumber.value = mdi.dispatchNumber ?? '';
              logic.refreshWorkCardDetail();
            },
          );
        } else {
          state.nowDispatchNumber.value = list[0].dispatchNumber ?? '';
          logic.refreshWorkCardDetail(refreshUI: () => setState(() {}));
        }
      });

  itemTitle() => SizedBox(
        width: 100,
        child: Obx(() => Column(
              children: [
                Container(
                  height: 30,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  alignment: Alignment.center,
                  child: Checkbox(
                    value: logic.isSelectAll(),
                    onChanged: (c) {
                      for (var v in state.selectList) {
                        v.value = c!;
                      }
                    },
                  ),
                ),
                expandedFrameText(
                  text: 'machine_dispatch_size'.tr,
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_total_qty'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_shortage_summary'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_sum_report'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_mould'.tr,
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.blue.shade300,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_day_qty'.tr,
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.blue.shade300,
                  textColor:
                      state.leaderVerify.value ? Colors.white : Colors.red,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_last_not_fill'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_box_capacity'.tr,
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.orange.shade100,
                  textColor:
                      state.leaderVerify.value ? Colors.white : Colors.black87,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_label_total'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_boxes'.tr,
                  backgroundColor: Colors.green.shade200,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_duty_not_fill'.tr,
                  backgroundColor: Colors.green.shade200,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: 'machine_dispatch_report_qty'.tr,
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
              ],
            )),
      );

  item(Items data, RxBool isSelect) => Obx(() => SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              alignment: Alignment.center,
              child: Checkbox(
                value: isSelect.value,
                onChanged: (c) => isSelect.value = c!,
              ),
            ),
            expandedFrameText(
              text: data.size ?? '',
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.sumQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.sumUnderQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.sumReportQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.mould.toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
              click: () {
                if (state.leaderVerify.value) {
                  showMachineInputDialog(
                      data: data,
                      maxMould: state.detailsInfo?.getProposalMoulds().floor() ?? 0,
                      confirm: () => setState(() {})
                  );
                }
              },
            ),
            expandedFrameText(
              text: data.getTodayDispatchQty().toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.blue.shade300,
              textColor: state.leaderVerify.value ? Colors.white : Colors.red,
              alignment: Alignment.center,
              click: () {
                if (state.leaderVerify.value) {
                  showInputDayReportDialog(
                      data: data,
                      confirm: () => setState(() {}));
                }
              },
            ),
            expandedFrameText(
              text: data.lastNotFullQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              textColor:
                  data.lastMantissaFlag == 1 ? Colors.red : Colors.black87,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.capacity.toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.orange.shade100,
              textColor:
                  state.leaderVerify.value ? Colors.white : Colors.black87,
              alignment: Alignment.center,
              click: () {
                if (state.leaderVerify.value) {
                  showInputCapacityDialog(
                      data: data,
                      confirm: () => setState(() {})
                    );
                }
              },
            ),
            expandedFrameText(
              text: data.labelQty.toString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.boxesQty.toShowString(),
              backgroundColor: Colors.green.shade200,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: data.notFullQty.toShowString(),
              backgroundColor: Colors.green.shade200,
              textColor: Colors.white,
              alignment: Alignment.center,
              click: () {
                if (logic.statusReportedAndGenerate()) {
                  msgDialog(
                    content: '无法再次产量汇报',
                  );
                } else {
                  showInputLastNumDialog(
                      data: data,
                      confirm: () => setState(() {}));
                }
              },
            ),
            expandedFrameText(
              text: data.getReportQty().toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
          ],
        ),
      ));

  totalItem(List<Items> data) {
    var sumQty = 0.0;
    var sumUnderQty = 0.0;
    var sumReportQty = 0.0;
    var mould = 0.0;
    var lastNotFullQty = 0.0;
    var capacity = 0.0;
    var boxesQty = 0.0;
    var notFullQty = 0.0;
    var todayDispatchQty = 0.0;
    var reportQty = 0.0;
    var labelQty = 0;
    for (var v in data) {
      sumQty = sumQty.add(v.sumQty ?? 0.0);
      sumUnderQty = sumUnderQty.add(v.sumUnderQty ?? 0.0);
      sumReportQty = sumReportQty.add(v.sumReportQty ?? 0.0);
      mould = mould.add(v.mould ?? 0.0);
      lastNotFullQty = lastNotFullQty.add(v.lastNotFullQty ?? 0.0);
      capacity = capacity.add(v.capacity ?? 0.0);
      boxesQty = boxesQty.add(v.boxesQty ?? 0.0);
      notFullQty = notFullQty.add(v.notFullQty ?? 0.0);
      todayDispatchQty = todayDispatchQty.add(v.getTodayDispatchQty());
      reportQty = reportQty.add(v.getReportQty());
      labelQty = labelQty += v.labelQty;
    }
    return Obx(
      () => SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: 'machine_dispatch_total'.tr,
              backgroundColor: Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: sumQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: sumUnderQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: sumReportQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: mould.toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.blue.shade300,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: todayDispatchQty.toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.blue.shade300,
              textColor: state.leaderVerify.value ? Colors.white : Colors.red,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: lastNotFullQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              textColor: Colors.black87,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: capacity.toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.orange.shade100,
              textColor:
                  state.leaderVerify.value ? Colors.white : Colors.black87,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: labelQty.toString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: boxesQty.toShowString(),
              backgroundColor: Colors.green.shade200,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: notFullQty.toShowString(),
              backgroundColor: Colors.green.shade200,
              textColor: Colors.white,
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: reportQty.toShowString(),
              backgroundColor: Colors.orange.shade100,
              alignment: Alignment.center,
            ),
          ],
        ),
      ),
    );
  }

  pageTitle() => Container(
        margin: const EdgeInsets.only(left: 10, bottom: 5, right: 10),
        padding: const EdgeInsets.all(5),
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.green.shade50],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                expandedTextSpan(
                  hint: 'machine_dispatch_decreasing_number'.tr,
                  text: state.detailsInfo?.decrementNumber ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_start_date'.tr,
                  text: state.detailsInfo?.startDate ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_dispatch_no'.tr,
                  text: state.detailsInfo?.dispatchNumber ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_single_weight'.tr,
                  text: (state.detailsInfo?.weight ?? 0.0).toShowString(),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                expandedTextSpan(
                  hint: 'machine_dispatch_material_code'.tr,
                  text: state.detailsInfo?.materialNumber ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_type_body'.tr,
                  text: state.detailsInfo?.factoryType ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_decreasing_machine'.tr,
                  text: state.detailsInfo?.decreasingMachine ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_actual_machine'.tr,
                  text: state.detailsInfo?.machine ?? '',
                  textColor: Colors.red,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                expandedTextSpan(
                  hint: 'machine_dispatch_shift_schedule'.tr,
                  text: state.detailsInfo?.shift ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_process'.tr,
                  text: state.detailsInfo?.processflow ?? '',
                ),
                expandedTextSpan(
                  hint: 'machine_dispatch_mold_number'.tr,
                  text: state.detailsInfo?.moldNo ?? '',
                ),
                expandedTextSpan(
                  hint: '建议模具数：',
                  text: (state.detailsInfo?.getProposalMoulds() ?? 0)
                      .toShowString(),
                  textColor: Colors.red,
                ),
              ],
            ),
            textSpan(
              hint: 'machine_dispatch_material_name'.tr,
              text: state.detailsInfo?.materialName ?? '',
              fontSize: 16,
            ),
            if (state.leaderVerify.value)
              Text(
                'machine_dispatch_tips'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              )
            else
              textSpan(
                hint: 'machine_dispatch_remarks'.tr,
                hintColor: Colors.red,
                text: state.detailsInfo?.remarks ?? '',
                textColor: Colors.red,
              ),
          ],
        ),
      );

  bottomButton() => Obx(
        () => Row(
          children: [
            if (!state.leaderVerify.value)
              CombinationButton(
                text: 'machine_dispatch_leader_operation'.tr,
                click: () {
                  if (logic.statusReportedAndGenerate()) {
                    msgDialog(
                      content: 'machine_dispatch_modify_error_tips'.tr,
                    );
                  } else {
                    teamLeaderVerifyDialog();
                  }
                },
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: 'machine_dispatch_clean_last'.tr,
                isEnabled: logic.hasSelected(),
                click: () => logic.cleanOrRecoveryLastQty(true),
                combination: Combination.left,
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: 'machine_dispatch_restore_last'.tr,
                isEnabled: logic.hasSelected(),
                click: () => logic.cleanOrRecoveryLastQty(false),
                combination: Combination.middle,
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: 'machine_dispatch_modify_order'.tr,
                click: () {
                  askDialog(
                    content: 'machine_dispatch_modify_tips'.tr,
                    confirm: () => logic.modifyWorkCardItem(),
                  );
                },
                combination: Combination.right,
              ),
            Expanded(child: Container()),
            CombinationButton(
              text: 'machine_dispatch_label_history'.tr,
              click: () => logic.getHistoryInfo(),
              combination: Combination.left,
            ),
            CombinationButton(
              text: 'machine_dispatch_process_manual'.tr,
              click: () => feishuViewWikiFiles(
                query: state.detailsInfo?.factoryType ?? '',
              ),
              combination: Combination.middle,
            ),
            CombinationButton(
              text: 'machine_dispatch_generate_and_print'.tr,
              isEnabled: logic.isSelectedOne(),
              click: () {
                if (logic.statusReportedAndGenerate()) {
                  msgDialog(
                    content: '已经进行过员工汇报，无法再打标',
                  );
                } else {
                  generateAndPrintDialog(
                    printLast: () =>
                        logic.generateAndPrintLabel(isPrintLast: true),
                    print: () =>
                        logic.generateAndPrintLabel(isPrintLast: false),
                  );
                }
              },
              combination: Combination.middle,
            ),
            CombinationButton(
              text: 'machine_dispatch_generate_and_print_english'.tr,
              isEnabled: logic.isSelectedOne(),
              click: () {
                if (logic.statusReportedAndGenerate()) {
                  msgDialog(
                    content: '已经进行过员工汇报，无法再打标',
                  );
                } else {
                  logic.getEnglishLabel((label) {
                    selectLabelTypeDialog(
                      englishLabel: label,
                      printLast: (weight, specifications) =>
                          logic.generateAndPrintLabel(
                        isPrintLast: true,
                        isEnglish: true,
                        weight: weight,
                        specifications: specifications,
                      ),
                      print: (weight, specifications) =>
                          logic.generateAndPrintLabel(
                        isPrintLast: false,
                        isEnglish: true,
                        weight: weight,
                        specifications: specifications,
                      ),
                    );
                  });
                }
              },
              combination: Combination.middle,
            ),
            CombinationButton(
              text: 'machine_dispatch_number_confirmation'.tr,
              isEnabled: state.detailsInfo?.barCodeList?.isNotEmpty == true,
              click: () => logic.workerDispatchConfirmation(),
              combination: Combination.middle,
            ),
            CombinationButton(
              text: 'machine_dispatch_cancel_number_confirmation'.tr,
              isEnabled: state.detailsInfo?.barCodeList?.isNotEmpty == true,
              click: () {
                if (logic.statusReportedAndGenerate()) {
                  msgDialog(
                    content: '请先进行员工确认！',
                  );
                } else {
                  askDialog(
                    content: '确定要取消员工确认吗？',
                    confirm: () => logic.cancelWorkerDispatchConfirmation(),
                  );
                }
              },
              combination: Combination.middle,
            ),
            CombinationButton(
              text: 'machine_dispatch_handover_shifts'.tr,
              isEnabled: logic.hasReported(),
              click: () => logic.handoverShifts(),
              combination: Combination.right,
            ),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshOrder());
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [
          Obx(() => state.hasDetails.value
              ? CombinationButton(
                  text: 'machine_dispatch_surplus_material_info'.tr,
                  click: () => showSurplusMaterialListDialog(
                    context,
                    print: (code, name, detail) {
                      logic.printMaterialHeadLabel(code, name, detail);
                    },
                  ),
                  combination: Combination.left,
                )
              : Container()),
          Obx(() => state.hasDetails.value
              ? CombinationButton(
                  text: 'machine_dispatch_label_list'.tr,
                  click: () {
                    if (state.labelErrorMsg.isNotEmpty) {
                      errorDialog(content: state.labelErrorMsg);
                    } else {
                      showLabelListDialog(
                        context: context,
                        print: (label) => logic.printLabel(label),
                      );
                    }
                  },
                  combination: Combination.middle,
                )
              : Container()),
          Obx(() => CombinationButton(
                text: 'machine_dispatch_change_order'.tr,
                click: refreshOrder,
                combination: state.hasDetails.value
                    ? Combination.middle
                    : state.nowDispatchNumber.value.isEmpty
                        ? Combination.intact
                        : Combination.left,
              )),
          Obx(() => state.nowDispatchNumber.value.isNotEmpty
              ? CombinationButton(
                  text: 'machine_dispatch_refresh'.tr,
                  click: () => logic.refreshWorkCardDetail(),
                  combination: Combination.right,
                )
              : Container())
        ],
        body: Column(
          children: [
            Obx(() => state.hasDetails.value ? pageTitle() : Container()),
            Expanded(
              child: Obx(() => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                    children: [
                      if (state.sizeItemList.isNotEmpty) itemTitle(),
                      for (var i = 0; i < state.sizeItemList.length; ++i)
                        item(state.sizeItemList[i], state.selectList[i]),
                      if (state.sizeItemList.isNotEmpty)
                        totalItem(state.sizeItemList)
                    ],
                  )),
            ),
            Obx(() => state.hasDetails.value ? bottomButton() : Container())
          ],
        ));
  }

  @override
  void dispose() {
    Get.delete<MachineDispatchLogic>();
    super.dispose();
  }
}
