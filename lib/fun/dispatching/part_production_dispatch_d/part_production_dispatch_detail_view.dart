import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_logic.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class PartProductionDispatchDetailPage extends StatefulWidget {
  const PartProductionDispatchDetailPage({super.key});

  @override
  State<PartProductionDispatchDetailPage> createState() =>
      _PartProductionDispatchDetailPageState();
}

class _PartProductionDispatchDetailPageState
    extends State<PartProductionDispatchDetailPage> {
  final PartProductionDispatchLogic logic =
      Get.find<PartProductionDispatchLogic>();
  final PartProductionDispatchState state =
      Get.find<PartProductionDispatchLogic>().state;
  var batchSetItemPackQtyController = TextEditingController();
  var batchSetItemLabelCountController = TextEditingController();
  var createLabelQtyController = TextEditingController(text: '1');

  Widget _instructionItem(int index) => Obx(() => GestureDetector(
        onTap: () => logic.changeInstruction(index),
        child: Container(
          height: 35,
          margin: EdgeInsets.only(right: 5),
          padding: EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: state.instructionSelect.value == index
                  ? Colors.green
                  : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(7),
            color: state.instructionSelect.value == index
                ? Colors.green.shade100
                : Colors.grey.shade100,
          ),
          alignment: Alignment.center,
          child: Text(
            state.instructionList[index],
            style: TextStyle(
              color: state.instructionSelect.value == index
                  ? Colors.green
                  : Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));

  Widget _titleItem() {
    var showList = state.sizeList.where((v) => v.isShow.value);
    return Row(
      children: [
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.purple.shade100,
          ),
          alignment: Alignment.center,
          child: Text('尺码'),
        ),
        expandedFrameText(
          flex: 2,
          backgroundColor: Colors.purple.shade100,
          text: '派工数',
        ),
        expandedFrameText(
          flex: 2,
          backgroundColor: Colors.purple.shade100,
          text: '已生成数',
        ),
        expandedFrameText(
          flex: 2,
          backgroundColor: Colors.purple.shade100,
          text: '剩余数',
        ),
        Expanded(
          flex: state.isSingleSize.value ? 3 : 2,
          child: Container(
            height: 35,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.purple.shade100,
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(width: 5),
                Text('装箱数：'),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[0-9.]'))
                    ],
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      contentPadding: EdgeInsets.only(bottom: 3),
                    ),
                    controller: batchSetItemPackQtyController,
                    onChanged: (s) => logic
                        .batchSetPackQtyListener(batchSetItemPackQtyController),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 5, right: 5),
                  child: Obx(() => CombinationButton(
                        isEnabled: showList.isNotEmpty &&
                            showList.any((v) => v.isSelected.value),
                        text: '批设置',
                        click: () => setState(() {
                          logic.batchSetItemPackQty(
                              batchSetItemPackQtyController);
                          batchSetItemLabelCountController.text =
                              logic.getInstructionSizeItemMaxCount().toString();
                          createLabelQtyController.text =
                              state.createCountMax.value.toString();
                        }),
                      )),
                ),
              ],
            ),
          ),
        ),
        Obx(() => state.isSingleSize.value
            ? Expanded(
                flex: state.isSingleSize.value ? 3 : 2,
                child: Container(
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    color: Colors.purple.shade100,
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    children: [
                      SizedBox(width: 5),
                      Text('标签数：'),
                      Expanded(
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
                          ),
                          controller: batchSetItemLabelCountController,
                          onChanged: (s) => logic.batchSetLabelCountListener(
                            batchSetItemLabelCountController,
                          ),
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsetsGeometry.only(left: 5, right: 5),
                        child: Obx(() => CombinationButton(
                              isEnabled: showList.isNotEmpty &&
                                  showList.any((v) => v.isSelected.value),
                              text: '批设置',
                              click: () => setState(() {
                                logic.batchSetItemLabelCountQty(
                                    batchSetItemLabelCountController.text);
                              }),
                            )),
                      ),
                    ],
                  ),
                ),
              )
            : Container()),
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.purple.shade100,
          ),
          alignment: Alignment.center,
          child: Text('选择'),
        )
      ],
    );
  }

  Widget _item(CreateLabelInfo data, Color backgroundColor) {
    var packQtyController = TextEditingController(
        text: data.qty.value > 0 ? data.qty.value.toShowString() : '');
    var countController = TextEditingController(
        text: data.createCount.value > 0
            ? data.createCount.value.toString()
            : '');
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
          flex: 2,
          backgroundColor: backgroundColor,
          text: data.dispatchedQty().toShowString(),
        ),
        expandedFrameText(
          flex: 2,
          backgroundColor: backgroundColor,
          text: data.completedQty().toShowString(),
        ),
        expandedFrameText(
          flex: 2,
          backgroundColor: backgroundColor,
          text: data.remainingQty().toShowString(),
        ),
        Obx(() => Expanded(
              flex: state.isSingleSize.value ? 3 : 2,
              child: Container(
                height: 35,
                color: backgroundColor,
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0),
                    ),
                    contentPadding: EdgeInsets.only(bottom: 3),
                  ),
                  style: TextStyle(color: Colors.blue),
                  controller: packQtyController,
                  onChanged: (v) => logic.setItemPackQtyListener(
                    controller: packQtyController,
                    data: data,
                  ),
                ),
              ),
            )),
        Obx(() => state.isSingleSize.value
            ? Expanded(
                flex: state.isSingleSize.value ? 3 : 2,
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
                    controller: countController,
                    onChanged: (v) => logic.setItemLabelCountListener(
                      controller: countController,
                      data: data,
                    ),
                  ),
                ),
              )
            : Container()),
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: backgroundColor,
          ),
          child: Obx(() => Checkbox(
                value: data.isSelected.value,
                onChanged: (c) => data.isSelected.value = c!,
              )),
        ),
      ],
    );
  }

  Widget _totalItem() => Obx(() {
        var dispatchedQty = 0.0;
        var completedQty = 0.0;
        var remainingQty = 0.0;
        var qty = 0.0;
        var labelCount = 0;
        var showList = state.sizeList.where((v) => v.isShow.value);
        showList.where((v) => v.isSelected.value).forEach((v) {
          dispatchedQty = dispatchedQty.add(v.dispatchedQty());
          completedQty = completedQty.add(v.completedQty());
          remainingQty = remainingQty.add(v.remainingQty());
          qty = qty.add(v.qty.value);
          labelCount += v.createCount.value;
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
              child: Text('合计'),
            ),
            expandedFrameText(
              flex: 2,
              backgroundColor: backgroundColor,
              text: dispatchedQty.toShowString(),
            ),
            expandedFrameText(
              flex: 2,
              backgroundColor: backgroundColor,
              text: completedQty.toShowString(),
            ),
            expandedFrameText(
              flex: 2,
              backgroundColor: backgroundColor,
              text: remainingQty.toShowString(),
            ),
            Obx(() => expandedFrameText(
                  flex: state.isSingleSize.value ? 3 : 2,
                  backgroundColor: backgroundColor,
                  text: qty.toShowString(),
                )),
            Obx(() => state.isSingleSize.value
                ? expandedFrameText(
                    flex: state.isSingleSize.value ? 3 : 2,
                    backgroundColor: backgroundColor,
                    text: labelCount.toString(),
                  )
                : Container()),
            Container(
              height: 35,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: backgroundColor,
              ),
              alignment: Alignment.center,
              child: Obx(() => Checkbox(
                    value: showList.isNotEmpty &&
                        showList.every((v) => v.isSelected.value),
                    onChanged: (c) {
                      for (var v in showList) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      batchSetItemPackQtyController.text =
          logic.getSaveBatchSetItemPackQty().toShowString();
      batchSetItemLabelCountController.text =
          logic.getSaveBatchSetItemLabelCount().toString();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var createSet = Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        children: [
          SizedBox(width: 5),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                Container(
                  margin: EdgeInsetsGeometry.only(top: 5, right: 5, bottom: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Obx(() => CheckBox(
                            onChanged: (c) {
                              state.isSingleInstruction.value = c;
                              createLabelQtyController.text =
                                  logic.refreshCountMax().toString();
                            },
                            name: '单指令',
                            value: state.isSingleInstruction.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (c) {
                              state.isSingleInstruction.value = !c;
                              createLabelQtyController.text =
                                  logic.refreshCountMax().toString();
                            },
                            name: '多指令',
                            value: !state.isSingleInstruction.value,
                          )),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsetsGeometry.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      Obx(() => CheckBox(
                            onChanged: (c) {
                              state.isSingleSize.value = c;
                              createLabelQtyController.text =
                                  logic.refreshCountMax().toString();
                            },
                            name: '单码装',
                            value: state.isSingleSize.value,
                          )),
                      Obx(() => CheckBox(
                            onChanged: (c) {
                              state.isSingleSize.value = !c;
                              createLabelQtyController.text =
                                  logic.refreshCountMax().toString();
                            },
                            name: '混码装',
                            value: !state.isSingleSize.value,
                          )),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '混装校验',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Obx(() => Switch(
                            thumbIcon: WidgetStateProperty.resolveWith(
                              (v) => Icon(v.contains(WidgetState.selected)
                                  ? Icons.check
                                  : Icons.close),
                            ),
                            value: state.checkSizeQty.value,
                            onChanged: state.isSingleInstruction.value &&
                                    state.isSingleSize.value
                                ? null
                                : (c) {
                                    state.checkSizeQty.value = c;
                                    if (c) {
                                      //如果校验混装，则禁止生成尾标
                                      state.createLastLabel.value = false;
                                    }
                                    createLabelQtyController.text =
                                        logic.refreshCountMax().toString();
                                  },
                          )),
                      SizedBox(width: 10),
                      Text(
                        '附带尾标',
                        style: const TextStyle(color: Colors.black),
                      ),
                      Obx(() => Switch(
                            thumbIcon: WidgetStateProperty.resolveWith(
                              (v) => Icon(v.contains(WidgetState.selected)
                                  ? Icons.check
                                  : Icons.close),
                            ),
                            value: state.createLastLabel.value,
                            onChanged: state.isSingleInstruction.value &&
                                    state.isSingleSize.value
                                ? null
                                : state.checkSizeQty.value
                                    ? null
                                    : (v) {
                                        state.createLastLabel.value = v;
                                        createLabelQtyController.text =
                                            logic.refreshCountMax().toString();
                                      },
                          ))
                    ],
                  ),
                ),
                Obx(() => state.isSingleSize.value
                    ? Container()
                    : SizedBox(
                        width: 160,
                        child: NumberEditText(
                          controller: createLabelQtyController,
                          onChanged: (v) {
                            if (v.toIntTry() > state.createCountMax.value) {
                              createLabelQtyController.text =
                                  state.createCountMax.value.toString();
                              state.createCount.value =
                                  state.createCountMax.value;
                            } else {
                              state.createCount.value = v.toIntTry();
                            }
                          },
                          hint: '创建贴标数',
                        ),
                      )),
                Obx(() => Padding(
                      padding: EdgeInsetsGeometry.only(left: 10, right: 10),
                      child: Center(
                        child: Text(
                          state.workerName.value,
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                SizedBox(
                  width: 160,
                  child: NumberEditText(
                    hint: '创建人工号',
                    onChanged: (v) => logic.checkWorker(v),
                  ),
                ),
                Obx(() => Padding(
                      padding: EdgeInsetsGeometry.only(left: 10, right: 10),
                      child: Center(
                        child: Text(
                          state.errorMsg.value,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );

    return pageBody(
      title: '型体：${state.detailInfo!.productName}',
      actions: [
        Obx(() => Padding(
              padding: EdgeInsetsGeometry.only(right: 5),
              child: CombinationButton(
                isEnabled: logic.createButtonEnable(),
                text: '创建贴标',
                click: () => askDialog(
                  content: '确定要按照当前填写内容生成标签吗？',
                  confirm: () => logic.createLabel(),
                ),
              ),
            ))
      ],
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            createSet,
            Padding(
              padding: EdgeInsetsGeometry.only(top: 5, bottom: 5),
              child: textSpan(
                hint: '部位：',
                text: state.detailInfo!.materialName ?? '',
                maxLines: 3,
              ),
            ),
            SizedBox(
              height: 30,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '指令：',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Obx(() => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.instructionList.length,
                          itemBuilder: (c, i) => _instructionItem(i),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5),
            Obx(() => state.sizeList.isEmpty ? Container() : _titleItem()),
            Expanded(
              child: Obx(() {
                if (state.sizeList.isEmpty) {
                  return Center(
                    child: Text('贴标已全部创建完毕！'),
                  );
                } else {
                  var list =
                      state.sizeList.where((v) => v.isShow.value).toList();
                  return ListView.builder(
                    itemCount: list.isNotEmpty ? list.length + 1 : list.length,
                    itemBuilder: (c, i) => list.isNotEmpty && i == list.length
                        ? _totalItem()
                        : _item(
                            list[i],
                            i % 2 == 0 ? Colors.grey.shade100 : Colors.white,
                          ),
                  );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}
