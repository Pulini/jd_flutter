import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/machine_dispatch/machine_dispatch_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/machine_dispatch_info.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/dialogs.dart';
import 'machine_dispatch_logic.dart';
import 'machine_dispatch_report_view.dart';

class MachineDispatchPage extends StatefulWidget {
  const MachineDispatchPage({super.key});

  @override
  State<MachineDispatchPage> createState() => _MachineDispatchPageState();
}

class _MachineDispatchPageState extends State<MachineDispatchPage> {
  final logic = Get.put(MachineDispatchLogic());
  final state = Get.find<MachineDispatchLogic>().state;

  refreshOrder() => logic.getWorkCardList(
        (list) {
          if (list.length > 1) {
            showWorkCardListDialog(
              list,
              (mdi) => logic.getWorkCardDetail(mdi, () => setState(() {})),
            );
          } else {
            logic.getWorkCardDetail(list[0], () => setState(() {}));
          }
        },
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => refreshOrder());
  }

  itemTitle() => SizedBox(
        width: 100,
        child: Obx(() => Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  alignment: Alignment.center,
                  child: Checkbox(
                    value: state.selectList.isNotEmpty &&
                        state.selectList.where((v) => v.value).length ==
                            state.selectList.length,
                    onChanged: (c) {
                      for (var v in state.selectList) {
                        v.value = c!;
                      }
                    },
                  ),
                ),
                expandedFrameText(
                  text: '尺码',
                  backgroundColor: Colors.blue.shade300,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '总数量',
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '欠数汇总',
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '累计报工',
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '模具',
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.blue.shade300,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '当日派工数',
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.blue.shade300,
                  textColor:
                      state.leaderVerify.value ? Colors.white : Colors.red,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '上班未满箱数',
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '箱容',
                  backgroundColor: state.leaderVerify.value
                      ? Colors.green.shade200
                      : Colors.orange.shade100,
                  textColor:
                      state.leaderVerify.value ? Colors.white : Colors.black87,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '贴标总数',
                  backgroundColor: Colors.orange.shade100,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '箱数',
                  backgroundColor: Colors.green.shade200,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '本班未满箱数',
                  backgroundColor: Colors.green.shade200,
                  textColor: Colors.white,
                  alignment: Alignment.center,
                ),
                expandedFrameText(
                  text: '报工数量',
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
              height: 40,
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
                click: () {}),
            expandedFrameText(
              text: data.getTodayDispatchQty().toShowString(),
              backgroundColor: state.leaderVerify.value
                  ? Colors.green.shade200
                  : Colors.blue.shade300,
              textColor: state.leaderVerify.value ? Colors.white : Colors.red,
              alignment: Alignment.center,
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
              height: 40,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              alignment: Alignment.center,
            ),
            expandedFrameText(
              text: '合计',
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
        padding: const EdgeInsets.all(10),
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
                  hint: '递减编号：',
                  text: state.detailsInfo?.decrementNumber ?? '',
                ),
                expandedTextSpan(
                  hint: '开工日期：',
                  text: state.detailsInfo?.startDate ?? '',
                ),
                expandedTextSpan(
                  hint: '派工单号：',
                  text: state.detailsInfo?.dispatchNumber ?? '',
                ),
                expandedTextSpan(
                  hint: '单重：',
                  text: (state.detailsInfo?.weight ?? 0.0).toShowString(),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                expandedTextSpan(
                  hint: '物料编码：',
                  text: state.detailsInfo?.materialNumber ?? '',
                ),
                expandedTextSpan(
                  hint: '工厂型体：',
                  text: state.detailsInfo?.factoryType ?? '',
                ),
                expandedTextSpan(
                  hint: '递减机台：',
                  text: state.detailsInfo?.decreasingMachine ?? '',
                ),
                expandedTextSpan(
                  hint: '实际机台：',
                  hintColor: Colors.red,
                  text: state.detailsInfo?.machine ?? '',
                  textColor: Colors.red,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                expandedTextSpan(
                  hint: '班次：',
                  text: state.detailsInfo?.shift ?? '',
                ),
                expandedTextSpan(
                  hint: '制程：',
                  text: state.detailsInfo?.processflow ?? '',
                ),
                expandedTextSpan(
                  hint: '模具号：',
                  text: state.detailsInfo?.moldNo ?? '',
                ),
                expandedTextSpan(hint: '', text: ''),
              ],
            ),
            textSpan(
              hint: '物料名称：',
              text: state.detailsInfo?.materialName ?? '',
              fontSize: 18,
            ),
            textSpan(
              hint: '备注：',
              hintColor: Colors.red,
              text: state.detailsInfo?.remarks ?? '',
              textColor: Colors.red,
              fontSize: 18,
            ),
          ],
        ),
      );

  bottomButton() => Obx(
        () => Row(
          children: [
            if (!state.leaderVerify.value)
              CombinationButton(
                text: '班组长操作',
                click: () => teamLeaderVerifyDialog(),
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: '清理上班尾数',
                isEnabled: state.selectList.any((v) => v.value),
                click: () => logic.cleanOrRecoveryLastQty(
                  true,
                  () => setState(() {}),
                ),
                combination: Combination.left,
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: '恢复上班尾数',
                isEnabled: state.selectList.any((v) => v.value),
                click: () => logic.cleanOrRecoveryLastQty(
                  false,
                  () => setState(() {}),
                ),
                combination: Combination.middle,
              ),
            if (state.leaderVerify.value)
              CombinationButton(
                text: '修改工单',
                click: () {
                  if (state.detailsInfo?.status == 2) {
                    informationDialog(content: '已工资汇报，请先删除工汇报！');
                  } else {
                    askDialog(
                      content: '确定要修改当前工单的模具和箱容吗？',
                      confirm: () => logic.modifyWorkCardItem(
                        () => setState(() {}),
                      ),
                    );
                  }
                },
                combination: Combination.right,
              ),
            Expanded(child: Container()),
            CombinationButton(
              text: '历史贴标',
              click: () {
                // Get.to(()=> TestApp());
                Get.to(()=> const MachineDispatchReportPage());
                },
              combination: Combination.left,
            ),
            CombinationButton(
              text: '生成并打印',
              click: () {},
              combination: Combination.middle,
            ),
            CombinationButton(
              text: '工艺指导书',
              click: () {},
              combination: Combination.middle,
            ),
            CombinationButton(
              text: '产量汇报',
              click: () {},
              combination: Combination.middle,
            ),
            if (state.detailsInfo?.barCodeList?.isNotEmpty == true)
              CombinationButton(
                text: '取消工号确认',
                click: () {},
                combination: Combination.middle,
              ),
            if (state.detailsInfo?.barCodeList?.isNotEmpty == true)
              CombinationButton(
                text: '工号确认',
                click: () => logic.checkLabelScanState(),
                combination: Combination.middle,
              ),
            CombinationButton(
              text: '两班交接',
              click: () {},
              combination: Combination.right,
            ),
          ],
        ),
      );
  var remake =
      '注：1、清理或恢复上班尾数需要先勾选要修改的尺码列。2、点击对应尺码的模具或箱容进行数量修改，然后点击《修改工单》进行修改提交。';

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => pageBody(
          actions: [
            if (state.detailsInfo != null)
              CombinationButton(
                text: '料头信息',
                click: () => showSurplusMaterialListDialog(
                  context,
                  print: (c) {},
                ),
                combination: Combination.left,
              ),
            if (state.detailsInfo != null)
              CombinationButton(
                text: '贴标列表',
                click: () {
                  if (state.labelErrorMsg.isNotEmpty) {
                    errorDialog(content: state.labelErrorMsg);
                  } else {
                    showLabelListDialog(context);
                  }
                },
                combination: Combination.middle,
              ),
            CombinationButton(
              text: '切换工单',
              click: refreshOrder,
              combination: state.detailsInfo != null
                  ? Combination.middle
                  : state.nowDispatchNumber.value.isEmpty
                      ? Combination.intact
                      : Combination.left,
            ),
            if (state.nowDispatchNumber.value.isNotEmpty)
              CombinationButton(
                text: '刷新',
                click: () => logic.refreshWorkCardDetail(() => setState(() {})),
                combination: Combination.right,
              ),
          ],
          body: Column(
            children: [
              if (state.detailsInfo != null) pageTitle(),
              if (state.leaderVerify.value)
                Text(
                  remake,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              Expanded(
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 10, top: 5, right: 10),
                  children: [
                    if (state.sizeItemList.isNotEmpty) itemTitle(),
                    for (var i = 0; i < state.sizeItemList.length; ++i)
                      item(state.sizeItemList[i], state.selectList[i]),
                    if (state.sizeItemList.isNotEmpty)
                      totalItem(state.sizeItemList)
                  ],
                ),
              ),
              if (state.detailsInfo != null) bottomButton()
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<MachineDispatchLogic>();
    super.dispose();
  }
}
