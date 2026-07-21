import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/material_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/personal_item_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/size_allocation_info.dart';

class TeamLeaderAssignsTaskState {
  var personalList = <PersonalItemInfo>[].obs;
  var materialDetailList = <MaterialDetailInfo>[].obs;
  var sizeAllocationList = <SizeAllocationInfo>[].obs;
  var selectedRowIndex = (-1).obs; // 当前选中的尺码行索引，-1表示未选中
}
