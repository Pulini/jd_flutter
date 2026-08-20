import 'package:flutter/widgets.dart' show TextSelection, WidgetsBinding;
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_state.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/bean/http/response/label_for_work_card_info.dart';

class TeamLeaderAssignsTaskLogic extends GetxController {
  final TeamLeaderAssignsTaskState state = TeamLeaderAssignsTaskState();

  TeamLeaderAssignsTaskLogic() {
    state.logic = this;
  }

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
  void setOperatorNo(SizeList item, String empNo, {bool batch = true}) {
    var no = empNo.trim();
    item.operatorNo.value = no;
    var emp = findEmployee(no);
    if (emp != null) {
      // 命中右侧花名册：直接取内码与姓名
      item.isMatched.value = true;
      item.empID = emp.fItemID;
      item.operatorName.value = emp.fName ?? '';
      // 多选：把同一人批量赋给所有选中行（仅在已解析出有效人员后）
      if (batch) _assignToSelectedRows(no, emp.fItemID, emp.fName ?? '');
    } else {
      // 未命中：先清空，避免残留上一个人的内码/姓名
      item.isMatched.value = false;
      item.empID = null;
      item.operatorName.value = '';
      // 走接口按工号查人员，把内码附上（姓名用于「员工」列展示，不在花名册也能显示）
      if (no.isNotEmpty) {
        state.searchPeople(no).then((p) {
          if (p != null) {
            item.empID = p.empID;
            item.operatorName.value = p.empName ?? '';
            item.isMatched.value = true;
            // 接口查到人后，才把同一人批量赋给所有选中行
            // （不在输入时广播，避免把不完整/未匹配的工号提前刷到其它行）
            if (batch) _assignToSelectedRows(no, p.empID, p.empName ?? '');
          }
        });
      }
    }
  }

  // 把某个人（工号+内码+姓名）批量赋给所有选中行，并清除选中态。
  // 仅在「已解析出有效人员」后调用，避免把不完整/未匹配的工号广播到其它行。
  void _assignToSelectedRows(String no, int? empID, String name) {
    final sel = state.selectedRowIndexes;
    if (sel.isEmpty) return;
    for (var index in List<int>.from(sel)) {
      if (index < 0 || index >= state.sizeAllocationList.length) continue;
      final target = state.sizeAllocationList[index];
      target.operatorNo.value = no;
      target.empID = empID;
      target.operatorName.value = name;
      target.isMatched.value = empID != null;
      if (target.operatorController.text != no) {
        target.operatorController.text = no;
        target.operatorController.selection =
            TextSelection.collapsed(offset: no.length);
      }
    }
    sel.clear();
  }

  // 设工号并刷新输入框（输入框只显示工号；姓名由「员工」列单独展示）
  void applyOperator(SizeList item, String empNo) {
    setOperatorNo(item, empNo, batch: false); // 批量由调用方(assignEmployeeToSelectedRow)自己循环处理
    final no = item.operatorNo.value;
    if (item.operatorController.text != no) {
      item.operatorController.text = no;
      item.operatorController.selection =
          TextSelection.collapsed(offset: no.length);
    }
  }

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


