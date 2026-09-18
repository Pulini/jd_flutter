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
  var mixCapacityController = TextEditingController();

  Widget _item(CreateCustomLabelsData data) =>
      _MaintainLabelCreateCustomItem(data: data);

  @override
  void dispose() {
    state.mixCapacityControllerText.value='';
    batchBoxCapacityController.dispose();
    batchCreateGoodsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'other_maintain_label_create_custom'.tr,
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 15),
              Text('other_maintain_label_batch_box_capacity'.tr),
              Expanded(
                child: NumberEditText(controller: batchBoxCapacityController),
              ),
              const SizedBox(width: 15),
              Text('other_maintain_label_batch_generate_num'.tr),
              Expanded(
                child: NumberEditText(controller: batchCreateGoodsController),
              ),
              Text('other_maintain_label_mix_box_capacity'.tr),
              Expanded(
                child: NumberEditText(
                  controller: mixCapacityController,
                  onChanged: (s) {
                      state.mixCapacityControllerText.value = s;
                      if(s.isEmpty){
                        logic.cleanMixedAssemble();
                      }
                  },
                ),
              ),
              Obx(() => CombinationButton(
                    combination: Combination.left,
                    isEnabled: state.createCustomLabelsData.isNotEmpty &&
                        state.createCustomLabelsData.any((v) => v.isSelect.value),
                    text: 'other_maintain_label_batch_set'.tr,
                    click: () => logic.customLabelsBatchSet(
                      batchBoxCapacityController.text.toIntTry(),
                      batchCreateGoodsController.text.toIntTry(),
                    ),
                  )),
              Obx(
                () => CombinationButton(
                  isEnabled: state.createCustomLabelsData.isNotEmpty &&
                      state.createCustomLabelsData.any((v) => v.isSelect.value),
                  text: 'maintain_label_dialog_set_full'.tr,
                  click: () => logic.setFull(),
                  combination: Combination.middle,
                ),
              ),
              Obx(
                () => CombinationButton(
                  isEnabled: state.mixCapacityControllerText.value.isNotEmpty,
                  text: 'other_maintain_label_mix_assemble'.tr,
                  click: () => logic.mixedAssemble(mixCapacityController.text),
                  combination: Combination.middle,
                ),
              ),
              Obx(() => CombinationButton(
                    combination: Combination.right,
                    isEnabled: state.createCustomLabelsData.isNotEmpty &&
                        state.createCustomLabelsData
                            .any((v) => v.isCanCreate() && state.mixCapacityControllerText.value.isEmpty),
                    text: 'other_maintain_label_create'.tr,
                    click: () => logic.createCustomLabels(widget.labelType),
                  )),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
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
                  padding: const EdgeInsets.all(10),
                  itemCount: state.createCustomLabelsData.length,
                  itemBuilder: (c, i) => _item(state.createCustomLabelsData[i]),
                )),
          ),
        ],
      ),
    );
  }
}

class _MaintainLabelCreateCustomItem extends StatelessWidget {
  final CreateCustomLabelsData data;

  const _MaintainLabelCreateCustomItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                textSpan(hint: 'other_maintain_label_size_colon'.tr, text: data.size, textColor: Colors.red),
                textSpan(
                  hint: 'other_maintain_label_total_goods'.tr,
                  text: data.goodsTotalValue,
                  isBold: false,
                ),
                textSpan(
                  hint: 'other_maintain_label_remaining_goods'.tr,
                  text: data.surplusGoodsValue,
                  isBold: false,
                ),
                Row(
                  children: [
                    Text('other_maintain_label_box_capacity'.tr),
                    Container(
                      height: 35,
                      width: 150,
                      padding: const EdgeInsets.only(
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
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 0, bottom: 15),
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
                textSpan(hint: 'other_maintain_label_generated_label'.tr, text: data.createdLabels.toString()),
                textSpan(
                  hint: 'other_maintain_label_generated_goods'.tr,
                  text: data.createdGoodsValue,
                  isBold: false,
                ),
                Obx(() => textSpan(
                      hint: 'other_maintain_label_create_num'.tr,
                      text: data.createLabel().toString(),
                      textColor: Colors.green,
                    )),
                Row(
                  children: [
                    Text('other_maintain_label_current_generate_goods'.tr),
                    Container(
                      height: 35,
                      width: 150,
                      padding: const EdgeInsets.only(
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
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.only(top: 0, bottom: 15),
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
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  padding: const EdgeInsets.all(5),
                  child: const Text(
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
  }
}
