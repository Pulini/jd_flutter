import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/home_button.dart';
import 'package:jd_flutter/bean/http/response/label_for_work_card_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_logic.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_state.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

class TeamLeaderAssignsTaskPage extends StatefulWidget {
  const TeamLeaderAssignsTaskPage({super.key});

  @override
  State<TeamLeaderAssignsTaskPage> createState() =>
      _TeamLeaderAssignsTaskPageState();
}

class _TeamLeaderAssignsTaskPageState extends State<TeamLeaderAssignsTaskPage> {
  final TeamLeaderAssignsTaskLogic logic =
      Get.put(TeamLeaderAssignsTaskLogic());
  final TeamLeaderAssignsTaskState state =
      Get.find<TeamLeaderAssignsTaskLogic>().state;

  var teStyle = const TextStyle(
      fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87);

  var tecSearchMes = TextEditingController();
  var batchFillController = TextEditingController();

  late final OptionsPickerController workCenterController;
  late final StreamSubscription<String> _workLineSub;

  @override
  void initState() {
    super.initState();
    workCenterController = OptionsPickerController(
      PickerType.sapWorkCenterNew,
      hasNone: true,
      buttonName: 'team_leader_select_org'.tr,
      onSelected: (i) {
        if (i.pickerId().isNotEmpty) {
          state.getWorkerInfo(
              department:
                  (i as PickerSapWorkCenterNew).departmentID!.toString());
        }
      },
    );
    _workLineSub = state.workLine.listen((v) {
      logger.f('打印：$v');
      if (v.isNotEmpty) {
        workCenterController.selectedName.value = v;
      }
    });
  }

  @override
  void dispose() {
    _workLineSub.cancel();
    super.dispose();
  }

