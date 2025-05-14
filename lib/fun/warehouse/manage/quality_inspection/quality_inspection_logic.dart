import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_detail_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/quality_inspection/quality_inspection_report_view.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'quality_inspection_state.dart';

class QualityInspectionLogic extends GetxController {
  final QualityInspectionState state = QualityInspectionState();

  queryOrders({
    required String startDate,
    required String endDate,
  }) {
    state.queryOrders(
      startDate: startDate,
      endDate: endDate,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getOrderDetail({required String workOrderNo, required Function() refresh}) {
    state.getOrderDetail(
      workOrderNo: workOrderNo,
      success: () => Get.to(
        () => const QualityInspectionDetailPage(),
      )?.then((_) => refresh.call()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  addAbnormalRecord({
    required QualityInspectionAbnormalItemInfo abnormalItem,
    required AbnormalDegree degree,
  }) {
    state.addAbnormalRecord(
      abnormalItem: abnormalItem,
      degree: degree.value,
      success: (NewAbnormalRecordInfo newAbnormal) {
        showScanTips(
          color: degree == AbnormalDegree.slight ? Colors.orange : Colors.red,
        );
        state.qiDetailAbnormalRecords.add(QualityInspectionAbnormalRecordInfo(
          abnormalRecordId: newAbnormal.abnormalRecordId,
          abnormalItemId: newAbnormal.abnormalItemId,
          abnormalSeverity: degree.value,
          abnormalStatus: newAbnormal.abnormalStatus,
          modifyDate: newAbnormal.creationTime,
        ));
      },
      error: (msg) => showSnackBar(message: msg),
    );
  }

  modifyAbnormalRecordStatus({
    required QualityInspectionAbnormalRecordInfo abnormalRecord,
    required int status,
  }) {
    state.modifyAbnormalRecordStatus(
      abnormalRecord: abnormalRecord,
      status: status,
      success: (msg) {
        var data = state.qiDetailAbnormalRecords.firstWhere(
            (v) => v.abnormalRecordId == abnormalRecord.abnormalRecordId);
        data.abnormalStatus = status;
        data.isSelect.value = false;
        state.qiDetailAbnormalRecords.refresh();
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteAbnormalRecord({
    required QualityInspectionAbnormalRecordInfo abnormalRecord,
  }) {
    state.deleteAbnormalRecord(
      abnormalRecord: abnormalRecord,
      success: (msg) {
        state.qiDetailAbnormalRecords.removeWhere(
            (v) => v.abnormalRecordId == abnormalRecord.abnormalRecordId);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool hasInspectionAbnormalRecords() =>
      state.qiDetailAbnormalRecords.isNotEmpty;

  bool allRecordsRechecked() =>
      hasInspectionAbnormalRecords() &&
      state.qiDetailAbnormalRecords
          .every((v) => v.abnormalStatus == 2 || v.abnormalStatus == 3);

  inspectionCompleted() {
    state.submitInspectionCompleted(
      success: (msg) => successDialog(
        content: msg,
        back: () => Get.back(result: true),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getInspectionReport({
    required String startDate,
    required String endDate,
  }) {
    state.queryInspectionReport(
      startDate: startDate,
      endDate: endDate,
      success: () =>Get.to(()=>const QualityInspectionReportPage()),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
