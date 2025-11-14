import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/quality_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class QualityInspectionState {
  var orderList = <QualityInspectionInfo>[].obs;
  var qiDetailWorkOrderNo = ''.obs;
  var qiDetailInstructionNo = ''.obs;
  var qiDetailTypeBody = ''.obs;
  var qiDetailCustomerPo = ''.obs;
  var qiDetailInspectionUnit = ''.obs;
  var qiDetailTotalQuantity = (0.0).obs;
  var qiDetailAbnormalRecords = <QualityInspectionAbnormalRecordInfo>[].obs;
  var qiDetailAbnormalItems = <QualityInspectionAbnormalItemInfo>[].obs;

  var report = <QualityInspectionReportInfo>[].obs;

  QualityInspectionState() {
    ///Initialize variables
  }

  void queryOrders({
    required String instructionNo,
    required String typeBody,
    required String customerPO,
    required String startDate,
    required String endDate,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_getting_line_info'.tr,
      method: webApiSapGetQualityInspectionOrders,
      body: {
        'instructionNo': instructionNo,
        'typeBody': typeBody,
        'customerPO': customerPO,
        'inspectorNo': userInfo?.number,
        'startDate': startDate,
        'endDate': endDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderList.value = [
          for (var json in response.data) QualityInspectionInfo.fromJson(json)
        ];
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getOrderDetail({
    required String workOrderNo,
    required Function() success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_getting_work_order_detail'.tr,
      method: webApiSapGetQualityInspectionOrderDetail,
      body: [
        {'workOrderNo': workOrderNo}
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = QualityInspectionDetailInfo.fromJson(response.data[0]);
        qiDetailWorkOrderNo.value = data.workOrderNo ?? '';
        qiDetailInstructionNo.value = data.instructionNo ?? '';
        qiDetailTypeBody.value = data.typeBody ?? '';
        qiDetailCustomerPo.value = data.customerPo ?? '';
        qiDetailInspectionUnit.value = data.inspectionUnit ?? '';
        qiDetailTotalQuantity.value = data.totalQuantity ?? 0.0;
        qiDetailAbnormalRecords.value = data.abnormalRecords ?? [];
        qiDetailAbnormalItems.value = data.abnormalItems!;
        success.call();
      } else {
        qiDetailWorkOrderNo.value = '';
        qiDetailInstructionNo.value = '';
        qiDetailTypeBody.value = '';
        qiDetailCustomerPo.value = '';
        qiDetailInspectionUnit.value = '';
        qiDetailTotalQuantity.value = 0.0;
        qiDetailAbnormalRecords.value = [];
        qiDetailAbnormalItems.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void addAbnormalRecord({
    required QualityInspectionAbnormalItemInfo abnormalItem,
    required Function(NewAbnormalRecordInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_submitting_abnormal'.tr,
      method: webApiSapAddAbnormalRecord,
      body: {
        'abnormalItemId': abnormalItem.abnormalItemId,
        'creatorNumber': userInfo?.number,
        'creatorName': userInfo?.name,
        'workOrderNo': qiDetailWorkOrderNo.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(NewAbnormalRecordInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void modifyAbnormalRecordStatus({
    required QualityInspectionAbnormalRecordInfo abnormalRecord,
    required int status,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_submitting_reinspection'.tr,
      method: webApiSapModifyAbnormalRecord,
      body: {
        'abnormalRecordId': abnormalRecord.abnormalRecordId,
        'updaterNo': userInfo?.number,
        'updaterName': userInfo?.name,
        'abnormalStatus': status
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void deleteAbnormalRecord({
    required QualityInspectionAbnormalRecordInfo abnormalRecord,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_withdrawing_abnormal'.tr,
      method: webApiSapDeleteAbnormalRecord,
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

  void submitInspectionCompleted({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_submitting_inspection_complete'.tr,
      method: webApiSapInspectionCompleted,
      body: {
        'workOrderNo': qiDetailWorkOrderNo.value,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void queryInspectionReport({
    required String startDate,
    required String endDate,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'product_quality_inspection_getting_inspection_report'.tr,
      method: webApiSapGetInspectionReport,
      body: {
        'inspectorNumber': userInfo?.number,
        'startDate': startDate,
        'endDate': endDate,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<QualityInspectionReportInfo>,
          ParseJsonParams(response.data, QualityInspectionReportInfo.fromJson),
        ).then((list) {
          report.value = list;
          success.call();
        });
      } else {
        report.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }


}
