import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/fun/maintenance/sap_ink_color_matching/sap_ink_color_matching_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';

import 'sap_ink_color_matching_logic.dart';
import 'sap_ink_color_matching_state.dart';

class SapInkColorMatchingPage extends StatefulWidget {
  const SapInkColorMatchingPage({super.key});

  @override
  State<SapInkColorMatchingPage> createState() =>
      _SapInkColorMatchingPageState();
}

class _SapInkColorMatchingPageState extends State<SapInkColorMatchingPage> {
  final SapInkColorMatchingLogic logic = Get.put(SapInkColorMatchingLogic());
  final SapInkColorMatchingState state =
      Get.find<SapInkColorMatchingLogic>().state;

  //

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.sapInkColorMatching.name}${PickerType.startDate}',
  );

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapInkColorMatching.name}${PickerType.endDate}',
  );
  var controller = TextEditingController();

  var tecTypeBody = TextEditingController();

  _item(int index) {
    SapInkColorMatchOrderInfo data = state.orderList[index];
    return GestureDetector(
      onTap: () {
        if (data.materialList?.isNotEmpty == true) {
          logic.modifyOrder(index: index, refresh: () => _refreshOrder());
        } else {
          showSnackBar(
            message: 'sap_ink_color_matching_no_color'.tr,
            isWarning: true,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.only(left: 7, top: 10, right: 7, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          expandedTextSpan(
                            flex: 3,
                            hint: 'sap_ink_color_matching_type_body'.tr,
                            text: data.typeBody ?? '',
                            textColor: Colors.green.shade700,
                          ),
                          expandedTextSpan(
                            flex: 3,
                            hint: 'sap_ink_color_matching_factory'.tr,
                            text: data.factoryName ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 5,
                            hint: 'sap_ink_color_matching_remarks'.tr,
                            text: data.remarks ?? '',
                            isBold: false,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            flex: 3,
                            hint: 'sap_ink_color_matching_inkmaster'.tr,
                            text: data.inkMaster ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 3,
                            hint: 'sap_ink_color_matching_toning_order'.tr,
                            text: data.orderNumber ?? '',
                            textColor: Colors.green.shade700,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 3,
                            hint: 'sap_ink_color_matching_toning_date'.tr,
                            text: data.mixDate ?? '',
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                          expandedTextSpan(
                            flex: 2,
                            hint: 'sap_ink_color_matching_mix_weight'.tr,
                            text: 'sap_ink_color_matching_kg_unit'.trArgs([
                              data.mixtureWeight.toFixed(4).toShowString(),
                            ]),
                            textColor: Colors.black87,
                            isBold: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if ((data.trialQty ?? 0) == 0)
                  CombinationButton(
                    text: 'sap_ink_color_matching_trial_completed'.tr,
                    click: () => trialFinishDialog(
                      typeBody: data.typeBody ?? '',
                      orderNumber: data.orderNumber ?? '',
                      mixWeight: data.mixtureWeight ?? 0,
                      refresh: () => _refreshOrder(),
                    ),
                  )
              ],
            ),
            if ((data.trialQty ?? 0) > 0) ...[
              const Divider(indent: 10, endIndent: 10),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    expandedTextSpan(
                      hint: 'sap_ink_color_matching_trial_qty'.tr,
                      text: 'sap_ink_color_matching_pair_unit'.trArgs([
                        data.trialQty.toFixed(4).toShowString(),
                      ]),
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: 'sap_ink_color_matching_mix_trial_weight'.tr,
                      text: 'sap_ink_color_matching_kg_unit'.trArgs([
                        data.mixtureTheoreticalWeight.toFixed(4).toShowString(),
                      ]),
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: 'sap_ink_color_matching_loss'.tr,
                      text: '${data.loss.toFixed(4).toShowString()}%',
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                    expandedTextSpan(
                      hint: 'sap_ink_color_matching_usage'.tr,
                      text: data.unitUsage.toMaxString(),
                      textColor: Colors.black87,
                      isBold: false,
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  _refreshOrder() {
    logic.queryOrder(
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      typeBody: tecTypeBody.text,
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshOrder();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithDrawer(
      actions: [
        Container(
          width: 300,
          margin: const EdgeInsets.all(5),
          height: 40,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 0,
                bottom: 0,
                left: 15,
                right: 10,
              ),
              filled: true,
              fillColor: Colors.grey[300],
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              hintText: 'sap_ink_color_matching_type_body_tips'.tr,
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: IconButton(
                onPressed: () => controller.clear(),
                icon: const Icon(
                  Icons.replay_circle_filled,
                  color: Colors.red,
                ),
              ),
              suffixIcon: CombinationButton(
                text: 'sap_ink_color_matching_new_toning_order'.tr,
                click: () => logic.createMixOrder(
                  newTypeBody: controller.text,
                  refresh: () {
                    hidKeyboard();
                    controller.clear();
                    _refreshOrder();
                  },
                ),
              ),
            ),
          ),
        )
      ],
      queryWidgets: [
        EditText(
          hint: 'sap_ink_color_matching_input_type_body'.tr,
          controller: tecTypeBody,
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        Obx(() => SwitchButton(
              onChanged: (s) {
                state.idTested.value = s;
                spSave('${Get.currentRoute}/idTested', s);
              },
              name: 'sap_ink_color_matching_trial_completed'.tr,
              value: state.idTested.value,
            ))
      ],
      query: () =>_refreshOrder(),
      body: Obx(() => ListView.builder(
            itemCount: state.orderList.length,
            itemBuilder: (c, i) => _item(i),
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapInkColorMatchingLogic>();
    super.dispose();
  }
}
