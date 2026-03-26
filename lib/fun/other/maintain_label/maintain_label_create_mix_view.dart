import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_logic.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class MaintainLabelCreateMixPage extends StatefulWidget {
  const MaintainLabelCreateMixPage({super.key});

  @override
  State<MaintainLabelCreateMixPage> createState() =>
      _MaintainLabelCreateMixPageState();
}

class _MaintainLabelCreateMixPageState
    extends State<MaintainLabelCreateMixPage> {
  final logic = Get.find<MaintainLabelLogic>();
  final state = Get.find<MaintainLabelLogic>().state;
  var maxLabelNumController = TextEditingController();

  Widget _item(List<PickingBarCodeInfo> data) => Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: '尺码:',
              text: data.first.size ?? '',
            ),
            SizedBox(height: 10),
            Row(
              children: [
                expandedFrameText(
                  lineHeight: 40,
                  text: '指令',
                  alignment: Alignment.center,
                  isBold: true,
                  flex: 3,
                  backgroundColor: Colors.blue.shade100,
                  borderColor: Colors.black,
                ),
                expandedFrameText(
                  lineHeight: 40,
                  text: '剩余数',
                  alignment: Alignment.center,
                  isBold: true,
                  flex: 1,
                  backgroundColor: Colors.blue.shade100,
                  borderColor: Colors.black,
                ),
                expandedFrameText(
                  lineHeight: 40,
                  text: '装箱数',
                  alignment: Alignment.center,
                  isBold: true,
                  flex: 2,
                  backgroundColor: Colors.blue.shade100,
                  borderColor: Colors.black,
                ),
                SizedBox(
                  height: 35,
                  child: Obx(() => Checkbox(
                        value: data.every((v) => v.isSelected.value),
                        onChanged: (v) {
                          for (var sub in data) {
                            sub.isSelected.value = v!;
                          }
                          logic.refreshMaxLabel();
                        },
                      )),
                ),
              ],
            ),
            for (var sub in data)
              Row(
                children: [
                  expandedFrameText(
                    lineHeight: 40,
                    text: sub.mtono ?? '',
                    flex: 3,
                    backgroundColor: Colors.white,
                    borderColor: Colors.black,
                  ),
                  expandedFrameText(
                    lineHeight: 40,
                    text: sub.surplusQty.value.toShowString(),
                    alignment: Alignment.center,
                    flex: 1,
                    backgroundColor: Colors.white,
                    borderColor: Colors.black,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        height: 40,
                        padding: EdgeInsetsGeometry.only(
                          left: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Obx(() => TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              controller: TextEditingController(
                                text: sub.packingQty.value > 0
                                    ? sub.packingQty.value.toShowString()
                                    : '',
                              ),
                              decoration: InputDecoration(
                                contentPadding:
                                    const EdgeInsets.only(top: 0, bottom: 15),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              onChanged: (v) {
                                sub.packingQty.value = v.toDoubleTry();
                                logic.refreshMaxLabel();
                              },
                            )),
                      )),
                  SizedBox(
                    height: 40,
                    child: Obx(() => Checkbox(
                          value: sub.isSelected.value,
                          onChanged: (v) {
                            sub.isSelected.value = v!;
                            logic.refreshMaxLabel();
                          },
                        )),
                  ),
                ],
              ),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ever(state.maxLabel, (v) => maxLabelNumController.text = v.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: "创建混码标签",
      body: Column(
        children: [
          Container(
            height: 40,
            padding: EdgeInsetsGeometry.only(left: 10, right: 10),
            child: TextField(
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: maxLabelNumController,
              decoration: InputDecoration(
                labelText: '最大标签数',
                contentPadding: const EdgeInsets.only(left: 15),
                filled: true,
                fillColor: Colors.grey.shade200,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50)),
                ),
                hintStyle: const TextStyle(color: Colors.white),
                prefixIcon: IconButton(
                  onPressed: () => maxLabelNumController.clear(),
                  icon:
                      const Icon(Icons.replay_circle_filled, color: Colors.red),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => CombinationButton(
                          combination: Combination.left,
                          isEnabled: state.createMixLabelsData.any(
                            (v) => v.any((v2) => v2.isSelected.value),
                          ),
                          text: '填满剩余量',
                          click: () => logic.fillRemainingQty(),
                        )),
                    Obx(() => CombinationButton(
                          combination: Combination.right,
                          isEnabled: state.createMixLabelsData.any(
                            (v) => v.any((v2) =>
                                v2.isSelected.value && v2.packingQty.value > 0),
                          ),
                          text: '创建',
                          click: () => logic.createMixLabel(
                              maxLabelNumController.text.toIntTry()),
                        )),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: EdgeInsetsGeometry.all(10),
                  itemCount: state.createMixLabelsData.length,
                  itemBuilder: (c, i) => _item(state.createMixLabelsData[i]),
                )),
          )
        ],
      ),
    );
  }
}
