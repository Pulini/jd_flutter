import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/material_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/personal_item_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/size_allocation_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_state.dart';

class TeamLeaderAssignsTaskLogic extends GetxController {
  final TeamLeaderAssignsTaskState state = TeamLeaderAssignsTaskState();

  // 点击右侧员工卡片，将工号填入左侧选中的尺码行
  void assignEmployeeToSelectedRow(String empNo) {
    int index = state.selectedRowIndex.value;
    if (index < 0 || index >= state.sizeAllocationList.length) {
      return; // 没有选中行，不做操作
    }
    var item = state.sizeAllocationList[index];
    item.assignedOperator.value = empNo;
    item.operatorController.text = empNo;
    item.isMatched.value = true;
    state.selectedRowIndex.value = -1; // 分配完成后取消选中
  }

  // 重置分配
  void resetAllocation() {
    for (var item in state.sizeAllocationList) {
      item.reset();
    }
    state.selectedRowIndex.value = -1;
  }

  // 保存拆分工单
  void saveSplitWorkOrder() {
    // TODO: 保存逻辑待实现
  }

  @override
  void onInit() {
    super.onInit();
    // 测试数据
    state.personalList.addAll([
      PersonalItemInfo(
        empNo: '757155',
        empName: 'LISTIANSARI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),
      PersonalItemInfo(
        empNo: '757156',
        empName: 'PUTRI',
        pictureUrl: '',
      ),

    ]);
    // 部件&物料明细测试数据
    state.materialDetailList.addAll([
      MaterialDetailInfo(
        materialCode: '011000123',
        totalMaterialUsage: '10.096 米(M)',
        specification:
            '1.3mm*1.35m 白色JF12839 (AL976/AL-KL976S) 纹太空革PU (可再生)',
      ),
      MaterialDetailInfo(
        materialCode: '011000456',
        totalMaterialUsage: '5.200 米(M)',
        specification: '1.5mm*1.2m 黑色JF12840 纹太空革PU',
      ),
      MaterialDetailInfo(
        materialCode: '011000789',
        totalMaterialUsage: '8.500 米(M)',
        specification: '2.0mm*1.0m 红色JF12841 纹太空革PU',
      ),
      MaterialDetailInfo(
        materialCode: '011000321',
        totalMaterialUsage: '12.300 米(M)',
        specification: '1.3mm*1.35m 蓝色JF12842 纹太空革PU',
      ),
    ]);
    // 尺码人员分配明细测试数据
    state.sizeAllocationList.addAll([
      SizeAllocationInfo(size: '3', totalQty: 126),
      SizeAllocationInfo(size: '3.5', totalQty: 227),
      SizeAllocationInfo(size: '4', totalQty: 328),
      SizeAllocationInfo(size: '4.5', totalQty: 379),
      SizeAllocationInfo(size: '5', totalQty: 429),
      SizeAllocationInfo(size: '5.5', totalQty: 379),
      SizeAllocationInfo(size: '6', totalQty: 328),
      SizeAllocationInfo(size: '6.5', totalQty: 202),
      SizeAllocationInfo(size: '7', totalQty: 126),
    ]);
  }
}
