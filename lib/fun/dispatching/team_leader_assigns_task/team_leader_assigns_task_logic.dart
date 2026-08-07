import 'package:flutter/widgets.dart' show TextSelection;
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_state.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/bean/http/response/label_for_work_card_info.dart';

class TeamLeaderAssignsTaskLogic extends GetxController {
  final TeamLeaderAssignsTaskState state = TeamLeaderAssignsTaskState();

  // 按工号在右侧人员列表中查找员工，找不到返回 null
  EmployeeList? findEmployee(String empNo) {
    var no = empNo.trim();
    if (no.isEmpty) return null;
    for (var e in state.personalList) {
      if ((e.fNumber ?? '').trim() == no) return e;
    }
    return null;
  }

  // 设置某一行的操作工（唯一入口）：同时维护工号文本、匹配状态、以及接口要用的 EmpID。
  // 注意：EmpID 存的是员工内码 fItemID（int），不是工号 fNumber（String）——
  // 工号可能含字母，直接字符串转 int 只会得到 0，接口拿不到人。
  void setOperatorNo(SizeList item, String empNo) {
    var no = empNo.trim();
    var emp = findEmployee(no);
    item.operatorNo.value = no;
    item.isMatched.value = emp != null;
    item.empID = emp?.fItemID; // 未匹配到人员时置空，避免残留上一个人的内码
  }

  // 设工号并刷新输入框（输入框只显示工号；姓名由「员工」列单独展示）
  void applyOperator(SizeList item, String empNo) {
    setOperatorNo(item, empNo);
    final no = item.operatorNo.value;
    if (item.operatorController.text != no) {
      item.operatorController.text = no;
      item.operatorController.selection =
          TextSelection.collapsed(offset: no.length);
    }
  }

  // 手动输入：输入框只含工号，提取纯工号做匹配
  void checkOperatorInput(SizeList item, String raw) {
    setOperatorNo(item, raw.trim());
  }

  // 点击尺码行：在多选集合里切换该行的选中状态
  void toggleRowSelection(int index) {
    final sel = state.selectedRowIndexes;
    if (sel.contains(index)) {
      sel.remove(index);
    } else {
      sel.add(index);
    }
  }

  // 一键全选所有尺码行
  void selectAllRows() {
    state.selectedRowIndexes.value =
        List<int>.generate(state.sizeAllocationList.length, (i) => i);
  }

  // 一键取消所有选中行
  void clearRowSelection() {
    state.selectedRowIndexes.clear();
  }

  // 点击右侧员工卡片，将工号填入左侧所有选中的尺码行（多选时一次填全部）
  void assignEmployeeToSelectedRow(String empNo) {
    final indexes = state.selectedRowIndexes;
    if (indexes.isEmpty) return; // 没有选中行，不做操作
    for (var index in indexes) {
      if (index < 0 || index >= state.sizeAllocationList.length) continue;
      applyOperator(state.sizeAllocationList[index], empNo);
    }
    state.selectedRowIndexes.clear(); // 分配完成后取消选中
  }

  // 重置分配：把重复尺码整合为一条（同尺码行 totalQty 累加），并清掉所有分配操作工
  void resetAllocation() {
    // 释放旧行的控制器，避免内存泄漏
    for (var item in state.sizeAllocationList) {
      item.operatorController.dispose();
      item.qtyController.dispose();
    }
    // 先按尺码累计总数量与已分配数量，并保留每个尺码首个出现的接口字段
    final totalMap = <String?, double>{};
    final allocatedMap = <String?, int>{};
    final baseMap = <String?, SizeList>{};
    for (var item in state.sizeAllocationList) {
      final key = item.size;
      // 同尺码只取一次总数量：接口每个尺码行（含不同分配人员）都带该尺码的总量，
      // 累加会按人员数翻倍，故只取首个出现的 totalQty。
      totalMap.putIfAbsent(key, () => item.totalQty ?? 0);
      // 已分配量仍累加：合并拆分行或多人员行各自已分配量，保留历史已分配总量
      allocatedMap[key] = (allocatedMap[key] ?? 0) + (item.allocatedQty ?? 0);
      baseMap.putIfAbsent(key, () => item);
    }
    final isAllocated =
        state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
    // 重建：每个尺码一条，工号清空（构造函数初始化即空），本次分配默认=上限
    final merged = <SizeList>[];
    totalMap.forEach((key, total) {
      final base = baseMap[key]!;
      merged.add(SizeList(
        size: base.size,
        totalQty: total,
        // empID 不继承：重置要清空已分配人员，否则工号框空了但内码还残留
        allocatedQty: allocatedMap[key] ?? 0,
        fPrdMoID: base.fPrdMoID,
      ));
    });
    for (var item in merged) {
      item.isAllocated = isAllocated;
      // 重置后本次分配默认=上限（已分配→allocatedQty，未分配→totalQty）
      item.fillQtyByTotal();
    }
    state.sizeAllocationList
      ..clear()
      ..addAll(merged);
    state.selectedRowIndexes.clear();
  }

