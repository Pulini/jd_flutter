import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/group_dispatch_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/view_photo.dart';

import 'group_dispatch_dialog.dart';
import 'group_dispatch_logic.dart';
import 'group_dispatch_state.dart';

class GroupDispatchPage extends StatefulWidget {
  const GroupDispatchPage({super.key});

  @override
  State<GroupDispatchPage> createState() => _GroupDispatchPageState();
}

class _GroupDispatchPageState extends State<GroupDispatchPage> {
  final GroupDispatchLogic logic = Get.put(GroupDispatchLogic());

  /// 页面状态（直接取 logic 持有的实例，无需再次 Get.find）
  late final GroupDispatchState state = logic.state;

  /// 派工单号前缀（单号均以该前缀开头，输入框保持该前缀不可被删除）
  static const dispatchNoPrefix = 'GXPG';

  /// 派工单号输入/扫码框控制器，默认带前缀 [dispatchNoPrefix]
  var dispatchNoController = TextEditingController(text: dispatchNoPrefix);

  /// 卡片统一阴影
  var boxShadow = const [
    BoxShadow(
      color: Colors.black26,
      blurRadius: 6,
      offset: Offset(2, 2),
      spreadRadius: 1.5,
    )
  ];

  /// 区块小标题：红色竖线 + 标题文字
  ///
  /// 用 [IntrinsicHeight] 让竖线高度与标题文字实际高度保持一致。
  Widget boxTitle(String title) => IntrinsicHeight(
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Row(
            children: [
              const VerticalDivider(
                width: 5,
                thickness: 5,
                color: Colors.red,
                indent: 2,
              ),
              const SizedBox(width: 5),
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );

  /// 单个部件卡片：左侧部件图，右侧部件名 + 工序流程，下方列出物料清单
  Widget partItem(ComponentItem data) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.to(
                      () => ViewNetPhoto(photos: [data.pictureUrl]),
                    ),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blueAccent, width: 2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: AspectRatio(
                        aspectRatio: 3 / 2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: cachedNetworkImage(
                            data.pictureUrl,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.componentName,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text('team_leader_process_flow'.tr),
                            Expanded(child: data.getProcessText()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 10),
            for (var item in data.materialList)
              Text(
                item.materialText,
                style: const TextStyle(color: Colors.grey),
              )
          ],
        ),
      );

  /// 左侧部件明细区：标题 + 部件列表
  Widget parts() {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 10, bottom: 10, right: 5),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: Column(
        children: [
          boxTitle('team_leader_part_material_detail'.tr),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.only(top: 10),
                  itemCount: state.partList.length,
                  itemBuilder: (c, i) => partItem(state.partList[i]),
                )),
          ),
        ],
      ),
    );
  }

  /// 已派工员工卡片：头像 + 右上角删除按钮 + 底部工号
  Widget workerItem(DispatchedItem data, Function() delete) => Container(
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 5,
                top: 5,
                right: 5,
                bottom: 20,
              ),
              child: avatarPhoto(data.avatarPath),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: () => delete.call(),
                icon: const Icon(Icons.cancel, color: Colors.red),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 1,
              right: 1,
              child: Text(data.number, textAlign: TextAlign.center),
            )
          ],
        ),
      );

  /// 单个尺码派工卡片（支持多选）
  ///
  /// 点击卡片切换选中状态，选中记录保存在
  /// [GroupDispatchState.selectedSizes]；选中时卡片显示浅蓝背景 + 蓝色边框，
  /// 尺码前显示勾选图标。卡片内的“添加员工”与“删除员工”按钮会优先响应，
  /// 不会触发选中切换。
  Widget dispatchItem(SizeInfo data) {
    return Obx(() {
      final selected = state.isSizeSelected(data.size);
      return GestureDetector(
        onTap: () => state.toggleSizeSelected(data.size),
        child: Container(
          height: 160,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: selected ? Colors.blue.shade50 : Colors.white,
            // 未选中时用透明边框占位，避免选中/未选中切换时尺寸跳动
            border: Border.all(
              color: selected ? Colors.blueAccent : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Column(
                  children: [
                    Text('${data.size}#',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        )),
                    Text(
                      data.totalQty.toShowString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.blue.shade100,
                          boxShadow: boxShadow),
                      child: IconButton(
                        onPressed: () => logic.getWorkCenter(
                          (wc) => addWorkerDialog(
                            size: data.size,
                            departmentId: state.departmentId,
                            workerCenterList: wc,
                            selected: state.dispatchListOf(data.size),
                            callback: (workers) =>
                                state.dispatchListOf(data.size).value = workers,
                          ),
                        ),
                        icon: const Icon(
                          Icons.manage_accounts_outlined,
                          color: Colors.blueAccent,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade200,
                  ),
                  child: Obx(() {
                    // 该尺码下已分配的员工（不存在时自动创建）
                    var workers = state.dispatchListOf(data.size);
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: workers.length,
                      itemBuilder: (c, i) => workerItem(
                        workers[i],
                        // 按对象移除而非按索引，避免列表变动时删错人
                        () => workers.remove(workers[i]),
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  /// 右侧尺码派工列表区：标题 + 尺码卡片列表
  Widget dispatchList() => Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(left: 5, right: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            boxShadow: boxShadow,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  boxTitle('team_leader_size_worker_assign_detail'.tr),
                  const Spacer(),
                  CombinationButton(
                        combination: Combination.left,
                        text: 'group_dispatch_select_all'.tr,
                        click: () =>state.toggleSizeSelectAll(),
                      ),
                  Obx(() => CombinationButton(
                        combination: Combination.right,
                        // 批量添加作用于所有尺码，故只要有尺码数据即可用
                        isEnabled: state.sizeList.isNotEmpty,
                        text: 'group_dispatch_batch_setting'.tr,
                        click: () => _batchAddWorker(),
                      ))
                ],
              ),
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: state.sizeList.length,
                      padding: const EdgeInsets.only(top: 10),
                      itemBuilder: (c, i) => dispatchItem(state.sizeList[i]),
                    )),
              )
            ],
          ),
        ),
      );

  /// 打开“批量添加员工”弹窗
  ///
  /// 与单个尺码的 [addWorkerDialog] 操作逻辑一致，区别在于：
  /// 这里勾选的员工会作用到**所有尺码**（每个尺码各添加一条记录）；
  /// 已存在于所有尺码的员工再次点击，则从所有尺码中移除。
  void _batchAddWorker() {
    if (state.sizeList.isEmpty) {
      msgDialog(content: 'group_dispatch_no_data_submit'.tr);
      return;
    }
    logic.getWorkCenter(
      (wc) => addWorkerBatchDialog(
        departmentId: state.departmentId,
        workerCenterList: wc,
        isWorkerSelected: state.isWorkerInAllSizes,
        onToggle: (worker, selected) {
          if (selected) {
            state.removeWorkerFromAllSizes(worker.empID ?? -1);
          } else {
            state.addWorkerToAllSizes(
              itemId: worker.empID ?? -1,
              number: worker.empCode ?? '',
              name: worker.empName ?? '',
              avatarPath: worker.picUrl ?? '',
            );
          }
        },
      ),
    );
  }

  /// 右侧派工区整体：工单信息 + 尺码派工列表 + 底部（重置/派工）操作按钮
  Widget personnelAllocation() {
    return Column(
      children: [
        title(),
        dispatchList(),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: CombinationButton(
                  backgroundColor: Colors.orange,
                  combination: Combination.left,
                  text: 'team_leader_reset_assign'.tr,
                  click: () => askDialog(
                    title: 'team_leader_confirm_reset_assign'.tr,
                    content: 'team_leader_reset_tip'.tr,
                    confirm: () => logic.resetAssign(),
                  ),
                ),
              ),
              Expanded(
                child: CombinationButton(
                  backgroundColor: Colors.green,
                  combination: Combination.right,
                  text: 'team_leader_dispatch_work'.tr,
                  click: () {
                    // 先校验是否存在未分配人员的尺码，通过后再确认提交
                    if (logic.checkSubmitData()) {
                      askDialog(
                        content: 'team_leader_sure_dispatch'.tr,
                        confirm: () => logic.submitDispatch(
                          // 派工成功后重置为默认前缀，便于录入下一单
                          () => dispatchNoController.text = dispatchNoPrefix,
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 顶部工单基本信息区：厂别/线别/日期、产品/工序/包装、指令/单号/批号
  Widget title() => Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(left: 5, bottom: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        boxShadow: boxShadow,
      ),
      child: Column(
        children: [
          boxTitle('team_leader_work_order_base_info'.tr),
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Obx(() => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_factory_name'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.factoryName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_production_line_group'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.departName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_doc_date'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.date ?? '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_product_no'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.productNumber ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_process'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.processName ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_pack_info'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.packag ?? '',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_instruction'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.mtono ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_order_number'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.cardNo ?? '',
                          ),
                        ),
                        Expanded(
                          child: textSpan(
                            hint: 'team_leader_doc_rd_no'.tr,
                            hintColor: Colors.black54,
                            text: state.titleInfo.value?.batchNo ?? '',
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ));

  /// 顶部搜索区：派工单号输入框 + 查询按钮 + 扫码按钮
  Widget search() => Container(
        margin: const EdgeInsets.all(5),
        width: 400,
        height: 40,
        child: TextField(
          controller: dispatchNoController,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(
              top: 0,
              bottom: 0,
              left: 10,
              right: 10,
            ),
            filled: true,
            fillColor: Colors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            labelText: 'team_leader_input_work_order_no'.tr,
            labelStyle: const TextStyle(
                color: Colors.black54, fontWeight: FontWeight.w500),
            prefixIcon: IconButton(
              // 重置为默认前缀
              onPressed: () {
                dispatchNoController.text = dispatchNoPrefix;
                // 光标移到末尾，便于继续输入后半段单号
                dispatchNoController.selection = TextSelection.fromPosition(
                  TextPosition(offset: dispatchNoController.text.length),
                );
              },
              icon: const Icon(Icons.replay_circle_filled, color: Colors.grey),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CombinationButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  combination: Combination.left,
                  text: 'team_leader_search'.tr,
                  click: () => logic.queryOrder(dispatchNoController.text),
                ),
                CombinationButton(
                  icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                  combination: Combination.right,
                  text: 'team_leader_scan_work_order'.tr,
                  click: () => scannerDialog(
                    detect: (code) => logic.queryOrder(code),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  /// 页面主体：左侧部件明细（占比 4）+ 右侧派工区（占比 6）
  @override
  Widget build(BuildContext context) {
    return pageBody(
      popTitle: 'group_dispatch_exit_confirm'.tr,
      actions: [search()],
      body: Row(
        children: [
          Expanded(flex: 4, child: parts()),
          Expanded(flex: 6, child: personnelAllocation()),
        ],
      ),
    );
  }

  /// 退出页面时销毁 logic，避免下次进入残留上一次数据
  @override
  void dispose() {
    Get.delete<GroupDispatchLogic>();
    super.dispose();
  }
}
