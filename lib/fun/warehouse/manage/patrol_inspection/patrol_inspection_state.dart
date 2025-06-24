import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PatrolInspectionState {
  var inspectionList = <PatrolInspectionInfo>[].obs;
  var abnormalItemList = <PatrolInspectionAbnormalItemInfo>[].obs;
  var abnormalRecordList = <PatrolInspectionAbnormalRecordInfo>[].obs;
  var typeBodyList = <PatrolInspectionTypeBodyInfo>[].obs;
  var typeBodyIndex = 0.obs;
  var errorMsg = ''.obs;
  var reportUnit = '';
  var reportQuantity = 0.0;
  var reportList = <PatrolInspectionAbnormalRecordDetailInfo>[].obs;

  PatrolInspectionState() {
    ever(inspectionList, (v) {
      abnormalItemList.value = v
          .firstWhere(
            (v) => v.isSelected.value,
            orElse: () => inspectionList.first,
          )
          .abnormalItems!;
    });
  }

  getPatrolInspectionInfo({
    required Function(int) success,
  }) {
    sapPost(
      loading: 'product_patrol_inspection_getting_line_info'.tr,
      method: webApiSapGetPatrolInspectionInfo,
      body: {'patrolInspectorNumber': userInfo?.number},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        inspectionList.value = [
          for (var json in response.data) PatrolInspectionInfo.fromJson(json)
        ];
        errorMsg.value = '';
        success.call(inspectionList.indexWhere((v) => v.isSelected.value));
      } else {
        inspectionList.value = [];
        errorMsg.value = response.message ?? 'query_default_error'.tr;
      }
    });
  }

  addPatrolInspectionRecord(
      {required String abnormalItemId,
      required Function(PatrolInspectionAbnormalRecordInfo) success,
      required Function(String) error}) {
    sapPost(
      loading: 'product_patrol_inspection_adding_patrol_records'.tr,
      method: webApiSapAddPatrolInspectionRecord,
      body: {
        'patrolInspectorNumber': userInfo?.number,
        'patrolInspectorName': userInfo?.name,
        'produceUnitId':
            inspectionList.firstWhere((v) => v.isSelected.value).produceUnitId,
        'abnormalItemId': abnormalItemId,
        'typeBody': typeBodyList.isEmpty
            ? ''
            : typeBodyList[typeBodyIndex.value].typeBody ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success
            .call(PatrolInspectionAbnormalRecordInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  deleteAbnormalRecord({
    required PatrolInspectionAbnormalRecordInfo abnormalRecord,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_patrol_inspection_withdrawing_abnormal'.tr,
      method: webApiSapDeletePatrolInspectionRecord,
      body: {
        'abnormalRecordId': abnormalRecord.abnormalRecordId,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getPatrolInspectionReport({
    required String patrolInspectDate,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_patrol_inspection_getting_patrol_report'.tr,
      method: webApiSapGetPatrolInspectionReport,
      body: {
        'patrolInspectorNumber': userInfo?.number,
        'patrolInspectDate': patrolInspectDate,
        'produceUnitId':
            inspectionList.firstWhere((v) => v.isSelected.value).produceUnitId
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var report = PatrolInspectionReportInfo.fromJson(response.data);
        reportList.value = report.abnormalRecordDetail!;
        reportUnit = report.produceUnitName ?? '';
        reportQuantity = report.patrolInspectQuantity ?? 0;
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
