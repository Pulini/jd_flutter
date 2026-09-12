import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';

import 'package:jd_flutter/bean/http/response/group_dispatch_info.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/worker_check_widget.dart';

/// 本地缓存 key：最近一次选择的工作中心/部门 ID
const groupDispatchDepartmentId = 'GroupDispatchDepartmentID';

/// 添加员工弹窗
///
/// 展示某工作中心下的员工花名册（网格），点击卡片可勾选/取消；
/// 勾选结果直接写入 [selected]（与尺码的已派工列表是同一个 RxList，故页面会实时刷新）。
///
/// - [size]            当前派工的尺码（新增员工时需要带上）
/// - [departmentId]    默认选中的部门 ID
/// - [workerCenterList] 工作中心列表（用于顶部下拉筛选）
/// - [selected]        已选中的员工（传入即被直接修改）
/// - [callback]        关闭弹窗时回传最终选中的员工列表
void addWorkerDialog({
  required String size,
  required String departmentId,
  required List<PickerSapWorkCenterNew> workerCenterList,
  required RxList<DispatchedItem> selected,
  required Function(List<DispatchedItem>) callback,
}) {
  var workers = <WorkerInfo>[].obs;

  /// 顶部工作中心下拉：选中后拉取该部门下的员工，并记住本次选择
  var opc = OptionsPickerController(
    PickerType.ghost,
    buttonName: 'team_leader_select_org'.tr,
    dataList: () async => workerCenterList,
    initId: departmentId,
    onSelected: (i) {
      if (i.pickerId().isNotEmpty) {
        getWorkerInfo(
          department: (i as PickerSapWorkCenterNew).departmentID.toString(),
          workers: (list) {
            workers.value = list;
            spSave(groupDispatchDepartmentId, i.pickerId());
          },
          error: (msg) => errorDialog(content: msg),
        );
      }
    },
  );

  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Text('group_dispatch_dialog_title'.tr),
          const Spacer(),
          SizedBox(width: 400, child: OptionsPicker(pickerController: opc)),
        ],
      ),
      content: SizedBox(
        // 按屏幕比例设置，避免直接用全屏尺寸导致 AlertDialog 内容溢出
        width: getScreenSize().width * 0.8,
        height: getScreenSize().height * 0.7,
        child: Obx(() {
          final selectedIds = <int>{
            for (var k = 0; k < selected.length; k++) selected[k].itemId,
          };
          return GridView.builder(
            itemCount: workers.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // 网格的列数
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (c, i) {
              if (i == 0) {
                return newWorkerItem(
                  isSelected: (w) => selectedIds.contains(w.empID),
                  click: (w, isSelected) {
                    if (isSelected) {
                      selected.removeWhere((v) => v.itemId == w.empID);
                    } else {
                      selected.add(newWorker(w, size));
                    }
                  },
                  checked: (w, isSelected) {
                    if (!isSelected) {
                      selected.add(newWorker(w, size));
                    }
                  },
                );
              } else {
                final worker = workers[i - 1];
                return workerItem(
                  item: worker,
                  isSelected: selectedIds.contains(worker.empID),
                  click: (isSelected) {
                    if (isSelected) {
                      selected.removeWhere((v) => v.itemId == worker.empID);
                    } else {
                      selected.add(newWorker(worker, size));
                    }
                  },
                );
              }
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 关闭前回传最终选中的员工列表
            callback.call(selected.toList());
            Get.back();
          },
          child: Text(
            'dialog_default_back'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

/// 批量添加员工弹窗
///
/// 操作逻辑与 [addWorkerDialog] 一致（工作中心筛选 + 花名册网格 + 点击勾选），
/// 区别在于：**勾选的员工会作用到所有尺码**，而不是某一个尺码。
///
/// - [departmentId]     默认选中的部门 ID
/// - [workerCenterList] 工作中心列表（顶部下拉筛选）
/// - [isWorkerSelected] 判断该员工是否已在所有尺码中（决定是否显示选中态）
/// - [onToggle]         点击卡片时回调：(员工, 当前是否已选中)，由外部决定添加/移除
/// - [callback]         关闭弹窗时回传最终勾选的员工列表
void addWorkerBatchDialog({
  required String departmentId,
  required List<PickerSapWorkCenterNew> workerCenterList,
  required bool Function(int empId) isWorkerSelected,
  required void Function(WorkerInfo worker, bool selected) onToggle,
  // 关闭时回传最终勾选的员工（可选）
  Function(List<WorkerInfo>)? callback,
}) {
  var workers = <WorkerInfo>[].obs;

  /// 顶部工作中心下拉：选中后拉取该部门下的员工，并记住本次选择
  var opc = OptionsPickerController(
    PickerType.ghost,
    buttonName: 'team_leader_select_org'.tr,
    dataList: () async => workerCenterList,
    initId: departmentId,
    onSelected: (i) {
      if (i.pickerId().isNotEmpty) {
        getWorkerInfo(
          department: (i as PickerSapWorkCenterNew).departmentID.toString(),
          workers: (list) {
            workers.value = list;
            spSave(groupDispatchDepartmentId, i.pickerId());
          },
          error: (msg) => errorDialog(content: msg),
        );
      }
    },
  );

  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Text('group_dispatch_batch_add_worker'.tr),
          const Spacer(),
          SizedBox(width: 400, child: OptionsPicker(pickerController: opc)),
        ],
      ),
      content: SizedBox(
        width: getScreenSize().width * 0.8,
        height: getScreenSize().height * 0.7,
        child: Obx(() {
          // 通过 RxList 公开成员建立对 workers 的响应式依赖
          final list = <WorkerInfo>[
            for (var k = 0; k < workers.length; k++) workers[k],
          ];
          // 预计算“已分配到所有尺码”的员工 ID：
          // 必须在 Obx 回调体内同步调用 isWorkerSelected 以建立对
          // state.dispatchMap 的依赖（放在 itemBuilder 里是惰性执行，建不了依赖，
          // 会导致点击后卡片颜色不刷新）。
          final selectedIds = <int>{
            for (var w in list)
              if (isWorkerSelected(w.empID ?? -1)) w.empID ?? -1,
          };
          return GridView.builder(
            // +1：首格为工号检索新增卡片 [newWorkerItem]
            itemCount: list.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8, // 网格的列数
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (c, i) {
              if (i == 0) {
                return newWorkerItem(
                  isSelected: (w) => selectedIds.contains(w.empID ?? -1),
                  click: (w, selected) => onToggle.call(w, selected),
                  checked: (w, selected) {
                    // 检索到新员工且尚未分配时，直接加入所有尺码
                    if (!selected) onToggle.call(w, false);
                  },
                );
              } else {
                final worker = list[i - 1];
                return workerItem(
                  item: worker,
                  isSelected: selectedIds.contains(worker.empID ?? -1),
                  click: (selected) => onToggle.call(worker, selected),
                );
              }
            },
          );
        }),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // 关闭前回传仍处于“已分配到所有尺码”状态的员工
            callback?.call(
              workers
                  .where((w) => isWorkerSelected(w.empID ?? -1))
                  .toList(),
            );
            Get.back();
          },
          child: Text(
            'dialog_default_back'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    ),
  );
}

DispatchedItem newWorker(WorkerInfo worker, String size) => DispatchedItem(
      itemId: worker.empID ?? -1,
      number: worker.empCode ?? '',
      name: worker.empName ?? '',
      avatarPath: worker.picUrl ?? '',
      size: size,
    );

/// 单个员工卡片：已选中显示绿色背景，点击可切换选中状态
Widget workerItem({
  required WorkerInfo item,
  required bool isSelected,
  required Function(bool) click,
}) =>
    GestureDetector(
      onTap: () => click.call(isSelected),
      child: Card(
        color: isSelected ? Colors.green.shade100 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(child: avatarPhoto(item.picUrl)),
              Text(
                item.empCode ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                item.empName ?? '',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );

/// 新增员工卡片：含工号检索控件 [WorkerCheck]
///
/// [isSelected] 返回该员工当前是否已选中（由外层传入，随外层 Obx 重建而更新）
Widget newWorkerItem({
  required bool Function(WorkerInfo) isSelected,
  required Function(WorkerInfo, bool) click,
  required Function(WorkerInfo, bool) checked,
}) {
  var worker = Rxn<WorkerInfo>();
  return Obx(() => GestureDetector(
        onTap: () => worker.value != null
            ? click(worker.value!, isSelected.call(worker.value!))
            : null,
        child: Card(
          color: worker.value != null && isSelected.call(worker.value!)
              ? Colors.green.shade100
              : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                Expanded(child: avatarPhoto(worker.value?.picUrl)),
                const SizedBox(height: 10),
                WorkerCheck(
                  onChanged: (w) {
                    if (w != null) {
                      worker.value = w;
                      checked.call(w, isSelected.call(w));
                    }
                  },
                  workerNameColor: Colors.blue.shade800,
                ),
              ],
            ),
          ),
        ),
      ));
}
