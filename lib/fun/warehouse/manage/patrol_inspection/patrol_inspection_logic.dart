import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/fun/warehouse/manage/patrol_inspection/patrol_inspection_report_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'patrol_inspection_state.dart';

class PatrolInspectionLogic extends GetxController {
  final PatrolInspectionState state = PatrolInspectionState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  getPatrolInspectionInfo() {
    state.getPatrolInspectionInfo(
      success: (selected) => selectLine(selected == -1 ? 0 : selected),
    );
  }

  String getSelectLine() {
    if (state.inspectionList.isEmpty) {
      return state.errorMsg.value;
    } else {
      return state.inspectionList
              .firstWhere(
                (v) => v.isSelected.value,
                orElse: () =>
                    state.inspectionList.first..isSelected.value = true,
              )
              .produceUnitName ??
          '';
    }
  }

  addPatrolInspectionAbnormalRecord({
    PatrolInspectionAbnormalItemInfo? abnormalItem,
  }) {
    if (abnormalItem == null) {
      state.addPatrolInspectionRecord(
        abnormalItemId: 'QUALIFIED',
        success: (newAbnormal) {
          showScanTips(color: Colors.green);
          state.abnormalRecordList.add(PatrolInspectionAbnormalRecordInfo(
            abnormalRecordId: newAbnormal.abnormalRecordId,
            abnormalItemId: newAbnormal.abnormalItemId,
            recordDate: newAbnormal.recordDate,
            typeBody: newAbnormal.typeBody,
          ));
        },
        error: (msg) => errorDialog(content: msg),
      );
    } else {}
    state.addPatrolInspectionRecord(
      abnormalItemId: abnormalItem!.abnormalItemId!,
      success: (newAbnormal) {
        showScanTips(color: Colors.red);
        state.abnormalRecordList.add(PatrolInspectionAbnormalRecordInfo(
          abnormalRecordId: newAbnormal.abnormalRecordId,
          abnormalItemId: newAbnormal.abnormalItemId,
          recordDate: newAbnormal.recordDate,
          typeBody: newAbnormal.typeBody,
        ));
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  changeLine(int index) {
    final oldIndex = state.inspectionList.indexWhere((v) => v.isSelected.value);
    // 如果选中的是同一项则直接返回
    if (oldIndex == index) return;
    // 清除旧选中状态（如果有）
    if (oldIndex != -1) {
      state.inspectionList[oldIndex].isSelected.value = false;
    }
    selectLine(index);
  }

  selectLine(int index) {
    // 设置新选中项
    final selectedItem = state.inspectionList[index];
    selectedItem.isSelected.value = true;

    // 更新相关状态
    state.abnormalRecordList.value = selectedItem.abnormalRecords!;
    state.abnormalItemList.value = selectedItem.abnormalItems!;
    state.typeBodyList.value = selectedItem.typeBodyList!;

    // 计算 typeBodyIndex
    final inspectionIndex =
        state.typeBodyList.indexWhere((v) => v.isInspection == true);
    state.typeBodyIndex.value = inspectionIndex != -1 ? inspectionIndex : 0;

    // 保存选中项ID
    spSave(
      spSavePatrolInspectionLineId,
      selectedItem.produceUnitId ?? '',
    );
  }

  deleteAbnormalRecord({
    required PatrolInspectionAbnormalRecordInfo abnormalRecord,
  }) {
    state.deleteAbnormalRecord(
      abnormalRecord: abnormalRecord,
      success: (msg) {
        state.abnormalRecordList.removeWhere(
            (v) => v.abnormalRecordId == abnormalRecord.abnormalRecordId);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<List<PatrolInspectionAbnormalRecordInfo>> getAbnormalGroup() {
    return groupBy(
      state.abnormalRecordList,
      (v) => '${v.typeBody}',
    ).values.toList();
  }

  getPatrolInspectionReport(String patrolInspectDate) {
    state.getPatrolInspectionReport(
      patrolInspectDate: patrolInspectDate,
      success: () => Get.to(() => const PatrolInspectionReportPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  List getMorningReport() {
    var morningList = state.reportList
        .where((v) =>
            v.recordDate != null && DateTime.parse(v.recordDate!).hour < 12)
        .toList();
    var morningReport =
        groupBy(morningList, (v) => '${v.typeBody}').values.toList();
    var morningQualified =morningReport.isEmpty?0: morningReport
        .map((v) => v.where((v2) => v2.abnormalDescription == '检验合格').length)
        .reduce((a, b) => a + b);
    return [morningReport,morningList.length, morningQualified];
  }

  List getAfternoonReport() {
    var afternoonList = state.reportList
        .where((v) =>
            v.recordDate != null && DateTime.parse(v.recordDate!).hour >= 12)
        .toList();
    var afternoonReport =
        groupBy(afternoonList, (v) => '${v.typeBody}').values.toList();
    var afternoonQualified =afternoonReport.isEmpty?0: afternoonReport
        .map((v) => v.where((v2) => v2.abnormalDescription == '检验合格').length)
        .reduce((a, b) => a + b);
    return [afternoonReport,afternoonList.length, afternoonQualified];
  }
}
