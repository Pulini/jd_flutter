import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_label_list/part_dispatch_label_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_order_list/part_dispatch_order_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch/part_dispatch_order_list/part_dispatch_order_list_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';

class PartDispatchOrderCreateLabelPage extends StatefulWidget {
  const PartDispatchOrderCreateLabelPage({super.key});

  @override
  State<PartDispatchOrderCreateLabelPage> createState() =>
      _PartDispatchOrderCreateLabelPageState();
}

class _PartDispatchOrderCreateLabelPageState
    extends State<PartDispatchOrderCreateLabelPage> {
  final PartDispatchLabelManageLogic logic =
      Get.find<PartDispatchLabelManageLogic>();
  final PartDispatchLabelManageState state =
      Get.find<PartDispatchLabelManageLogic>().state;
  var tecBatchSetPackageQty = TextEditingController();
  var tecBatchSetLabelCount = TextEditingController();
  var tecLabelCount = TextEditingController();

  Widget _totalItem() => _CreateLabelTotalItem(state: state, logic: logic);

  @override
  void initState() {
    state.needRefreshPartList = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tecBatchSetPackageQty.text =
          logic.getSaveBatchSetItemPackQty().toString();
      tecBatchSetLabelCount.text =
          logic.getSaveBatchSetItemLabelCount().toString();
    });
    super.initState();
  }

  @override
  void dispose() {
    tecBatchSetPackageQty.dispose();
    tecBatchSetLabelCount.dispose();
    tecLabelCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Obx(() => CombinationButton(
              text: 'part_dispatch_create_label_create_label'.tr,
              combination: Combination.left,
              isEnabled: logic.canCreateLabel(),
              click: () => createLabelDialog(
                selectedList: state.createSizeList
                    .where((v) => v.isSelected.value)
                    .toList(),
                batchNo: state.dispatchBatchNo.value,
                isSingleSize: state.isSingleSize,
                isSingleInstruction: state.isSingleInstruction,
                refresh: () => logic.refreshCreateLabel(),
              ),
            )),
        CombinationButton(
          text: 'part_dispatch_create_label_label_list'.tr,
          combination: Combination.right,
          click: () => Get.to(
            () => PartDispatchLabelListPage(partIds: state.partListId),
          )?.then((_) => logic.refreshCreateLabel()),
        )
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(
                hint: 'part_dispatch_create_label_type_body'.tr,
                text: state.typeBody.value),
            textSpan(
                hint: 'part_dispatch_create_label_part'.tr,
                text: state.part.value),
            textSpan(
                hint: 'part_dispatch_create_label_instruction'.tr,
                text: state.instructions.value),
            _CreateLabelTitleItem(state: state, logic: logic, controllers: (
              packageQty: tecBatchSetPackageQty,
              labelCount: tecBatchSetLabelCount,
            )),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: state.createSizeList.isNotEmpty
                        ? state.createSizeList.length + 1
                        : 0,
                    itemBuilder: (c, i) => i == state.createSizeList.length
                        ? _totalItem()
                        : _CreateLabelItem(
                            data: state.createSizeList[i],
                            backgroundColor: i % 2 == 0
                                ? Colors.blue.shade50
                                : Colors.grey.shade50,
                            isSingleSize: state.isSingleSize,
                            logic: logic,
                            tecLabelCount: tecLabelCount,
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateLabelTitleItem extends StatelessWidget {
  final PartDispatchLabelManageState state;
  final PartDispatchLabelManageLogic logic;
  final ({
    TextEditingController packageQty,
    TextEditingController labelCount
  }) controllers;

  const _CreateLabelTitleItem({
    required this.state,
    required this.logic,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 45,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.purple.shade100,
          ),
          alignment: Alignment.center,
          child: Text('part_dispatch_create_label_size'.tr),
        ),
        ExpandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_dispatch_qty'.tr,
        ),
        ExpandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_accompany_qty'.tr,
        ),
        ExpandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_generated_qty'.tr,
        ),
        ExpandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_remaining_qty'.tr,
        ),
        Expanded(
          flex: state.isSingleSize ? 6 : 4,
          child: Container(
            height: 45,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.purple.shade100,
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                const SizedBox(width: 5),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        contentPadding: const EdgeInsets.only(bottom: 3),
                        labelText: 'part_dispatch_create_label_packing_qty'.tr,
                        labelStyle:
                            const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      controller: controllers.packageQty,
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Obx(() => CombinationButton(
                      isEnabled: logic.isCanSet(),
                      combination: Combination.left,
                      text: 'part_dispatch_create_label_batch_setting'.tr,
                      click: () {
                        logic.batchSetItemPackQty(
                          controllers.packageQty.text.toIntTry(),
                        );
                        // label count refresh handled by parent
                      },
                    )),
                Obx(() => CombinationButton(
                      isEnabled: logic.isCanSet(),
                      combination: Combination.right,
                      text: 'part_dispatch_create_label_max_number'.tr,
                      click: () {
                        logic.batchSetItemMaxPackQty();
                      },
                    )),
                const SizedBox(width: 5),
              ],
            ),
          ),
        ),
        if (state.isSingleSize)
          Expanded(
            flex: 6,
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.purple.shade100,
              ),
              alignment: Alignment.center,
              child: Row(
                children: [
                  const SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5, bottom: 5),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          contentPadding: const EdgeInsets.only(bottom: 3),
                          labelText: 'part_dispatch_create_label_qty'.tr,
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        controller: controllers.labelCount,
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Obx(() => CombinationButton(
                        isEnabled: logic.isCanSet(),
                        combination: Combination.left,
                        text: 'part_dispatch_create_label_batch_setting'.tr,
                        click: () => logic.batchSetItemLabelCount(
                          controllers.labelCount.text.toIntTry(),
                        ),
                      )),
                  Obx(() => CombinationButton(
                        isEnabled: logic.isCanSet(),
                        combination: Combination.right,
                        text: 'part_dispatch_create_label_max_number'.tr,
                        click: () => logic.batchSetItemMaxLabelCount(),
                      )),
                  const SizedBox(width: 5),
                ],
              ),
            ),
          ),
        Container(
          height: 45,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.purple.shade100,
          ),
          alignment: Alignment.center,
          child: Text('part_dispatch_create_label_select'.tr),
        )
      ],
    );
  }
}

