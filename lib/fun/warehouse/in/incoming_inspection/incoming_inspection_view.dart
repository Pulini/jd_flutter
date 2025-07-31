import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/incoming_inspection_info.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/incoming_inspection/incoming_inspection_orders_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'incoming_inspection_logic.dart';
import 'incoming_inspection_state.dart';

class IncomingInspectionPage extends StatefulWidget {
  const IncomingInspectionPage({super.key});

  @override
  State<IncomingInspectionPage> createState() => _IncomingInspectionPageState();
}

class _IncomingInspectionPageState extends State<IncomingInspectionPage> {
  final IncomingInspectionLogic logic = Get.put(IncomingInspectionLogic());
  final IncomingInspectionState state =
      Get.find<IncomingInspectionLogic>().state;
  var controller = TextEditingController();
  late Widget searchSheet;
  var companyController = OptionsPickerController(
    PickerType.sapCompany,
    saveKey: '${RouteConfig.incomingInspection.name}${PickerType.sapCompany}',
  );
  var factoryController = OptionsPickerController(
    PickerType.sapFactory,
    saveKey: '${RouteConfig.incomingInspection.name}${PickerType.sapFactory}',
  );
  var supplierController = OptionsPickerController(
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.incomingInspection.name}${PickerType.sapSupplier}',
  );
  var tecDeliveryNo=TextEditingController();
  var tecMaterialCode=TextEditingController();

  Widget _deliveryItem(List<List<InspectionDeliveryInfo>> group) {
    var orderTotalNumPage = group
        .map((v) => v.map((v2) => v2.numPage ?? 0).reduce((a, b) => a + b))
        .reduce((a, b) => a + b);

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: textSpan(
          hint: 'incoming_inspection_order_no'.tr,
          text: group[0][0].billNo ?? '',
          textColor: Colors.green,
        ),
        subtitle: textSpan(
          hint: 'incoming_inspection_delivery_qty'.tr,
          text: 'incoming_inspection_delivery_detail'.trArgs([
            orderTotalNumPage.toString(),
            group[0][0].numPage.toString(),
            group[0][0].unitName ?? '',
          ]),
          textColor: Colors.green,
        ),
        leading: IconButton(
          onPressed: () => askDialog(
            content: 'incoming_inspection_delete_order_tips'.tr,
            confirm: () => logic.deleteDeliveryOrder(group),
          ),
          icon: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
        ),
        children: [for (var item in group) _subItem(item)],
      ),
    );
  }

  Widget _subItem(List<InspectionDeliveryInfo> item) {
    var materialGroupQty =
        item.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)).toShowString();

    var materialGroupNumPage =
        item.map((v) => v.numPage ?? 0).reduce((a, b) => a + b);

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade50,
            Colors.blue.shade100,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        // color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: ExpansionTile(
        backgroundColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        title: textSpan(
          maxLines: 2,
          hint: 'incoming_inspection_material'.tr,
          text: '(${item[0].materialCode}) ${item[0].materialName}'
              .allowWordTruncation(),
        ),
        subtitle: textSpan(
          hint: 'incoming_inspection_material_delivery_qty'.tr,
          text: 'incoming_inspection_delivery_detail'.trArgs([
            materialGroupNumPage.toString(),
            materialGroupQty.toString(),
            item[0].unitName ?? '',
          ]),
        ),
        leading: IconButton(
          onPressed: () => askDialog(
            content: 'incoming_inspection_delete_material_tips'.tr,
            confirm: () => logic.deleteDeliveryMaterialGroupOrder(item),
          ),
          icon: const Icon(
            Icons.delete_forever,
            color: Colors.red,
          ),
        ),
        children: [
          for (var subItem in item)
            Column(
              children: [
                const Divider(indent: 10, endIndent: 10),
                InkWell(
                  onTap: () => modifySubItemMaterialDialog(
                      item: subItem, modify: () => logic.modify()),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Expanded(
                        child: textSpan(
                          hint: 'incoming_inspection_detail_delivery_qty'.tr,
                          text: 'incoming_inspection_delivery_detail'.trArgs([
                            subItem.numPage.toString(),
                            subItem.qty.toShowString(),
                            subItem.unitName ?? '',
                          ]),
                          textColor: Colors.black54,
                        ),
                      ),
                      IconButton(
                        onPressed: () => askDialog(
                          content: 'incoming_inspection_delete_item_tips'.tr,
                          confirm: () => logic.deleteDeliveryItem(subItem),
                        ),
                        icon: const Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
        ],
      ),
    );
  }

  Widget _addMaterialItem(InspectionDeliveryInfo item) {
    return InkWell(
      onTap: () => addOrModifyMaterialDialog(
        item: item,
        modify: () => logic.modifyMaterialItem(),
      ),
      child: Container(
        padding: const EdgeInsets.all(5),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade50,
              Colors.blue.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          // color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.blue, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textSpan(
              hint: 'incoming_inspection_material'.tr,
              text: item.materialName.allowWordTruncation(),
              maxLines: 3,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textSpan(
                        hint: 'incoming_inspection_order_no'.tr,
                        text: item.billNo ?? '',
                        textColor: Colors.black54,
                      ),
                      textSpan(
                        hint: 'incoming_inspection_delivery_detail_tips'.tr,
                        text: 'incoming_inspection_delivery_detail'.trArgs([
                          item.numPage.toString(),
                          item.qty.toShowString(),
                          item.unitName ?? '',
                        ]),
                        textColor: Colors.black54,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => askDialog(
                    content: 'incoming_inspection_delete_item_tips'.tr,
                    confirm: () => logic.deleteMaterialItem(item),
                  ),
                  icon: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget initSearch() => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding:
            const EdgeInsets.only(left: 10, top: 20, right: 10, bottom: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(15),
            topRight: Radius.circular(15),
          ),
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.blue.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: OptionsPicker(pickerController: companyController),
                ),
                Expanded(
                  flex: 3,
                  child: OptionsPicker(pickerController: factoryController),
                ),
              ],
            ),
            OptionsPicker(pickerController: supplierController),
            EditText(
              controller: tecDeliveryNo,
              hint: 'incoming_inspection_delivery_no'.tr,
            ),
            EditText(
              controller: tecMaterialCode,
              hint: 'incoming_inspection_material_code'.tr,
            ),
            Expanded(child: Container()),
            Row(
              children: [
                Expanded(
                  child: CombinationButton(
                    combination: Combination.left,
                    text: 'incoming_inspection_scan_order'.tr,
                    click: () => scannerDialog(
                      detect: (code) => logic.scanOrder(
                        deliveryNo:tecDeliveryNo.text,
                        materialCode:tecMaterialCode.text,
                        code: code,
                        success: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: CombinationButton(
                    combination: Combination.right,
                    text: 'incoming_inspection_query_delivery'.tr,
                    click: () => logic.query(
                      area: companyController.selectedId.value,
                      factory: factoryController.selectedId.value,
                      supplier: supplierController.selectedId.value,
                      deliveryNo:tecDeliveryNo.text,
                      materialCode:tecMaterialCode.text,
                      success: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      searchSheet = initSearch();
    });
    super.initState();
  }

  _showSearch() {
    showSheet(
      bodyPadding: const EdgeInsets.all(0),
      context: context,
      body: searchSheet,
      scrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      actions: [
        IconButton(
          onPressed:() =>_showSearch(),
          icon: const Icon(Icons.search),
        ),
        IconButton(
          onPressed: () => Get.to(() => const IncomingInspectionOrdersPage()),
          icon: const Icon(Icons.menu),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
                  children: [
                    for (var item in state.deliveryList) _deliveryItem(item),
                    for (var item in state.addMaterialList)
                      _addMaterialItem(item),
                  ],
                )),
          ),
          Container(
            padding: const EdgeInsets.only(left: 5, right: 5),
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                overlayColor: Colors.white,
                backgroundColor: Colors.green,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
              ),
              onPressed: () => addOrModifyMaterialDialog(
                add: (item) => logic.addMaterialItem(item),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Obx(() => CombinationButton(
                      text: 'incoming_inspection_clean_delivery'.tr,
                      combination: Combination.left,
                      isEnabled: state.deliveryList.isNotEmpty ||
                          state.addMaterialList.isNotEmpty,
                      click: () => askDialog(
                        content: 'incoming_inspection_clean_delivery_tips'.tr,
                        confirm: () => logic.cleanDelivery(),
                      ),
                    )),
              ),
              Expanded(
                child: Obx(() => CombinationButton(
                      text: 'incoming_inspection_apply_inspection'.tr,
                      combination: Combination.right,
                      isEnabled: state.deliveryList.isNotEmpty ||
                          state.addMaterialList.isNotEmpty,
                      click: () => applyInspectionDialog(
                        submit: (worker) => logic.applyInspection(worker),
                      ),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<IncomingInspectionLogic>();
    super.dispose();
  }
}
