import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch/part_production_dispatch_dialogs.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch/part_production_dispatch_logic.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch/part_production_dispatch_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

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
  var batchSetController = TextEditingController();

  Widget _instructionItem(List data) => Obx(() => GestureDetector(
        onTap: () {
          (data.last as RxBool).value = !(data.last as RxBool).value;
          logic.refreshSizeList();
        },
        child: Container(
          height: 35,
          margin: EdgeInsets.only(right: 5),
          padding: EdgeInsets.only(left: 5, right: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: (data.last as RxBool).value ? Colors.blue : Colors.red,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(7),
            color: (data.last as RxBool).value
                ? Colors.blue.shade100
                : Colors.orange.shade100,
          ),
          alignment: Alignment.center,
          child: Text(
            data.first.toString(),
            style: TextStyle(
              color: (data.last as RxBool).value ? Colors.blue : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ));

  Widget _titleItem() {
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
          backgroundColor: Colors.purple.shade100,
          text: '派工数',
        ),
        expandedFrameText(
          backgroundColor: Colors.purple.shade100,
          text: '以生成数',
        ),
        expandedFrameText(
          backgroundColor: Colors.purple.shade100,
          text: '剩余数',
        ),
        Expanded(
          child: Container(
            height: 35,
            width: 60,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              color: Colors.purple.shade100,
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                SizedBox(width: 5),
                Text('箱容：'),
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
                    controller: batchSetController,
                    onChanged: (s) {
                      if (s.split('.').length > 2) {
                        batchSetController.text =
                            s.substring(0, s.lastIndexOf('.'));
                        batchSetController.selection =
                            TextSelection.fromPosition(
                          TextPosition(offset: batchSetController.text.length),
                        );
                      }
                    },
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsGeometry.only(left: 5, right: 5),
                  child: CombinationButton(
                    text: '批设置',
                    click: () => setState(() {
                      hidKeyboard();
                      batchSetController.text =
                          logic.batchSetItemQty(batchSetController.text);
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
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

  Widget _item(List<PartProductionDispatchOrderDetailSizeInfo> list) {
    var dispatchedQty =
        list.map((v) => v.dispatchedQty ?? 0).reduce((a, b) => a.add(b));
    var completedQty =
        list.map((v) => v.completedQty ?? 0).reduce((a, b) => a.add(b));
    var remainingQty =
        list.map((v) => v.remainingQty ?? 0).reduce((a, b) => a.add(b));
    var initQty = list.map((v) => v.qty.value).reduce((a, b) => a.add(b));
    var controller =
        TextEditingController(text: initQty > 0 ? initQty.toShowString() : '');
    return Row(
      children: [
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Text(list.first.size ?? ''),
        ),
        expandedFrameText(
          backgroundColor: Colors.white,
          text: dispatchedQty.toShowString(),
        ),
        expandedFrameText(
          backgroundColor: Colors.white,
          text: completedQty.toShowString(),
        ),
        expandedFrameText(
          backgroundColor: Colors.white,
          text: remainingQty.toShowString(),
        ),
        Expanded(
          child: Container(
            height: 35,
            color: Colors.white,
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                contentPadding: EdgeInsets.only(bottom: 3),
              ),
              style: TextStyle(color: Colors.blue),
              controller: controller,
              onChanged: (v) => logic.setItemQty(
                dataList: list,
                qtyString: v,
                refresh: (t) {
                  controller.text = t;
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          height: 35,
          width: 60,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.white,
          ),
          child: Obx(() => Checkbox(
                value: list.every((v) => v.isSelected.value),
                onChanged: (c) {
                  for (var v in list) {
                    v.isSelected.value = c!;
                  }
                },
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
        var list = state.sizeList.where((v) => v.isShow.value);
        if (list.isNotEmpty) {
          dispatchedQty =
              list.map((v) => v.dispatchedQty ?? 0).reduce((a, b) => a.add(b));
          completedQty =
              list.map((v) => v.completedQty ?? 0).reduce((a, b) => a.add(b));
          remainingQty =
              list.map((v) => v.remainingQty ?? 0).reduce((a, b) => a.add(b));
          qty = list.map((v) => v.qty.value).reduce((a, b) => a.add(b));
        }
        return Row(
          children: [
            Container(
              height: 35,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.blue.shade100,
              ),
              alignment: Alignment.center,
              child: Text('合计'),
            ),
            expandedFrameText(
              backgroundColor: Colors.blue.shade100,
              text: dispatchedQty.toShowString(),
            ),
            expandedFrameText(
              backgroundColor: Colors.blue.shade100,
              text: completedQty.toShowString(),
            ),
            expandedFrameText(
              backgroundColor: Colors.blue.shade100,
              text: remainingQty.toShowString(),
            ),
            expandedFrameText(
              backgroundColor: Colors.blue.shade100,
              text: qty.toShowString(),
            ),
            Container(
              height: 35,
              width: 60,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: Colors.blue.shade100,
              ),
              alignment: Alignment.center,
              child: Obx(() => Checkbox(
                    value: list.isNotEmpty &&
                        list.every((v) => v.isSelected.value),
                    onChanged: (c) {
                      for (var v in list) {
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
      double saveQty = spGet('${Get.currentRoute}/BatchSetQty') ?? 0.0;
      batchSetController.text = saveQty == 0 ? '100' : saveQty.toShowString();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        CombinationButton(
          text: '创建贴标',
          click: () => createLabelDialog(
            sizeList: logic.getCreateLabelMap(),
            callback: () => logic.refreshOrderDetail(() {}),
          ),
        )
      ],
      title: '型体：${state.detailInfo!.productName}',
      body: Padding(
        padding: EdgeInsetsGeometry.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: '部位：',
              text: state.detailInfo!.materialName ?? '',
              maxLines: 3,
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
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.instructionList.length,
                      itemBuilder: (c, i) =>
                          _instructionItem(state.instructionList[i]),
                    ),
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
                  var map = groupBy(list, (v) => v.size).values.toList();
                  return ListView.builder(
                    itemCount: map.length + 1,
                    itemBuilder: (c, i) =>
                        i == map.length ? _totalItem() : _item(map[i]),
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
