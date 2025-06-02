import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PatrolInspectionState {
  var inspectionList = <PatrolInspectionInfo>[].obs;
  var abnormalItemList = <PatrolInspectionAbnormalItemInfo>[].obs;
  var abnormalRecordList = <PatrolInspectionAbnormalRecordInfo>[].obs;
  var errorMsg = ''.obs;

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

  getPatrolInspectionInfo() {
    sapPost(
      loading: '正在获取产线信息...',
      method: webApiSapGetPatrolInspectionInfo,
      body: {'patrolInspectorNumber': userInfo?.number},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        inspectionList.value = [
          for (var json in response.data) PatrolInspectionInfo.fromJson(json)
        ];
        errorMsg.value = '';
      } else {
        inspectionList.value = [];
        abnormalItemList.value = [];
        errorMsg.value = response.message ?? 'query_default_error'.tr;
      }
    });
  }

  addPatrolInspectionRecord({
    required String produceUnitId,
    required String abnormalItemId,
    required Function() success,
    required Function(String) error
  }) {
    sapPost(
      loading: '正在添加巡查记录...',
      method: webApiSapAddPatrolInspectionRecord,
      body: {
        'patrolInspectorNumber': userInfo?.number,
        'patrolInspectorName': userInfo?.name,
        'produceUnitId': produceUnitId,
        'abnormalItemId': abnormalItemId,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
