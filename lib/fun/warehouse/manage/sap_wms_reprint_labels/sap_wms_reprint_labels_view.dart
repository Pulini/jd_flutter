import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_wms_reprint_labels_logic.dart';
import 'sap_wms_reprint_labels_state.dart';

class SapWmsReprintLabelsPage extends StatefulWidget {
  const SapWmsReprintLabelsPage({super.key});

  @override
  State<SapWmsReprintLabelsPage> createState() =>
      _SapWmsReprintLabelsPageState();
}

class _SapWmsReprintLabelsPageState extends State<SapWmsReprintLabelsPage> {
  final SapWmsReprintLabelsLogic logic = Get.put(SapWmsReprintLabelsLogic());
  final SapWmsReprintLabelsState state =
      Get.find<SapWmsReprintLabelsLogic>().state;

  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapWmsReprintLabels.name}${PickerType.sapFactoryWarehouse}',
  );

  @override
  void initState() {
    pdaScanner(
      scan: (code) => logic.scanCode(
        warehouse: factoryWarehouseController.getPickItem2().pickerId(),
        code: code,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        TextButton(
          onPressed: (() => logic.clean()).throttle(),
          child: Text('sap_wms_reprint_label_clean'.tr),
        ),
      ],
      body: Column(
        children: [
          LinkOptionsPicker(pickerController: factoryWarehouseController),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Row(
              children: [
                Obx(() => expandedTextSpan(
                      hint: 'sap_wms_reprint_label_pallet_no'.tr,
                      text: state.palletNumber.value,
                    )),
                Obx(() => Checkbox(
                      value: state.labelList.isNotEmpty &&
                          state.labelList.every((v) => v.select),
                      onChanged: (c) {
                        for (var v in state.labelList) {
                          v.select = c!;
                        }
                        state.labelList.refresh();
                      },
                    )),
              ],
            ),
          ),
          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.only(left: 8, right: 8),
                itemCount: state.labelList.length,
                itemBuilder: (c, i) => _ReprintLabelItem(
                  label: state.labelList[i],
                  onTap: () => setState(
                    () => state.labelList[i].select =
                        !state.labelList[i].select,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: CombinationButton(
              text: 'sap_wms_reprint_label_reprint_label'.tr,
              click: () {
                // logic.scanCode(
                //   warehouse:
                //       factoryWarehouseController.getOptionsPicker2().pickerId(),
                //   code: 'GE10023400',
                // );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<SapWmsReprintLabelsLogic>();
    super.dispose();
  }
}

class _ReprintLabelItem extends StatelessWidget {
  final ReprintLabelInfo label;
  final VoidCallback onTap;

  const _ReprintLabelItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            AutoSizeText(
              label.materialName ?? '',
              style: const TextStyle(color: Colors.red),
              maxLines: 2,
              minFontSize: 8,
              maxFontSize: 18,
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: '标签：',
                  text: label.labelNumber ?? '',
                  isBold: false,
                  textColor: Colors.grey,
                ),
                Text('${label.quantity}${label.unit}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
