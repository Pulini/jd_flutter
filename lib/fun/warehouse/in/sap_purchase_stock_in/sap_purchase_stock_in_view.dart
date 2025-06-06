import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';
import 'package:jd_flutter/widget/switch_button_widget.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import 'sap_purchase_stock_in_logic.dart';
import 'sap_purchase_stock_in_state.dart';

class SapPurchaseStockInPage extends StatefulWidget {
  const SapPurchaseStockInPage({super.key});

  @override
  State<SapPurchaseStockInPage> createState() => _SapPurchaseStockInPageState();
}

class _SapPurchaseStockInPageState extends State<SapPurchaseStockInPage> {
  final SapPurchaseStockInLogic logic = Get.put(SapPurchaseStockInLogic());
  final SapPurchaseStockInState state =
      Get.find<SapPurchaseStockInLogic>().state;

  var deliveryOrderController = TextEditingController();

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.sapPurchaseStockIn.name}${PickerType.startDate}',
  );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapPurchaseStockIn.name}${PickerType.endDate}',
  );

  var companyController = OptionsPickerController(
    PickerType.sapCompany,
    saveKey: '${RouteConfig.sapPurchaseStockIn.name}${PickerType.sapCompany}',
  );
  var factoryWarehouseController = LinkOptionsPickerController(
    PickerType.sapFactoryWarehouse,
    hasAll: true,
    saveKey:
        '${RouteConfig.sapPurchaseStockIn.name}${PickerType.sapFactoryWarehouse}',
  );
  var supplierController = OptionsPickerController(
    hasAll: true,
    PickerType.sapSupplier,
    saveKey: '${RouteConfig.sapPurchaseStockIn.name}${PickerType.sapSupplier}',
  );

  _item(int index) {
    var list = state.orderList[index];
    var materialList = <List<SapPurchaseStockInInfo>>[];
    groupBy(list, (v) => v.materialCode).forEach((k, v) {
      materialList.add(v);
    });
    return Obx(() => GestureDetector(
          onTap: () {
            state.selectedList[index] = !state.selectedList[index];
          },
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 10),
            padding: const EdgeInsets.only(left: 4, right: 4),
            decoration: BoxDecoration(
              color: state.selectedList[index]
                  ? Colors.blue.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: state.selectedList[index]
                  ? Border.all(color: Colors.green, width: 2)
                  : Border.all(color: Colors.white, width: 2),
            ),
            foregroundDecoration: list[0].isGenerate?.isNotEmpty == true ||
                    list[0].inspector?.isNotEmpty == true
                ? RotatedCornerDecoration.withColor(
                    color: Colors.green,
                    badgeCornerRadius: const Radius.circular(8),
                    badgeSize: const Size(45, 45),
                    textSpan: TextSpan(
                      text: list[0].isGenerate?.isNotEmpty == true
                          ? 'sap_purchase_stock_in_temporarily_received'.tr
                          : 'sap_purchase_stock_in_inventoried'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  )
                : null,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    expandedTextSpan(
                      hint: 'sap_purchase_stock_in_supplier'.tr,
                      text: list[0].supplierName ?? '',
                      textColor: Colors.red,
                    ),
                    textSpan(
                      hint: 'sap_purchase_stock_in_piece_qty'.tr,
                      isBold: false,
                      text: list
                          .map((v) => v.numPage ?? 0)
                          .reduce((a, b) => a + b)
                          .toString(),
                    ),
                    if (list[0].isGenerate?.isNotEmpty == true ||
                        list[0].inspector?.isNotEmpty == true)
                      const SizedBox(width: 30),
                  ],
                ),
                Row(
                  children: [
                    expandedTextSpan(
                      hint: 'sap_purchase_stock_in_delivery_no'.tr,
                      text: list[0].deliveryNumber ?? '',
                      isBold: false,
                      textColor: Colors.grey.shade700,
                      hintColor: Colors.grey.shade700,
                    ),
                    if (list[0].isExempt == 'X')
                      Text(
                        'sap_purchase_stock_in_exempt_inspection'.tr,
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                  ],
                ),
                textSpan(
                  hint: 'sap_purchase_stock_in_remake'.tr,
                  text: list[0].remarks ?? '',
                  isBold: false,
                  textColor: Colors.grey.shade700,
                  hintColor: Colors.grey.shade700,
                ),
                const Divider(
                  indent: 5,
                  endIndent: 5,
                  height: 10,
                  color: Colors.black,
                ),
                for (var item in materialList) ..._subItem(item),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(7),
                          ),
                        ),
                      ),
                      onPressed: () => logic.checkOrder(
                        index: index,
                        list: list[0],
                        refresh: () => logic.queryOrder(
                          deliNo: deliveryOrderController.text,
                          startDate: dpcStartDate.getDateFormatSapYMD(),
                          endDate: dpcEndDate.getDateFormatSapYMD(),
                          factory: factoryWarehouseController
                              .getPickItem1()
                              .pickerId(),
                          warehouse: factoryWarehouseController
                              .getPickItem2()
                              .pickerId(),
                          supplier: supplierController.selectedId.value,
                          company: companyController.selectedId.value,
                        ),
                      ),
                      child: Text(
                        'sap_purchase_stock_in_check'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 1),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        overlayColor: Colors.white,
                        backgroundColor: Colors.blueAccent,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(7),
                          ),
                        ),
                      ),
                      onPressed: () => logic.queryDetail(
                        index,
                        list[0].deliveryNumber ?? '',
                      ),
                      child: Text(
                        'sap_purchase_stock_in_details'.tr,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ])
              ],
            ),
          ),
        ));
  }

  List<Widget> _subItem(List<SapPurchaseStockInInfo> list) {
    return [
      list[0].basicUnit == list[0].commonUnits
          ? Row(
              children: [
                expandedTextSpan(
                  hint: 'sap_purchase_stock_in_material'.tr,
                  text:
                      '(${list[0].materialCode})${list[0].materialDescription}',
                ),
                textSpan(
                  hint: 'sap_purchase_stock_in_unit'.tr,
                  text: list[0].basicUnit ?? '',
                )
              ],
            )
          : textSpan(
              hint: 'sap_purchase_stock_in_material'.tr,
              text: '(${list[0].materialCode})${list[0].materialDescription}',
            ),
      if (list[0].basicUnit != list[0].commonUnits)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textSpan(
              hint: 'sap_purchase_stock_in_basic_unit'.tr,
              text: list[0].basicUnit ?? '',
            ),
            textSpan(
              hint: 'sap_purchase_stock_in_coefficient'.tr,
              text: '${list[0].coefficient ?? 0}',
            ),
            textSpan(
              hint: 'sap_purchase_stock_in_common_units'.tr,
              text: list[0].commonUnits ?? '',
            ),
          ],
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'sap_purchase_stock_in_check_situation'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: progressIndicator(
              max: list.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
              value:
                  list.map((v) => v.checkQty ?? 0).reduce((a, b) => a.add(b)),
            ),
          ),
        ],
      ),
      const Divider(
        indent: 5,
        endIndent: 5,
        height: 10,
        color: Colors.black,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          hint: 'sap_purchase_stock_in_delivery_no'.tr,
          controller: deliveryOrderController,
        ),
        Row(
          children: [
            Expanded(child: DatePicker(pickerController: dpcStartDate)),
            Expanded(child: DatePicker(pickerController: dpcEndDate)),
          ],
        ),
        OptionsPicker(pickerController: companyController),
        LinkOptionsPicker(pickerController: factoryWarehouseController),
        OptionsPicker(pickerController: supplierController),
        Obx(() => Row(
              children: [
                Expanded(
                  child: SwitchButton(
                    onChanged: (s) => state.warehoused.value = s,
                    name: 'sap_purchase_stock_in_already_stock_in'.tr,
                    value: state.warehoused.value,
                  ),
                ),
                Expanded(
                  child: SwitchButton(
                    onChanged: (s) => state.generated.value = s,
                    name: 'sap_purchase_stock_in_temporarily_received'.tr,
                    value: state.generated.value,
                  ),
                ),
              ],
            )),
      ],
      query: () => queryOrder(),
      body: Obx(() => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.orderList.length,
                  itemBuilder: (c, i) => _item(i),
                ),
              ),
              if (state.selectedList.any((v) => v))
                Row(
                  children: [
                    Expanded(
                      child: CombinationButton(
                        text: 'sap_purchase_stock_in_stock_in'.tr,
                        click: () => stockInDialog(
                          list: logic.getSelected(),
                          refresh: queryOrder,
                        ),
                        combination: Combination.left,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'sap_purchase_stock_in_stock_in_reversal'.tr,
                        click: () => logic.checkStockInWriteOffSelected(
                          (list) => stockInWriteOffDialog(
                            list: list,
                            refresh: queryOrder,
                          ),
                        ),
                        combination: Combination.middle,
                      ),
                    ),
                    Expanded(
                      child: CombinationButton(
                        text: 'sap_purchase_stock_in_temporarily_receive'.tr,
                        click: () => logic.checkTemporarySelected(
                          (list) => temporaryDialog(
                            list: list,
                            refresh: queryOrder,
                          ),
                        ),
                        combination: Combination.right,
                      ),
                    ),
                  ],
                )
            ],
          )),
    );
  }

  queryOrder() {
    logic.queryOrder(
      deliNo: deliveryOrderController.text,
      startDate: dpcStartDate.getDateFormatSapYMD(),
      endDate: dpcEndDate.getDateFormatSapYMD(),
      factory: factoryWarehouseController.getPickItem1().pickerId(),
      warehouse: factoryWarehouseController.getPickItem2().pickerId(),
      supplier: supplierController.selectedId.value,
      company: companyController.selectedId.value,
    );
  }

  @override
  void dispose() {
    Get.delete<SapPurchaseStockInLogic>();
    super.dispose();
  }
}