  void resetAllocation() {
    final component = state.currentComponent.value;
    final source = state.sizeAllocationList;
    if (source.isEmpty) return;
    final oldControllers = source
        .expand((e) => [e.operatorController, e.qtyController])
        .toList();

    final baseMap = <String, SizeList>{};
    for (var item in source) {
      final key = _allocationKey(item.fMtono, item.size);
      baseMap.putIfAbsent(key, () => item);
    }

    final isAllocated =
        state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;


    final merged = <SizeList>[];
    baseMap.forEach((key, base) {
      merged.add(SizeList(
        size: base.size,
        fMtono: base.fMtono,
        fItemID: base.fItemID,
        fRouteEntryFID: base.fRouteEntryFID,
        fProcessName: base.fProcessName,
        totalQty: base.totalQty, // 取其中一行的值，不累加
        // empID 不继承：重置要清空已分配人员，否则工号框空了但内码还残留
        allocatedQty: base.allocatedQty, // 同样取其中一行的值，不累加
        fPrdMoID: base.fPrdMoID,
      ));
    });
    for (var item in merged) {
      item.isAllocated = isAllocated;
      item.fillQtyByTotal();
    }


    if (component != null) {
      component.sizeList = List<SizeList>.from(merged);
    }
    state.sizeAllocationList
      ..clear()
      ..addAll(merged);
    state.selectedRowIndexes.clear();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final c in oldControllers) {
        c.dispose();
      }
    });
  }

  String _allocationKey(String? fMtono, String? size) {
    return '${(fMtono ?? '').trim()}#${(size ?? '').trim()}';
  }


  int groupRowCount(SizeList row) {
    final key = _allocationKey(row.fMtono, row.size);
    return state.sizeAllocationList
        .where((e) => _allocationKey(e.fMtono, e.size) == key)
        .length;
  }


  int _groupCap(SizeList row, List<SizeList> all) {
    final key = _allocationKey(row.fMtono, row.size);

    final isAllocated =
        state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
    if (isAllocated) {
      return all
          .where((e) => _allocationKey(e.fMtono, e.size) == key)
          .fold(0, (s, e) => s + (e.allocatedQty ?? 0));
    }
    return row.totalQty?.toInt() ?? 0;
  }

  int groupRemainingQty(SizeList row, List<SizeList> all) {
    final key = _allocationKey(row.fMtono, row.size);
    final cap = _groupCap(row, all);
    var sum = 0;
    for (final e in all) {
      if (_allocationKey(e.fMtono, e.size) == key) {
        sum += int.tryParse(e.currentQty.value) ?? 0;
      }
    }
    final r = cap - sum;
    return r < 0 ? 0 : r;
  }

  int rowMaxQty(SizeList row, List<SizeList> all) {
    final key = _allocationKey(row.fMtono, row.size);
    final cap = _groupCap(row, all);
    var others = 0;
    for (final e in all) {
      if (e != row && _allocationKey(e.fMtono, e.size) == key) {
        others += int.tryParse(e.currentQty.value) ?? 0;
      }
    }
    final max = cap - others;
    return max < 0 ? 0 : max;
  }


  void copySizeAllocation(int index) {
    if (index < 0 || index >= state.sizeAllocationList.length) return;
    final data = state.sizeAllocationList[index];
    final all = state.sizeAllocationList;

    final groupRem = groupRemainingQty(data, all);
    if (groupRem <= 0) {
      errorDialog(content: 'team_leader_no_remaining_to_split'.tr);
      return;
    }
    final newQty = groupRem;

    final newRow = SizeList(
      size: data.size,
      fMtono: data.fMtono,
      fPrdMoID: data.fPrdMoID,
      totalQty: data.totalQty,
      allocatedQty: 0,
      fItemID: data.fItemID,
      fRouteEntryFID: data.fRouteEntryFID,
      fProcessName: data.fProcessName,

    );

    newRow.isAllocated = data.isAllocated;
    newRow.currentQty.value = newQty.toString();
    newRow.qtyController.text = newQty.toString();
    newRow.operatorNo.value = '';
    newRow.isMatched.value = false;
    newRow.operatorController.clear();
    state.currentComponent.value?.sizeList?.insert(index + 1, newRow);
    state.sizeAllocationList.insert(index + 1, newRow);
    final shifted =
        state.selectedRowIndexes.map((i) => i > index ? i + 1 : i).toList();
    state.selectedRowIndexes.value = shifted;
  }

  void deleteSizeAllocation(int index) {
    if (index < 0 || index >= state.sizeAllocationList.length) return;
    final data = state.sizeAllocationList[index];
    final key = _allocationKey(data.fMtono, data.size);
    int target = -1;
    for (var i = index - 1; i >= 0; i--) {
      if (_allocationKey(state.sizeAllocationList[i].fMtono,
              state.sizeAllocationList[i].size) ==
          key) {
        target = i;
        break;
      }
    }
    if (target == -1) {
      for (var i = index + 1; i < state.sizeAllocationList.length; i++) {
        if (_allocationKey(state.sizeAllocationList[i].fMtono,
                state.sizeAllocationList[i].size) ==
            key) {
          target = i;
          break;
        }
      }
    }
    if (target == -1) {
      errorDialog(content: 'team_leader_size_only_one_row'.tr);
      return;
    }

    if (data.isAllocated) {
      final sibling = state.sizeAllocationList[target];
      sibling.allocatedQty = (sibling.allocatedQty ?? 0) + (data.allocatedQty ?? 0);
    }
    state.currentComponent.value?.sizeList?.removeAt(index);
    state.sizeAllocationList.removeAt(index);
    final shifted = state.selectedRowIndexes
        .where((i) => i != index)
        .map((i) => i > index ? i - 1 : i)
        .toList();
    state.selectedRowIndexes.value = shifted;
  }

  //搜索工单
  void scanSearch(String order) {
    state.getProcessWorkCardInfo(order, success: () {
      _initAllComponents();
    });
  }

  // 已分配工单加载时，把 size 行里的已派员工解析到「工号/姓名」展示位。
  // 优先用 SizeList 自带的 empNumber/empName（后端随工单返回，无需命中花名册），
  // 否则退回 personalList 里按 empID 反查（原有逻辑，仅当员工在花名册时生效）。
  void resolveAllocatedEmployee(SizeList item) {
    if (item.empID == null) return;
    // 1) SizeList 自带工号/姓名（后端已分配即返回，不依赖花名册能否查到）
    if ((item.empNumber ?? '').isNotEmpty) {
      item.operatorNo.value = item.empNumber!;
      item.operatorName.value = item.empName ?? '';
      item.isMatched.value = true;
      item.operatorController.text = item.empNumber!;
      return;
    }
    // 2) 退回：在花名册 personalList 里按 empID 反查
    final empIdStr = item.empID.toString().trim();
    for (var e in state.personalList) {
      if (e.fItemID?.toString().trim() == empIdStr) {
        item.operatorNo.value = e.fNumber ?? '';
        item.isMatched.value = true;
        item.operatorController.text = e.fNumber ?? '';
        item.empID = e.fItemID;
        break;
      }
    }
  }

  void _initAllComponents() {
    final isAllocated =
        state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
    for (var comp in state.workCardInfo.componentList ?? []) {
      final list = comp.sizeList;
      if (list == null || list.isEmpty) continue;
      for (var item in list) {
        item.isAllocated = isAllocated;
        item.operatorNo.value = '';
        item.isMatched.value = false;
        item.operatorController.text = '';
        resolveAllocatedEmployee(item);
        item.fillQtyByTotal();
      }
      comp.allocationLoaded = true;
    }
  }


  void loadSizeAllocation(ComponentList component) {
    if (state.currentComponent.value != component) {
      final list = component.sizeList;
      if (list == null || list.isEmpty) {
        state.sizeAllocationList.clear();
      } else {

        if (!component.allocationLoaded) {

          final isAllocated =
              state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
          for (var item in list) {
            item.isAllocated = isAllocated;
            item.operatorNo.value = '';
            item.isMatched.value = false;
            item.operatorController.text = '';
            resolveAllocatedEmployee(item);
            item.fillQtyByTotal();
          }
          component.allocationLoaded = true;
        }
        state.sizeAllocationList.value = List<SizeList>.from(list);
      }
      state.selectedRowIndexes.clear();
      state.currentComponent.value = component;
    }
    // 无论点哪次，都确保底部面板展开（不收起）
    state.showSizeAllocation.value = true;
  }

  // 保存拆分工单
  void saveSplitWorkOrder() {
    var operatorErrors = <String>[];
    var qtyErrors = <String>[];
    for (var comp in state.workCardInfo.componentList ?? []) {
      final list = comp.sizeList;
      if (list == null || list.isEmpty) continue;
      final compLabel = (comp.componentName?.isNotEmpty == true)
          ? comp.componentName!
          : (comp.componentno ?? '');
      for (var item in list) {
        var no = item.operatorNo.value.trim();
        if (no.isEmpty) {
          operatorErrors.add('team_leader_size_operator_not_assigned'
              .trArgs([compLabel, item.size ?? '']));
        } else if (item.empID == null) {
          operatorErrors.add('team_leader_size_operator_not_matched'
              .trArgs([compLabel, item.size ?? '', no]));
        }
      }

      final groups = <String, List<SizeList>>{};
      for (var item in list) {
        final key = _allocationKey(item.fMtono, item.size);
        groups.putIfAbsent(key, () => []).add(item);
      }
      groups.forEach((key, items) {
        final isAllocated =
            state.workCardInfo.processWorkCardInfo?.allocationStatus == 1;
        final cap = isAllocated
            ? items.fold(0, (s, e) => s + (e.allocatedQty ?? 0))
            : (items.first.totalQty?.toInt() ?? 0);
        final sum =
            items.fold(0, (s, e) => s + (int.tryParse(e.currentQty.value) ?? 0));
        final remaining = cap - sum;
        if (remaining != 0) {
          qtyErrors.add('team_leader_size_qty_not_fully_allocated'
              .trArgs([compLabel, items.first.size ?? '', remaining.toString()]));
        }
        final seenEmp = <int?>{};
        for (var e in items) {
          final empId = e.empID;
          if (empId == null) continue;
          if (!seenEmp.add(empId)) {
            final name = e.operatorName.value.isEmpty
                ? e.operatorNo.value.trim()
                : e.operatorName.value;
            operatorErrors.add('team_leader_size_operator_duplicated'.trArgs(
                [compLabel, e.size ?? '', e.fMtono ?? '', name]));
            break;
          }
        }
      });
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
    for (var comp in state.workCardInfo.componentList ?? []) {
      for (var item in comp.sizeList ?? []) {
        final no = item.operatorNo.value.trim();
        if (no.isNotEmpty) {
          item.empID ??= findEmployee(no)?.fItemID;
        }
      }
    }
    state.saveProcessWorkCardInfo(success: (mes) {
      successDialog(
          content: mes,
          back: () {
            state.clearAll();
          });
    });
  }
}
