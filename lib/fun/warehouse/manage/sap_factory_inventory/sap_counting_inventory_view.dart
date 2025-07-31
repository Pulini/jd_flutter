import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_scan_code_inventory_info.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/signature_page.dart';

import 'sap_factory_inventory_logic.dart';
import 'sap_factory_inventory_state.dart';

class SapCountingInventoryPage extends StatefulWidget {
  const SapCountingInventoryPage({super.key});

  @override
  State<SapCountingInventoryPage> createState() =>
      _SapCountingInventoryPageState();
}

class _SapCountingInventoryPageState extends State<SapCountingInventoryPage> {
  final SapScanCodeInventoryLogic logic = Get.put(SapScanCodeInventoryLogic());
  final SapScanCodeInventoryState state =
      Get.find<SapScanCodeInventoryLogic>().state;
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    saveKey:
        '${RouteConfig.sapCountingInventory.name}${PickerType.sapFactoryWarehouse}',
  );

  _item(InventoryPalletInfo data) {
    var width = MediaQuery.of(context).size.width - 20;
    var textButtonPadding =
        const EdgeInsets.only(left: 7, top: 3, right: 7, bottom: 3);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(5),
              topRight: Radius.circular(5),
            ),
          ),
          child: Column(
            children: [
              textSpan(
                hint: 'sap_inventory_material'.tr,
                maxLines: 2,
                text: '(${data.materialCode}) ${data.materialName}',
                textColor: Colors.green.shade700,
              ),
              Row(
                children: [
                  expandedTextSpan(
                    flex: 2,
                    hint: 'sap_inventory_stock_qty'.tr,
                    text: data.getQuantity().toShowString(),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Expanded(
                          child: NumberDecimalEditText(
                            initQty: data.getInventoryQty(),
                            resetQty: data.getQuantity(),
                            onChanged: (v) => data.setInventoryQty(v),
                          ),
                        ),
                        data.basicUnit == data.convertedUnits
                            ? Padding(
                                padding: textButtonPadding,
                                child: Text(
                                  data.getUnit(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  data.isBaseUnit.value =
                                      !data.isBaseUnit.value;
                                },
                                child: Container(
                                  padding: textButtonPadding,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.blue, width: 2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Obx(() => Text(
                                        data.getUnit(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      )),
                                ),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Obx(() => Row(
              children: [
                AnimatedContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 5,
                  width: width * data.getInventoryQtyPercent(),
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: const Radius.circular(5),
                      bottomRight: data.inventoryQty.value >= (data.quantity??0)
                          ? const Radius.circular(5)
                          : Radius.zero,
                    ),
                    color: Colors.blue,
                  ),
                ),
                AnimatedContainer(
                  margin: const EdgeInsets.only(bottom: 10),
                  height: 5,
                  width: width * data.getInventoryQtyOwePercent(),
                  curve: Curves.easeInOut,
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: data.inventoryQty.value == 0
                          ? const Radius.circular(5)
                          : Radius.zero,
                      bottomRight: const Radius.circular(5),
                    ),
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            )),
      ],
    );
  }

  _queryOrder() {
    logic.queryInventoryOrder(
      isScan: false,
      factory: factoryWarehouseController.getPickItem1().pickerId(),
      warehouse: factoryWarehouseController.getPickItem2().pickerId(),
      area: ''
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
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
                  itemCount: state.materialList.length,
                  padding: const EdgeInsets.all(10),
                  itemBuilder: (c, i) => _item(state.materialList[i]),
                )),
          ),
          Obx(() => state.materialList.isEmpty
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
