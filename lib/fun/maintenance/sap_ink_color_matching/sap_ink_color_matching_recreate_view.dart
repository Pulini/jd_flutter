import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_dialog.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'sap_ink_color_matching_logic.dart';

class SapInkColorMatchingRecreatePage extends StatefulWidget {
  const SapInkColorMatchingRecreatePage({super.key});

  @override
  State<SapInkColorMatchingRecreatePage> createState() =>
      _SapInkColorMatchingRecreatePageState();
}

class _SapInkColorMatchingRecreatePageState
    extends State<SapInkColorMatchingRecreatePage> {
  final SapInkColorMatchingLogic logic = Get.find<SapInkColorMatchingLogic>();
  final SapInkColorMatchingState state =
      Get.find<SapInkColorMatchingLogic>().state;
  int index = Get.arguments['index'];
  String deviceName = Get.arguments['deviceName'];
  String deviceServerIp = Get.arguments['deviceServerIp'];
  int deviceScalePort = Get.arguments['deviceScalePort'];
  var controller = TextEditingController();
  late Widget ratioBarChartWidget;
  var errorTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, color: Colors.red);
  var fn = FocusNode();
  var hasSet = false.obs;

  _item(SapRecreateInkColorItemInfo data, int index) {
    var ballColor = data.materialColor.getColorByDescription();
    return GestureDetector(
      onTap: () {
        if (data.presetWeight.value <= 0) {
          errorDialog(
              content:
                  'sap_ink_color_matching_recreate_pre_toning_weight_tips'.tr,
              back: () => fn.requestFocus());
        } else {
          puttingDialog(
            data: data,
            deviceName: deviceName,
            deviceServerIp: deviceServerIp,
            deviceScalePort: deviceScalePort,
            nowWeight: logic.getNowWeight(index),
            refresh: () {
              logic.refreshItemList(index);
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 30,
              width: 30,
              margin: const EdgeInsets.only(right: 5),
              decoration: BoxDecoration(
                color: ballColor,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: ballColor == Colors.transparent
                  ? Center(
                      child: Text('sap_ink_color_matching_recreate_null'.tr))
                  : null,
            ),
            expandedTextSpan(
              flex: 4,
              hint: 'sap_ink_color_matching_recreate_material'.tr,
              text: '(${data.materialCode})${data.materialName}',
              textColor: Colors.black87,
            ),
            Obx(() => expandedTextSpan(
                  flex: 2,
                  hint: 'sap_ink_color_matching_recreate_pre_toning_weight'.tr,
                  text:
                      '${data.presetWeight.value.toFixed(4).toShowString()} kg',
                )),
            Obx(() => expandedTextSpan(
                  flex: 2,
                  hint: 'sap_ink_color_matching_recreate_actual_weight'.tr,
                  text:
                      '${data.actualWeight.value.toFixed(4).toShowString()} kg',
                )),
            Obx(() => expandedTextSpan(
                  flex: 2,
                  hint:
                      'sap_ink_color_matching_recreate_need_supplemented_weight'
                          .tr,
                  text:
                      '${data.repairWeight.value.toFixed(4).toShowString()} kg',
                )),
          ],
        ),
      ),
    );
  }

  setPresetWeight() {
    if (!hasSet.value) {
      hidKeyboard();
      logic.setPresetWeight(controller.text.toDoubleTry());
      hasSet.value = true;
    }
  }

  @override
  void initState() {
    logic.initRecreateItemData(index);
    ratioBarChartWidget =
        ratioBarChart(ratioList: logic.getRecreateRatioColorLine());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        Container(
          padding: const EdgeInsets.only(left: 10, top: 0, right: 0, bottom: 0),
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.blue, width: 2),
          ),
          child: Row(
            children: [
              Text(
                'sap_ink_color_matching_recreate_pre_toning_weight_unit'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 150,
                margin: const EdgeInsets.all(1),
                height: 40,
                child: Obx(() => TextField(
                      focusNode: fn,
                      onSubmitted: (value) => setPresetWeight(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                      ],
                      controller: controller,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(
                          top: 0,
                          bottom: 0,
                          left: 15,
                          right: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(
                            color: Colors.transparent,
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        hintStyle: const TextStyle(color: Colors.white),
                        prefixIcon: IconButton(
                          onPressed: () => askDialog(
                            content:
                                'sap_ink_color_matching_recreate_restart_tips'
                                    .tr,
                            confirm: () {
                              controller.clear();
                              logic.refreshAll();
                              hasSet.value = false;
                            },
                          ),
                          icon: const Icon(
                            Icons.replay_circle_filled,
                            color: Colors.red,
                          ),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () => setPresetWeight(),
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: hasSet.value ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                    )),
              )
            ],
          ),
        )
      ],
      title: 'sap_ink_color_matching_recreate_recurrent_color_toning'.tr,
      popTitle: 'sap_ink_color_matching_recreate_exit_tips'.tr,
      body: Padding(
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
          bottom: 10,
        ),
        child: Column(
          children: [
            ratioBarChartWidget,
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'sap_ink_color_matching_recreate_type_body'.tr,
                    text: state.orderList[index].typeBody ?? '',
                    textColor: Colors.green.shade700,
                  ),
                  textSpan(
                    hint: 'sap_ink_color_matching_recreate_inkmaster'.tr,
                    text: '${userInfo?.name}',
                    textColor: Colors.black87,
                  ),
                  Obx(() => textSpan(
                        hint: 'sap_ink_color_matching_recreate_final_weight'.tr,
                        text:
                            '${state.finalWeight.value.toFixed(4).toShowString()} kg',
                        textColor: Colors.blue,
                      )),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 10),
                itemCount: state.presetInkColorList.length,
                itemBuilder: (c, i) => _item(state.presetInkColorList[i], i),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    state.cleanRecreate();
    super.dispose();
  }
}
