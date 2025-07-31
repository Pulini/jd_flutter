import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/manage/sap_factory_inventory/sap_scan_code_inventory_detail_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';
import 'package:jd_flutter/widget/signature_page.dart';

import 'sap_factory_inventory_logic.dart';
import 'sap_factory_inventory_state.dart';

class SapScanCodeInventoryPage extends StatefulWidget {
  const SapScanCodeInventoryPage({super.key});

  @override
  State<SapScanCodeInventoryPage> createState() =>
      _SapScanCodeInventoryPageState();
}

class _SapScanCodeInventoryPageState extends State<SapScanCodeInventoryPage> {
  final SapScanCodeInventoryLogic logic = Get.put(SapScanCodeInventoryLogic());
  final SapScanCodeInventoryState state =
      Get.find<SapScanCodeInventoryLogic>().state;
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapScanCodeInventory.name}${PickerType.sapFactoryWarehouse}',
  );
  var tecArea = TextEditingController();

  _item(int index) {
    var data = state.palletList[index];
    var width = MediaQuery.of(context).size.width - 20;
    bool isScannedAll = data.every((v) => v.isSelected.value);
    int scanned = data.where((v) => v.isSelected.value).length;
    return Column(
      children: [
        InkWell(
          onTap: () => Get.to(
            () => const SapScanCodeInventoryDetailPage(),
            arguments: {'index': index},
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
            ),
            child: Row(
              children: [
                expandedTextSpan(
                  flex: 2,
                  hint: 'sap_inventory_pallet'.tr,
                  isBold: isScannedAll,
                  text: data[0].palletNumber ?? '',
                  textColor: Colors.green.shade700,
                ),
                expandedTextSpan(
                  hint: 'sap_inventory_label_qty'.tr,
                  isBold: isScannedAll,
                  text: data.length.toString(),
                  textColor: isScannedAll ? Colors.blue : Colors.black87,
                ),
                expandedTextSpan(
                  hint: 'sap_inventory_inventory_qty'.tr,
                  isBold: isScannedAll,
                  text: scanned.toString(),
                  textColor: isScannedAll ? Colors.blue : Colors.red,
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            AnimatedContainer(
              margin: const EdgeInsets.only(bottom: 10),
              height: 5,
              width: width * (scanned / data.length),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(5),
                  bottomRight:
                      isScannedAll ? const Radius.circular(5) : Radius.zero,
                ),
                color: Colors.blue,
              ),
            ),
            AnimatedContainer(
              margin: const EdgeInsets.only(bottom: 10),
              height: 5,
              width: width * ((data.length - scanned) / data.length),
              curve: Curves.easeInOut,
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft:
                      scanned == 0 ? const Radius.circular(5) : Radius.zero,
                  bottomRight: const Radius.circular(5),
                ),
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  _queryOrder() {
    logic.queryInventoryOrder(
      isScan: true,
      factory: factoryWarehouseController.getPickItem1().pickerId(),
      warehouse: factoryWarehouseController.getPickItem2().pickerId(),
      area: tecArea.text,
    );
  }

  @override
  void initState() {
    pdaScanner(scan: (code) => logic.scanCode(code));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          hint: 'sap_inventory_area'.tr,
          controller: tecArea,
        ),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
        Row(
          children: [
            Expanded(
              child: Obx(() => RadioListTile(
                    title: Text('sap_inventory_null'.tr),
                    value: '',
                    groupValue: state.orderType.value,
                    onChanged: (v) => state.orderType.value = v!,
                  )),
            ),
            Expanded(
              child: Obx(() => RadioListTile(
                    title: Text('sap_inventory_first_count'.tr),
                    value: '10',
                    groupValue: state.orderType.value,
                    onChanged: (v) => state.orderType.value = v!,
                  )),
            ),
            Expanded(
              child: Obx(() => RadioListTile(
                    title: Text('sap_inventory_second_count'.tr),
                    value: '11',
                    groupValue: state.orderType.value,
                    onChanged: (v) => state.orderType.value = v!,
                  )),
            ),
          ],
        )
      ],
      query: () => _queryOrder(),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: state.palletList.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (c, i) => _item(i),
                )),
          ),
          Obx(() => state.palletList
                  .every((v) => v.every((v2) => !v2.isSelected.value))
              ? Container()
              : SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: 'sap_inventory_submit'.tr,
                    click: () => Get.to(
                      () => SignatureWithWorkerNumberPage(
                        hint: 'sap_inventory_worker_number'.tr,
                        callback: (worker, image) => logic.submitScanInventory(
                          workerInfo: worker,
                          signature: image,
                          finish: () => _queryOrder(),
                        ),
                      ),
                    ),
                  ),
                ))
        ],
      ),
      // body: AnimatedFlexExample()
    );
  }

  @override
  void dispose() {
    Get.delete<SapScanCodeInventoryLogic>();
    super.dispose();
  }
}
