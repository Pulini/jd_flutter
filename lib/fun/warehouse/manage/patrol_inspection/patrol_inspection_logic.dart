import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/patrol_inspection_info.dart';

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
    state.getPatrolInspectionInfo();
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
    } else {}
    // state.addAbnormalRecord(
    //   abnormalItem: abnormalItem,
    //   success: (NewAbnormalRecordInfo newAbnormal) {
    //     showScanTips(
    //       color:  Colors.red,
    //     );
    //     state.qiDetailAbnormalRecords.add(QualityInspectionAbnormalRecordInfo(
    //       abnormalRecordId: newAbnormal.abnormalRecordId,
    //       abnormalItemId: newAbnormal.abnormalItemId,
    //       abnormalStatus: newAbnormal.abnormalStatus,
    //       modifyDate: newAbnormal.creationTime,
    //     ));
    //   },
    //   error: (msg) => showSnackBar(message: msg),
    // );
  }

  changeLine(int index) {
    var oldIndex = state.inspectionList.indexWhere((v) => v.isSelected.value);
    if (index != oldIndex) {
      state.inspectionList[oldIndex].isSelected.value = false;
      state.inspectionList[index].isSelected.value = true;
      state.abnormalRecordList.value =
          state.inspectionList[index].abnormalRecords!;
      state.abnormalItemList.value = state.inspectionList[index].abnormalItems!;
    }
  }
}