  Widget _personalItem(EmployeeList data) {
    return InkWell(
      onTap: () {
        logic.assignEmployeeToSelectedRow(data.fNumber ?? '');
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            Expanded(
              flex: 1,
              child: Center(
                child: ClipOval(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: data.avatarPath?.isNotEmpty == true
                        ? CachedNetworkImage(
                            imageUrl: data.avatarPath!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey,
                          ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      data.fNumber ?? '',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Text(
                        data.fName ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _materialDetailItem(ComponentList data) {
    var materialText = (data.materialList ?? [])
        .map((e) =>
            '(${e.materialNo ?? ''})${e.materialName ?? ''}<${e.ingredients}${e.englishUnit}>')
        .join('\n');
    final processes = data.processList ?? <String>[];
    final includedProcesses = data.includesProcess ?? <String>[];
    const processBaseStyle = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
    );
    final processSpans = <InlineSpan>[
      TextSpan(text: 'team_leader_process_flow'.tr, style: processBaseStyle)
    ];
    for (var i = 0; i < processes.length; ++i) {
      if (i > 0) {
        processSpans.add(const TextSpan(text: '→', style: processBaseStyle));
      }
      final name = processes[i];
      processSpans.add(TextSpan(
        text: name,
        style: processBaseStyle.copyWith(
          color:
              includedProcesses.contains(name) ? Colors.green : Colors.black87,
        ),
      ));
    }
    return Obx(() {
      final isSelected = state.currentComponent.value == data;
      return GestureDetector(
        onTap: () => logic.loadSizeAllocation(data),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            border: Border.all(
                color: isSelected ? Colors.red : Colors.grey.shade300,
                width: isSelected ? 2 : 1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Obx(() {
                      final isCurrent = state.currentComponent.value == data;
                      final List<SizeList> list = isCurrent
                          ? state.sizeAllocationList
                          : (data.sizeList ?? []);
                      var fully = list.isNotEmpty;
                      for (var item in list) {
                        item.operatorNo.value; // 触碰可观察量
                        item.currentQty.value; // 触碰可观察量
                        if (item.operatorNo.value.trim().isEmpty ||
                            logic.groupRemainingQty(item, list) > 0) {
                          fully = false;
                          break;
                        }
                      }
                      return Text(
                        data.componentName ?? '',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: fully ? Colors.green : Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      );
                    }),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => logic.loadSizeAllocation(data),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'team_leader_assign'.tr,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                child: RichText(
                  text: TextSpan(children: processSpans),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('production_dispatch_dialog_view'.tr,
                          style: const TextStyle(color: Colors.orange)),
                      content: SingleChildScrollView(
                        child: RichText(
                          text: TextSpan(children: processSpans),
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: Text('dialog_default_got_it'.tr),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 8, thickness: 1, color: Color(0xFFEEEEEE)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap:
                        data.fPictureUrl != null && data.fPictureUrl!.isNotEmpty
                            ? () => _showImagePreview(data.fPictureUrl!)
                            : null,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: data.fPictureUrl != null &&
                              data.fPictureUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: CachedNetworkImage(
                                imageUrl: data.fPictureUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image,
                                      size: 20, color: Colors.grey),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.broken_image,
                                      size: 20, color: Colors.grey),
                                ),
                              ),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(Icons.image,
                                  size: 20, color: Colors.grey),
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 用料明细
                  Expanded(
                    flex: 3,
                    child: InkWell(
                      child: Text(
                        materialText,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black54),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      onTap: () {
                        msgDialog(content: materialText);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  // 点击物料缩略图后弹出大图预览
  void _showImagePreview(String url) {
    if (!context.mounted) return;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.85),
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.contain,
              placeholder: (_, __) => const CircularProgressIndicator(
                color: Colors.white,
              ),
              errorWidget: (_, __, ___) =>
                  const Icon(Icons.broken_image, size: 60, color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sizeAllocationRow(SizeList data, int index) {
    return InkWell(
      onTap: () {
        logic.toggleRowSelection(index);
      },
      child: Obx(() => Container(
            decoration: BoxDecoration(
              color: state.selectedRowIndexes.contains(index)
                  ? Colors.blue.shade50
                  : (index % 2 == 0 ? Colors.white : Colors.grey.shade50),
              border: Border.all(
                color: state.selectedRowIndexes.contains(index)
                    ? Colors.blue
                    : Colors.transparent,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    data.size ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    data.fProcessName ?? '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    data.fMtono ?? '',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '${data.totalQty?.toInt() ?? 0}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 32,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SizedBox(
                      height: 24,
                      child: TextField(
                        controller: data.operatorController,
                        onChanged: (v) => logic.checkOperatorInput(data, v),
                        style: const TextStyle(fontSize: 12),
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'team_leader_input_worker_no'.tr,
                          hintStyle:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 4),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 32,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Obx(() {
                      final no = data.operatorNo.value;
                      final emp = no.isEmpty ? null : logic.findEmployee(no);
                      final name = emp?.fName ??
                          (no.isEmpty ? '' : data.operatorName.value);
                      return Text(
                        name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black87),
                      );
                    }),
                  ),
                ),
                SizedBox(
                  width: 32,
                  child: Obx(() => Icon(
                        data.isMatched.value
                            ? Icons.check_circle
                            : Icons.check_circle,
                        color:
                            data.isMatched.value ? Colors.green : Colors.grey,
                        size: 20,
                      )),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SizedBox(
                      height: 24,
                      child: TextField(
                        controller: data.qtyController,
                        onChanged: (v) {
                          final max =
                              logic.rowMaxQty(data, state.sizeAllocationList);
                          final val = int.tryParse(v);
                          if (v.isNotEmpty && (val == null || val > max)) {
                            data.qtyController.text = data.currentQty.value;
                            data.qtyController.selection =
                                TextSelection.fromPosition(TextPosition(
                                    offset: data.qtyController.text.length));
                            showSnackBar(
                                isWarning: true,
                                message: val == null
                                    ? 'team_leader_input_valid_number'.tr
                                    : 'team_leader_qty_exceed_remaining'.tr);
                            return;
                          }
                          data.currentQty.value = v;
                        },
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Obx(() => Text(
                        '${logic.groupRemainingQty(data, state.sizeAllocationList)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black87),
                      )),
                ),
                // 操作：复制（拆成两行）/ 删除
                SizedBox(
                  width: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      InkWell(
                        onTap: () => logic.copySizeAllocation(index),
                        child: const Icon(Icons.copy,
                            size: 20, color: Colors.blue),
                      ),
                      Obx(() {
                        final canDelete = logic.groupRowCount(data) > 1;
                        return InkWell(
                          onTap: canDelete
                              ? () => logic.deleteSizeAllocation(index)
                              : null,
                          child: Icon(
                            Icons.delete,
                            size: 20,
                            color:
                                canDelete ? Colors.red : Colors.grey.shade400,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  Widget _sizeAllocationHeader() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              'team_leader_punch_size'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'team_leader_process'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'team_leader_instruction'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            child: Text(
              'team_leader_total_qty'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'team_leader_worker_no'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'team_leader_employee'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          SizedBox(
            width: 32,
            child: Text(
              'team_leader_match_status'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'team_leader_current_assign_qty'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          Expanded(
            child: Text(
              'team_leader_remain_unassign'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
          SizedBox(
            width: 52,
            child: Text(
              'team_leader_operate'.tr,
              textAlign: TextAlign.center,
              style: teStyle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sizeAllocationFooter() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Obx(() {
        int totalSum = 0;
        int assignedSum = 0;
        final groups = <String, List<SizeList>>{};
        for (var item in state.sizeAllocationList) {
          final key =
              '${(item.fMtono ?? '').trim()}#${(item.size ?? '').trim()}';
          groups.putIfAbsent(key, () => []).add(item);
        }
        groups.forEach((key, items) {
          final isAllocated =
              state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
          final cap = isAllocated
              ? items.fold(0, (s, e) => s + (e.allocatedQty ?? 0))
              : (items.first.totalQty?.toInt() ?? 0);
          final sum = items.fold(
              0, (s, e) => s + (int.tryParse(e.currentQty.value) ?? 0));
          totalSum += cap;
          assignedSum += sum;
        });
        final unassignedSum = totalSum - assignedSum;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: textSpan(
                  hint: 'team_leader_total_sum'.tr, text: totalSum.toString()),
            ),
            Expanded(
                flex: 3,
                child: textSpan(
                    hint: 'team_leader_assigned_sum'.tr,
                    text: assignedSum.toString())),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: textSpan(
                    hint: 'team_leader_unassigned_sum'.tr,
                    text: unassignedSum.toString()),
              ),
            ),
            const SizedBox(width: 52),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: backgroundColor(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(functionTitle),
          actions: [
            Row(
              children: [
                SizedBox(
                  width: 260,
                  child: EditText(
                    hint: 'team_leader_input_work_order_no'.tr,
                    controller: tecSearchMes,
                  ),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.only(left: 5, right: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      if (tecSearchMes.text.isNotEmpty) {
                        if (!tecSearchMes.text.startsWith('GXPG')) {
                          var searchMes = 'GXPG${tecSearchMes.text}';
                          logic.scanSearch(searchMes);
                        } else {
                          logic.scanSearch(tecSearchMes.text);
                        }
                      }
                    },
                    child: Text(
                      'team_leader_search'.tr,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              width: 10,
            ),
            Container(
              height: 40,
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.qr_code_scanner_outlined,
                    size: 20,
                    color: Colors.grey,
                  ),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      Get.to(() => const Scanner())?.then((v) {
                        if (v != null) {
                          logic.scanSearch(v);
                        }
                      });
                    },
                    child: Text(
                      'team_leader_scan_work_order'.tr,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return ListView(
                physics: const ClampingScrollPhysics(),
                children: [
                  SizedBox(
                    height: constraints.maxHeight,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(5),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 6,
                                            offset: Offset(2, 2),
                                            spreadRadius: 1.5,
                                          )
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(
                                                height: 20,
                                                child: VerticalDivider(
                                                  width: 6, // 占用宽度
                                                  thickness: 6, // 线条粗细
                                                  color: Colors.red,
                                                ),
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                  'team_leader_work_order_base_info'
                                                      .tr,
                                                  style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black)),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Obx(
                                                () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                          'team_leader_factory_name'
                                                              .tr,
                                                      text: state
                                                          .factoryName.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                          'team_leader_order_number'
                                                              .tr,
                                                      text: state.orderNo.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                    () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                      'team_leader_doc_date'
                                                          .tr,
                                                      text:
                                                      state.orderDate.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                          'team_leader_production_line_group'
                                                              .tr,
                                                      text:
                                                          state.workLine.value,
                                                      isBold: false),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Obx(
                                                    () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                      'team_leader_product_no'
                                                          .tr,
                                                      text: state
                                                          .productNumber.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                    () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                      'team_leader_doc_rd_no'
                                                          .tr,
                                                      text: state.batchNo.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                          'team_leader_pack_info'
                                                              .tr,
                                                      text: state
                                                          .packMessage.value,
                                                      isBold: false),
                                                ),
                                              ),
                                              Obx(
                                                () => Expanded(
                                                  child: textSpan(
                                                      hint:
                                                          'team_leader_order_total_qty'
                                                              .tr,
                                                      text: state
                                                          .orderAllQty.value,
                                                      isBold: false),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 8, right: 8, bottom: 8),
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(2, 2),
                                              spreadRadius: 1.5,
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  height: 20,
                                                  child: VerticalDivider(
                                                    width: 6,
                                                    thickness: 6,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                    'team_leader_part_material_detail'
                                                        .tr,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black)),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Obx(() => GridView.builder(
                                                    gridDelegate:
                                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                                      crossAxisCount: 2,
                                                      mainAxisSpacing: 8,
                                                      crossAxisSpacing: 8,
                                                      childAspectRatio: 5.5,
                                                    ),
                                                    itemCount: state
                                                        .materialDetailList
                                                        .length,
                                                    itemBuilder: (context,
                                                            index) =>
                                                        _materialDetailItem(
                                                            state.materialDetailList[
                                                                index]),
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 6,
                                                offset: Offset(2, 2),
                                                spreadRadius: 1.5,
                                              )
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // 固定标题行
                                              Row(
                                                children: [
                                                  const SizedBox(
                                                    height: 20,
                                                    child: VerticalDivider(
                                                      width: 6,
                                                      thickness: 6,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                      'team_leader_size_worker_assign_detail'
                                                          .tr,
                                                      style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.black)),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    'team_leader_all_size_must_assign_save'
                                                        .tr,
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.red),
                                                  ),
                                                  const Spacer(),
                                                  // 一键全选所有尺码行
                                                  InkWell(
                                                    onTap: () =>
                                                        logic.selectAllRows(),
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors
                                                                .blue.shade300),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4),
                                                      ),
                                                      child: Text(
                                                          'team_leader_select_all'
                                                              .tr,
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .blue)),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  // 有选中行时才显示：一键取消所有选中
                                                  Obx(() => state
                                                          .selectedRowIndexes
                                                          .isEmpty
                                                      ? const SizedBox.shrink()
                                                      : InkWell(
                                                          onTap: () => logic
                                                              .clearRowSelection(),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical:
                                                                        2),
                                                            decoration:
                                                                BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .red
                                                                      .shade400),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Text(
                                                                'team_leader_cancel_select'
                                                                    .tr,
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .redAccent)),
                                                          ),
                                                        )),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              // 固定表头（始终显示，无数据也保留标题行）
                                              _sizeAllocationHeader(),
                                              // 可滚动的内容区：点击部件「分配」后才加载数据
                                              Obx(() => state
                                                      .showSizeAllocation.value
                                                  ? Expanded(
                                                      child: Obx(() =>
                                                          ListView.builder(
                                                            padding:
                                                                EdgeInsets.zero,
                                                            itemCount: state
                                                                .sizeAllocationList
                                                                .length,
                                                            itemBuilder: (context,
                                                                    index) =>
                                                                _sizeAllocationRow(
                                                                    state.sizeAllocationList[
                                                                        index],
                                                                    index),
                                                          )),
                                                    )
                                                  : const SizedBox.shrink()),
                                              // 固定底栏（有数据时显示）
                                              Obx(() => state
                                                      .showSizeAllocation.value
                                                  ? _sizeAllocationFooter()
                                                  : const SizedBox.shrink()),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    // 工作中心选择器（人员选择上方）
                                    OptionsPicker(
                                      pickerController: workCenterController,
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 8, right: 8, bottom: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 6,
                                              offset: Offset(2, 2),
                                              spreadRadius: 1.5,
                                            )
                                          ],
                                        ),
                                        child: Obx(() => GridView.builder(
                                              padding: const EdgeInsets.all(8),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                mainAxisSpacing: 2,
                                                crossAxisSpacing: 6,
                                                childAspectRatio: 1,
                                              ),
                                              itemCount:
                                                  state.personalList.length,
                                              itemBuilder: (context, index) =>
                                                  _personalItem(state
                                                      .personalList[index]),
                                            )),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        Obx(() => Visibility(
                              visible: state.showButton.value,
                              child: Container(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: CombinationButton(
                                        combination: Combination.left,
                                        text: 'team_leader_reset_assign'.tr,
                                        backgroundColor: Colors.orangeAccent,
                                        click: () => askDialog(
                                          title:
                                              'team_leader_confirm_reset_assign'
                                                  .tr,
                                          content: 'team_leader_reset_tip'.tr,
                                          confirm: () =>
                                              logic.resetAllocation(),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: CombinationButton(
                                        combination: Combination.right,
                                        text: 'team_leader_dispatch_work'.tr,
                                        click: () => askDialog(
                                            content:
                                                'team_leader_sure_dispatch'.tr,
                                            confirm: () {
                                              logic.saveSplitWorkOrder();
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
