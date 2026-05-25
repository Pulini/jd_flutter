import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_list/part_dispatch_label_list_view.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_label_manage_dialog.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_order_list/part_dispatch_order_list_logic.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_order_list/part_dispatch_order_list_state.dart';
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

  Widget _titleItem() {
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
        expandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_dispatch_qty'.tr,
        ),
        expandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_accompany_qty'.tr,
        ),
        expandedFrameText(
          flex: 3,
          lineHeight: 45,
          backgroundColor: Colors.purple.shade100,
          text: 'part_dispatch_create_label_generated_qty'.tr,
        ),
        expandedFrameText(
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
                SizedBox(width: 5),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 5),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                        contentPadding: EdgeInsets.only(bottom: 3),
                        labelText: 'part_dispatch_create_label_packing_qty'.tr,
                        labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      controller: tecBatchSetPackageQty,
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Obx(() => CombinationButton(
                      isEnabled: logic.isCanSet(),
                      combination: Combination.left,
                      text: 'part_dispatch_create_label_batch_setting'.tr,
                      click: () {
                        logic.batchSetItemPackQty(
                          tecBatchSetPackageQty.text.toIntTry(),
                        );
                        logic.refreshMixLabelCount(tecLabelCount);
                      },
                    )),
                Obx(() => CombinationButton(
                      isEnabled: logic.isCanSet(),
                      combination: Combination.right,
                      text: 'part_dispatch_create_label_max_number'.tr,
                      click: () {
                        logic.batchSetItemMaxPackQty();
                        logic.refreshMixLabelCount(tecLabelCount);
                      },
                    )),
                SizedBox(width: 5),
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
                  SizedBox(width: 5),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 5, bottom: 5),
                      child: TextField(
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3),
                          ),
                          contentPadding: EdgeInsets.only(bottom: 3),
                          labelText: 'part_dispatch_create_label_qty'.tr,
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        controller: tecBatchSetLabelCount,
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Obx(() => CombinationButton(
                        isEnabled: logic.isCanSet(),
                        combination: Combination.left,
                        text: 'part_dispatch_create_label_batch_setting'.tr,
                        click: () => logic.batchSetItemLabelCount(
                          tecBatchSetLabelCount.text.toIntTry(),
                        ),
                      )),
                  Obx(() => CombinationButton(
                        isEnabled: logic.isCanSet(),
                        combination: Combination.right,
                        text: 'part_dispatch_create_label_max_number'.tr,
                        click: () => logic.batchSetItemMaxLabelCount(),
                      )),
                  SizedBox(width: 5),
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

  Widget _item(CreateLabelInfo data, Color backgroundColor) {
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
        expandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.dispatchedQty().toString(),
        ),
        expandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.kitQty().toString(),
        ),
        expandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.completedQty().toString(),
        ),
        expandedFrameText(
          flex: 3,
          backgroundColor: backgroundColor,
          text: data.remainingQty().toString(),
        ),
        Expanded(
          flex: state.isSingleSize ? 6 : 4,
          child: Container(
            height: 35,
            color: backgroundColor,
            child: TextField(
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                contentPadding: EdgeInsets.only(bottom: 3),
              ),
              style: TextStyle(color: Colors.blue),
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
        if (state.isSingleSize)
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
                    contentPadding: EdgeInsets.only(bottom: 3)),
                style: TextStyle(color: Colors.blue),
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

  Widget _totalItem() => Obx(() {
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
            expandedFrameText(
              flex: 3,
              backgroundColor: backgroundColor,
              text: dispatchedQty.toString(),
            ),
            expandedFrameText(
              flex: 3,
              backgroundColor: backgroundColor,
              text: kitQty.toString(),
            ),
            expandedFrameText(
              flex: 3,
              backgroundColor: backgroundColor,
              text: completedQty.toString(),
            ),
            expandedFrameText(
              flex: 3,
              backgroundColor: backgroundColor,
              text: remainingQty.toString(),
            ),
            expandedFrameText(
              flex: state.isSingleSize ? 6 : 4,
              backgroundColor: backgroundColor,
              text: qty.toString(),
            ),
            if (state.isSingleSize)
              expandedFrameText(
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

  @override
  void initState() {
    state.needRefreshPartList=false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      tecBatchSetPackageQty.text =
          logic.getSaveBatchSetItemPackQty().toString();
      tecBatchSetLabelCount.text =
          logic.getSaveBatchSetItemLabelCount().toString();
    });
    super.initState();
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
        padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(hint: 'part_dispatch_create_label_type_body'.tr, text: state.typeBody.value),
            textSpan(hint: 'part_dispatch_create_label_part'.tr, text: state.part.value),
            textSpan(hint: 'part_dispatch_create_label_instruction'.tr, text: state.instructions.value),
            _titleItem(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: state.createSizeList.isNotEmpty
                        ? state.createSizeList.length + 1
                        : 0,
                    itemBuilder: (c, i) => i == state.createSizeList.length
                        ? _totalItem()
                        : _item(
                            state.createSizeList[i],
                            i % 2 == 0
                                ? Colors.blue.shade50
                                : Colors.grey.shade50,
                          ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