  // 复制/拆分尺码行：把原行「本次可分配上限(allocCap)」里未分配的部分结转到新行，
  // 该尺码本次可分配总量不变。注意必须以 allocCap 为基准，而不是 totalQty——
  // 已分配状态(isAllocated)下 totalQty 是全部尺码总数，不等于本次可分配上限。
  void copySizeAllocation(int index) {
    if (index < 0 || index >= state.sizeAllocationList.length) return;
    final data = state.sizeAllocationList[index];
    final cap = data.allocCap; // 本次可分配上限（已分配→allocatedQty，未分配→totalQty）
    final current = int.tryParse(data.currentQty.value) ?? 0;
    if (current <= 0) {
      errorDialog(content: 'team_leader_fill_qty_before_split'.tr);
      return;
    }
    final remaining = cap - current; // 原行剩余未分配
    if (remaining <= 0) {
      errorDialog(content: 'team_leader_no_remaining_to_split'.tr);
      return;
    }
    // 原行：承接本次已填分配量，剩余归 0。依据 isAllocated 口径更新上限基准字段，
    // 否则 allocCap 仍指向旧总量，剩余未分配会一直挂在第一条。
    if (data.isAllocated) {
      data.allocatedQty = current;
    } else {
      data.totalQty = current.toDouble();
    }
    data.fillQtyByTotal(); // currentQty 填满上限 → 第一行剩余 0
    // 新行：承接原行剩余未分配，沿用同尺码 isAllocated 口径，本次分配留空待填
    final newRow = SizeList(
      size: data.size,
      fPrdMoID: data.fPrdMoID,
      allocatedQty: data.isAllocated ? remaining : 0,
      totalQty: remaining.toDouble(),
    );
    newRow.isAllocated = data.isAllocated;
    newRow.fillQtyByTotal(); // 本次分配默认填满剩余量（= allocCap）
    state.sizeAllocationList.insert(index + 1, newRow);
    // 插入后，位于原 index 之后的选中行索引需整体 +1
    final shifted =
        state.selectedRowIndexes.map((i) => i > index ? i + 1 : i).toList();
    state.selectedRowIndexes.value = shifted;
  }

  // 删除尺码行：把被删行的数量归还给同尺码的相邻行，保证该尺码总数量不变
  void deleteSizeAllocation(int index) {
    if (index < 0 || index >= state.sizeAllocationList.length) return;
    final data = state.sizeAllocationList[index];
    // 找同尺码的归还目标：优先上一行，其次下一行
    int target = -1;
    for (var i = index - 1; i >= 0; i--) {
      if (state.sizeAllocationList[i].size == data.size) {
        target = i;
        break;
      }
    }
    if (target == -1) {
      for (var i = index + 1; i < state.sizeAllocationList.length; i++) {
        if (state.sizeAllocationList[i].size == data.size) {
          target = i;
          break;
        }
      }
    }
    if (target == -1) {
      errorDialog(content: 'team_leader_size_only_one_row'.tr);
      return;
    }
    // 归还整行总数量，该尺码合计不变；被删行已填的分配数一并作废
    final back = state.sizeAllocationList[target];
    back.totalQty = (back.totalQty ?? 0) + (data.totalQty ?? 0);
    // 本次分配保持不动，归还的数量自动体现为该行的剩余未分配（复制的逆操作）
    state.sizeAllocationList.removeAt(index);
    // 选中集合维护：移除被删行，位于其后的选中行索引整体 -1
    final shifted = state.selectedRowIndexes
        .where((i) => i != index)
        .map((i) => i > index ? i - 1 : i)
        .toList();
    state.selectedRowIndexes.value = shifted;
  }

  void scanSearch(String order) {
    state.getProcessWorkCardInfo(order);
  }

  // 保存拆分工单
  void saveSplitWorkOrder() {
    // 保存前校验：
    // 1) 每个尺码都必须分配人员（工号非空且能在右侧人员列表匹配到）
    // 2) 每个尺码的数量都必须全部分配完（剩余未分配 = 0）
    var operatorErrors = <String>[];
    var qtyErrors = <String>[];
    for (var item in state.sizeAllocationList) {
      var no = item.operatorNo.value.trim();
      if (no.isEmpty) {
        operatorErrors.add('team_leader_size_operator_not_assigned'.trArgs([item.size ?? '']));
      } else if (findEmployee(no) == null) {
        operatorErrors.add('team_leader_size_operator_not_matched'.trArgs([item.size ?? '', no]));
      }
      if (item.remainingQty > 0) {
        qtyErrors.add('team_leader_size_qty_not_fully_allocated'.trArgs([item.size ?? '', item.remainingQty.toString()]));
      }
    }
    var msg = '';
    if (operatorErrors.isNotEmpty) {
      msg += 'team_leader_operator_invalid_msg'.trArgs([operatorErrors.join('\n')]);
    }
    if (qtyErrors.isNotEmpty) {
      msg += 'team_leader_qty_not_allocated_msg'.trArgs([qtyErrors.join('\n')]);
    }
    if (msg.isNotEmpty) {
      errorDialog(content: msg);
      return;
    }
    // 兜底：提交前按工号统一回填 EmpID 内码；工号为空时不覆盖（保留接口原值，避免清掉已分配内码）
    for (var item in state.sizeAllocationList) {
      final no = item.operatorNo.value.trim();
      if (no.isNotEmpty) {
        item.empID = findEmployee(no)?.fItemID;
      }
    }
    state.saveProcessWorkCardInfo(success: (mes) {
      successDialog(
          content: mes,
          back: () {
            scanSearch(state.scanOrder);
          });
    });
  }
}
