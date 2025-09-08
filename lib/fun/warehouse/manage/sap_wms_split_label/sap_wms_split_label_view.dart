import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_wms_split_label_logic.dart';
import 'sap_wms_split_label_state.dart';

class SapWmsSplitLabelPage extends StatefulWidget {
  const SapWmsSplitLabelPage({super.key});

  @override
  State<SapWmsSplitLabelPage> createState() => _SapWmsSplitLabelPageState();
}

class _SapWmsSplitLabelPageState extends State<SapWmsSplitLabelPage> {
  final SapWmsSplitLabelLogic logic = Get.put(SapWmsSplitLabelLogic());
  final SapWmsSplitLabelState state = Get.find<SapWmsSplitLabelLogic>().state;

  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapWmsSplitLabel.name}${PickerType.sapFactoryWarehouse}',
  );
  var controller = TextEditingController();
  var fn = FocusNode();

  Widget _item(ReprintLabelInfo label) {
    return GestureDetector(
        onTap: () {
          if (label.isNewLabel == 'X') {
            setState(() => label.select = !label.select);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: label.select ? Colors.blue.shade100 : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: label.select
                ? Border.all(color: Colors.green, width: 2)
                : Border.all(color: Colors.white, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  expandedTextSpan(
                    hint: 'sap_wms_split_label_material'.tr,
                    text: '(${label.materialCode})${label.materialName}',
                    textColor: Colors.green.shade900,
                    maxLines: 2,
                  ),
                  Checkbox(
                    value: label.select,
                    onChanged: (c) =>
                        setState(() => label.select = !label.select),
                  )
                ],
              ),
              textSpan(hint: 'sap_wms_split_label_type_body'.tr, text: label.typeBody ?? ''),
              const Divider(indent: 10, endIndent: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  textSpan(
                    hint: 'sap_wms_split_label_size'.tr,
                    text: label.size ?? '',
                    textColor: Colors.green.shade900,
                  ),
                  textSpan(
                    hint: '数量：',
                    text: '${label.quantity.toShowString()} ${label.unit}',
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  _originalLabelItem() {
    if (state.hasOriginalLabel.value) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue.shade200, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: 'sap_wms_split_label_material'.tr,
              text:
                  '(${state.originalLabel!.materialCode})${state.originalLabel!.materialName}',
              textColor: Colors.green.shade900,
              maxLines: 2,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_wms_split_label_type_body'.tr,
                  text: state.originalLabel!.typeBody ?? '',
                  maxLines: 2,
                ),
                if (state.originalLabel!.size?.isNotEmpty == true)
                  textSpan(
                    hint: 'sap_wms_split_label_size'.tr,
                    text: state.originalLabel!.size ?? '',
                    textColor: Colors.green.shade900,
                  ),
              ],
            ),
            const Divider(),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  textSpan(
                    hint: 'sap_wms_split_label_split_qty'.tr,
                    text:
                        '${state.originalLabel!.quantity.toShowString()} ${state.originalLabel!.unit}',
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: TextField(
                      focusNode: fn,
                      onSubmitted: (value) => split(),
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp("[0-9.]"))
                      ],
                      onChanged: (c) {
                        if (c.toDoubleTry() >
                            (state.originalLabel!.quantity ?? 0)) {
                          controller.text = (state.originalLabel!.quantity ?? 0)
                              .toShowString();
                        }
                      },
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
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.blue, width: 2),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        hintStyle: const TextStyle(color: Colors.white),
                        suffixIcon: CombinationButton(
                          text: '拆出',
                          click: () => split(),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  split() {
    hidKeyboard();
    logic.split(
      splitQty: controller.text.toDoubleTry(),
      input: () => fn.requestFocus(),
      finish: () => controller.text = '',
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) {
      hidKeyboard();
      logic.scanCode(code);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: () => askDialog(
            content: 'sap_wms_split_label_submit_split_info_tips'.tr,
            confirm: () => logic.submitSplit(),
          ),
          child: Text('sap_wms_split_label_submit'.tr),
        ),
      ],
      body: Column(
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Expanded(
            child: Obx(() => ListView(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  children: [
                    _originalLabelItem(),
                    for (var item
                        in state.labelList.where((v) => v.isNewLabel == 'X'))
                      _item(item)
                  ],
                )),
          ),
          Row(
            children: [
              Expanded(
                child: CombinationButton(
                  text: 'sap_wms_split_label_delete_label'.tr,
                  click: () => logic.deleteLabel(),
                  combination: Combination.left,
                ),
              ),
              Expanded(
                child: CombinationButton(
                  text: 'sap_wms_split_label_reprint_label'.tr,
                  click: () => logic.reprintLabel(
                    factory: factoryWarehouseController
                        .getPickItem1()
                        .pickerId(),
                    warehouse: factoryWarehouseController
                        .getPickItem2()
                        .pickerId(),
                  ),
                  combination: Combination.right,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapWmsSplitLabelLogic>();
    super.dispose();
  }
}
