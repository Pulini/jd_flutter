import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_wms_reprint_label_info.dart';
import 'package:jd_flutter/route.dart';
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

  GestureDetector _item(ReprintLabelInfo label) {
    return GestureDetector(
      onTap: () => setState(() => label.select = !label.select),
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
  /*
  _labelTitle(ReprintLabelInfo label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        right: 3,
      ),
      child: Text(
        label.factory??'',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  _subTitle(ReprintLabelInfo label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        right: 3,
      ),
      child: AutoSizeText(
        label.instructionNo ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        maxLines: 2,
        minFontSize: 12,
        maxFontSize: 36,
      ),
    );
  }

  _tableHeader(ReprintLabelInfo label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3,
        right: 3,
      ),
      child: AutoSizeText(
        label.instructionNo ?? '',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 36,
        ),
        maxLines: 2,
        minFontSize: 12,
        maxFontSize: 36,
      ),
    );
  }



  _previewLabelList() {
    var selected = state.labelList.where((v) => v.select).toList();
    Get.to(() => PreviewLabelList(
          labelWidgets: [
            for (var item in selected)
            dynamicLabelTemplate(
                qrCode: item.labelNumber ?? '',
                title: _labelTitle(item),
                subTitle: _subTitle(item),
               header: _tableHeader(item),
              )
          ],
        ));
  }
*/

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
          onPressed: () => logic.clean(),
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
                itemBuilder: (c, i) => _item(state.labelList[i]),
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
