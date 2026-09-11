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

  /// 单个员工卡片：已选中显示绿色背景，点击可切换选中状态
  Widget workerItem(WorkerInfo item) {
    // 以员工 ID 作为唯一标识判断是否已选中
    var isSelected = selected.map((v) => v.itemId).contains(item.empID);
    return Obx(() => GestureDetector(
          onTap: () {
            isSelected = selected.map((v) => v.itemId).contains(item.empID);
            if (isSelected) {
              selected.removeWhere((v) => v.itemId == item.empID);
            } else {
              selected.add(DispatchedItem(
                itemId: item.empID ?? -1,
                number: item.empCode ?? '',
                name: item.empName ?? '',
                avatarPath: item.picUrl ?? '',
                size: size,
              ));
            }
          },
          child: Card(
            color: selected.map((v) => v.itemId).contains(item.empID)
                ? Colors.green.shade100
                : Colors.white,
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
        ));
  }

  Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Text('group_dispatch_dialog_title'.tr),
          const Spacer(),
          SizedBox(width: 400, child: OptionsPicker(pickerController: opc))
        ],
      ),
      content: SizedBox(
        // 按屏幕比例设置，避免直接用全屏尺寸导致 AlertDialog 内容溢出
        width: getScreenSize().width * 0.8,
        height: getScreenSize().height * 0.7,
        child: Obx(() => GridView.builder(
              itemCount: workers.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8, // 网格的列数
                childAspectRatio: 3 / 4,
              ),
              itemBuilder: (c, i) => workerItem(workers[i]),
            )),
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
