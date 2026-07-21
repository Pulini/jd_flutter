import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/material_detail_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/personal_item_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/size_allocation_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_logic.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_state.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class TeamLeaderAssignsTaskPage extends StatefulWidget {
  const TeamLeaderAssignsTaskPage({super.key});

  @override
  State<TeamLeaderAssignsTaskPage> createState() =>
      _TeamLeaderAssignsTaskPageState();
}

class _TeamLeaderAssignsTaskPageState extends State<TeamLeaderAssignsTaskPage> {
  final TeamLeaderAssignsTaskLogic logic =
      Get.put(TeamLeaderAssignsTaskLogic());
  final TeamLeaderAssignsTaskState state =
      Get.find<TeamLeaderAssignsTaskLogic>().state;

  Widget _personalItem(PersonalItemInfo data) {
    return InkWell(
      onTap: () {
        logic.assignEmployeeToSelectedRow(data.empNo ?? '');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 头像区 - 占上半
          Expanded(
            flex: 1,
            child: Center(
              child: ClipOval(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: data.pictureUrl?.isNotEmpty == true
                      ? CachedNetworkImage(
                          imageUrl: data.pictureUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.grey,
                        ),
                ),
              ),
            ),
          ),
          // 工号+姓名区 - 占下半
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '工号：${data.empNo ?? ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4, right: 4),
                    child: Text(
                      data.empName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _materialDetailItem(MaterialDetailInfo data) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '物料编码：${data.materialCode ?? ''}',
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '总用料：${data.totalMaterialUsage ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '规格：${data.specification ?? ''}',
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sizeAllocationRow(SizeAllocationInfo data, int index) {
    return InkWell(
      onTap: () {
        state.selectedRowIndex.value = index;
      },
      child: Obx(() => Container(
        decoration: BoxDecoration(
          color: state.selectedRowIndex.value == index
              ? Colors.blue.shade50
              : (index % 2 == 0 ? Colors.white : Colors.grey.shade50),
          border: state.selectedRowIndex.value == index
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                data.size ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                '${data.totalQty ?? 0}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ),
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 24,
                        child: TextField(
                          controller: data.operatorController,
                          onChanged: (v) {
                            data.assignedOperator.value = v;
                            data.isMatched.value = v.isNotEmpty;
                          },
                          style: const TextStyle(fontSize: 12),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            hintText: '输入工号',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => Text(
                      data.isMatched.value ? '已匹配员工' : '未匹配员工',
                      style: TextStyle(
                        fontSize: 12,
                        color: data.isMatched.value ? Colors.green : Colors.red,
                      ),
                    )),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: SizedBox(
                  height: 24,
                  child: TextField(
                    controller: data.qtyController,
                    onChanged: (v) {
                      data.currentQty.value = v;
                    },
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 4),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Obx(() => Text(
                '${data.remainingQty}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              )),
            ),
          ],
        ),
      )),
    );
  }

  Widget _sizeAllocationHeader() {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              '冲刀尺码',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '总数量',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '分配操作工(输入工号/拖拽右侧卡片)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '本次分配数量',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '剩余未分配',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sizeAllocationFooter() {
    return Container(
      color: Colors.grey.shade100,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Obx(() {
        int totalSum = 0;
        int assignedSum = 0;
        for (var item in state.sizeAllocationList) {
          totalSum += item.totalQty ?? 0;
          assignedSum += int.tryParse(item.currentQty.value) ?? 0;
        }
        int unassignedSum = totalSum - assignedSum;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 3,
              child: textSpan(hint: '合计总数：', text: totalSum.toString()),
            ),
            Expanded(
              flex: 3,
              child: textSpan(hint: '已分配总和：', text: assignedSum.toString())
            ),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: textSpan(hint: '未分配总和：', text: unassignedSum.toString()),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
        actions: [
          Container(
            height: 40,
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.only(left: 5, right: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.qr_code_scanner_outlined,
                  size: 20,
                  color: Colors.grey,
                ),
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  onPressed: () {
                    Get.to(() => const Scanner())?.then((v) {
                      if (v != null) {}
                    });
                  },
                  child: const Text(
                    '扫码读取工单',
                    style: TextStyle(color: Colors.blue),
                  ),
                )
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            Expanded(
              child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                            spreadRadius: 1.5,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                  width: 6, // 占用宽度
                                  thickness: 6, // 线条粗细
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text("工单基础信息",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Expanded(
                                child: textSpan(
                                    hint: '工厂名称：',
                                    text: 'PT.Gold Emperor Indonesia',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '工单类型：',
                                    text: '工序派工单(全码总单)',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '单据日期：',
                                    text: '2026-06-27',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '总订单数量：', text: '2524 双(PAA)',textColor: Colors.red),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: textSpan(
                                    hint: '产品编号：',
                                    text: 'PDS25400367-02',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '制程路线：',
                                    text: '裁1->印刷->贴补强',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '部件名称：',
                                    text: '00010后上片',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '单据Rd号：',
                                    text: 'PC260000011/1',
                                    isBold: false),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: textSpan(
                                    hint: '产线组别：',
                                    text: 'IDN.Workshop 2 Cutting Line 1',
                                    isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '组长：', text: 'PUTRI', isBold: false),
                              ),
                              Expanded(
                                child: textSpan(
                                    hint: '操作工：',
                                    text: 'LISTIANSARI(757155)',
                                    isBold: false),
                              ),
                              const Expanded(
                                child: SizedBox(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(left: 8, right: 8,bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                            spreadRadius: 1.5,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                  width: 6,
                                  thickness: 6,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: 5),
                              Text("部件&物料明细",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Obx(() => GridView.builder(
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 8,
                                    crossAxisSpacing: 8,
                                    childAspectRatio: 4.8,
                                  ),
                                  itemCount: state.materialDetailList.length,
                                  itemBuilder: (context, index) =>
                                      _materialDetailItem(
                                          state.materialDetailList[index]),
                                )),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, right: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 6,
                                offset: Offset(2, 2),
                                spreadRadius: 1.5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 固定标题行
                              const Row(
                                children: [
                                  SizedBox(
                                    height: 20,
                                    child: VerticalDivider(
                                      width: 6,
                                      thickness: 6,
                                      color: Colors.red,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Text("尺码人员分配明细",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black)),
                                  SizedBox(width: 12),
                                  Text(
                                    '*全部尺码必须分配完成才可保存',
                                    style: TextStyle(fontSize: 12, color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // 固定表头
                              _sizeAllocationHeader(),
                              // 可滚动的内容区
                              Expanded(
                                child: ListView.builder(
                                  itemCount: state.sizeAllocationList.length,
                                  itemBuilder: (context, index) =>
                                      _sizeAllocationRow(
                                          state.sizeAllocationList[index], index),
                                ),
                              ),
                              // 固定底栏
                              _sizeAllocationFooter(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(2, 2),
                      spreadRadius: 1.5,
                    )
                  ],
                ),
                child: Obx(() => GridView.builder(
                      padding: const EdgeInsets.all(8),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: state.personalList.length,
                      itemBuilder: (context, index) =>
                          _personalItem(state.personalList[index]),
                    )),
              ),
            )
          ],
        ),
      ),
            // 底部按钮行
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.left,
                      text: '重置分配',
                      backgroundColor: Colors.orangeAccent,
                      click: () => logic.resetAllocation(),
                    ),
                  ),
                  Expanded(
                    child: CombinationButton(
                      combination: Combination.right,
                      text: '保存拆分工单',
                      click: () => logic.saveSplitWorkOrder(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}