class _CreateLabelItem extends StatelessWidget {
  final CreateLabelInfo data;
  final Color backgroundColor;
  final bool isSingleSize;
  final PartDispatchLabelManageLogic logic;
  final TextEditingController tecLabelCount;

  const _CreateLabelItem({
    required this.data,
    required this.backgroundColor,
    required this.logic,
    required this.isSingleSize,
    required this.tecLabelCount,
  });

  @override
  Widget build(BuildContext context) {
    var packQtyController = TextEditingController(
      text: data.packageQty.value > 0 ? data.packageQty.value.toString() : '',
    );
    var countController = TextEditingController(
      text: data.labelCount.value > 0 ? data.labelCount.value.toString() : '',
    );
    return Row(
      children: [
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: backgroundColor,
          ),
          alignment: Alignment.center,
          child: Text(data.size()),
        ),
        ExpandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.dispatchedQty().toString(),
        ),
        ExpandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.kitQty().toString(),
        ),
        ExpandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.completedQty().toString(),
        ),
        ExpandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.remainingQty().toString(),
        ),
        Expanded(
          flex: isSingleSize ? 6 : 4,
          child: Container(
            height: 35,
            color: backgroundColor,
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                contentPadding: const EdgeInsets.only(bottom: 3),
              ),
              style: const TextStyle(color: Colors.blue),
              controller: packQtyController,
              onChanged: (v) {
                logic.setItemPackQtyListener(
                  controller: packQtyController,
                  data: data,
                );
                if (data.isSelected.value) {
                  logic.refreshMixLabelCount(tecLabelCount);
                }
              },
            ),
          ),
        ),
        if (isSingleSize)
          Expanded(
            flex: 6,
            child: Container(
              height: 35,
              color: backgroundColor,
              child: TextField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    contentPadding: const EdgeInsets.only(bottom: 3)),
                style: const TextStyle(color: Colors.blue),
                controller: countController,
                onChanged: (v) => logic.setItemLabelCountListener(
                  controller: countController,
                  data: data,
                ),
              ),
            ),
          ),
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: backgroundColor,
          ),
          child: Obx(() => Checkbox(
                value: data.isSelected.value,
                onChanged: (c) {
                  data.isSelected.value = c!;
                  logic.refreshMixLabelCount(tecLabelCount);
                },
              )),
        ),
      ],
    );
  }
}

class _CreateLabelTotalItem extends StatelessWidget {
  final PartDispatchLabelManageState state;
  final PartDispatchLabelManageLogic logic;

  const _CreateLabelTotalItem({
    required this.state,
    required this.logic,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      var dispatchedQty = 0;
      var kitQty = 0;
      var completedQty = 0;
      var remainingQty = 0;
      var qty = 0;
      var labelCount = 0;
      state.createSizeList.where((v) => v.isSelected.value).forEach((v) {
        dispatchedQty += v.dispatchedQty();
        kitQty += v.kitQty();
        completedQty += v.completedQty();
        remainingQty += v.remainingQty();
        qty += v.packageQty.value;
        labelCount += v.labelCount.value;
      });
      var backgroundColor = Colors.blue.shade100;
      return Row(
        children: [
          Container(
            height: 35,
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: backgroundColor,
            ),
            alignment: Alignment.center,
            child: Text('part_dispatch_create_label_total'.tr),
          ),
          ExpandedFrameText(
            flex: 3,
            backgroundColor: backgroundColor,
            text: dispatchedQty.toString(),
          ),
          ExpandedFrameText(
            flex: 3,
            backgroundColor: backgroundColor,
            text: kitQty.toString(),
          ),
          ExpandedFrameText(
            flex: 3,
            backgroundColor: backgroundColor,
            text: completedQty.toString(),
          ),
          ExpandedFrameText(
            flex: 3,
            backgroundColor: backgroundColor,
            text: remainingQty.toString(),
          ),
          ExpandedFrameText(
            flex: state.isSingleSize ? 6 : 4,
            backgroundColor: backgroundColor,
            text: qty.toString(),
          ),
          if (state.isSingleSize)
            ExpandedFrameText(
              flex: 6,
              backgroundColor: backgroundColor,
              text: labelCount.toString(),
            ),
          Container(
            height: 35,
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: backgroundColor,
            ),
            alignment: Alignment.center,
            child: Obx(() => Checkbox(
                  value: state.createSizeList.isNotEmpty &&
                      state.createSizeList.every((v) => v.isSelected.value),
                  onChanged: (c) {
                    for (var v in state.createSizeList) {
                      v.isSelected.value = c!;
                    }
                  },
                )),
          )
        ],
      );
    });
  }
}
