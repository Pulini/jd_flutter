import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/create_custom_label_data.dart';
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class MaintainLabelCreateCustomPage extends StatefulWidget {
  const MaintainLabelCreateCustomPage({super.key, required this.labelType});

  final int labelType;

  @override
  State<MaintainLabelCreateCustomPage> createState() =>
      _MaintainLabelCreateCustomPageState();
}

class _MaintainLabelCreateCustomPageState
    extends State<MaintainLabelCreateCustomPage> {
  final logic = Get.find<MaintainLabelLogic>();
  final state = Get.find<MaintainLabelLogic>().state;
  var batchBoxCapacityController = TextEditingController();
  var batchCreateGoodsController = TextEditingController();

  Widget _item(CreateCustomLabelsData data) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey, width: 2),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textSpan(hint: '尺码：', text: data.size, textColor: Colors.red),
                  textSpan(
                    hint: '总货数：',
                    text: data.goodsTotalValue,
                    isBold: false,
                  ),
                  textSpan(
                    hint: '剩余货数：',
                    text: data.surplusGoodsValue,
                    isBold: false,
                  ),
                  Row(
                    children: [
                      Text('箱容：'),
                      Container(
                        height: 35,
                        width: 150,
                        padding: EdgeInsets.only(
                          left: 3,
                          right: 3,
                          bottom: 0,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: data.capacityController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 0, bottom: 15),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          onChanged: (v) {
                            data.capacity.value = v.toDoubleTry();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textSpan(hint: '已生成贴标：', text: data.createdLabels.toString()),
                  textSpan(
                    hint: '已生成货数：',
                    text: data.createdGoodsValue,
                    isBold: false,
                  ),
                  Obx(() => textSpan(
                        hint: '创建数：',
                        text: data.createLabel().toString(),
                        textColor: Colors.green,
                      )),
                  Row(
                    children: [
                      Text('本次生成货数：'),
                      Container(
                        height: 35,
                        width: 150,
                        padding: EdgeInsets.only(
                          left: 3,
                          right: 3,
                          bottom: 0,
                        ),
                        child: TextField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          controller: data.createGoodsController,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 0, bottom: 15),
                            filled: true,
                            fillColor: Colors.transparent,
                          ),
                          onChanged: (v) {
                            data.createGoods.value = v.toDoubleTry();
                          },
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 40,
                  child: Obx(() => Checkbox(
                        value: data.isSelect.value,
                        onChanged: (v) => data.isSelect.value = v!,
                      )),
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    padding: EdgeInsets.all(5),
                    child: Text(
                      '最大值',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () => data.setMax(),
                )
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: '创建自定义标签',
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 15),
              Text('批量箱容：'),
              Expanded(
                child: NumberEditText(controller: batchBoxCapacityController),
              ),
              SizedBox(width: 15),
              Text('批量生成数：'),
              Expanded(
                child: NumberEditText(controller: batchCreateGoodsController),
              ),
              Obx(() => CombinationButton(
                    combination: Combination.left,
                    isEnabled: state.createCustomLabelsData.isNotEmpty &&
                        state.createCustomLabelsData
                            .any((v) => v.isSelect.value),
                    text: '批量设置',
                    click: () => logic.customLabelsBatchSet(
                      batchBoxCapacityController.text.toIntTry(),
                      batchCreateGoodsController.text.toIntTry(),
                    ),
                  )),
              Obx(() => CombinationButton(
                    combination: Combination.right,
                    isEnabled: state.createCustomLabelsData.isNotEmpty &&
                        state.createCustomLabelsData
                            .any((v) => v.isCanCreate()),
                    text: '创建',
                    click: () => logic.createCustomLabels(widget.labelType),
                  )),
              Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Obx(() => Checkbox(
                      value: state.createCustomLabelsData.isNotEmpty &&
                          state.createCustomLabelsData
                              .every((v) => v.isSelect.value),
                      onChanged: (v) {
                        for (var item in state.createCustomLabelsData) {
                          item.isSelect.value = v!;
                        }
                      },
                    )),
              ),
            ],
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsets.all(10),
                  itemCount: state.createCustomLabelsData.length,
                  itemBuilder: (c, i) => _item(state.createCustomLabelsData[i]),
                )),
          ),
        ],
      ),
    );
  }
}
