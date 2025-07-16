import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/temporary_order_info.dart';
import 'package:jd_flutter/fun/warehouse/in/stuff_quality_inspection/stuff_quality_inspection_view.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_dialog.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/temporary_order/temporary_order_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/check_box_widget.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class TemporaryOrderDetailPage extends StatefulWidget {
  const TemporaryOrderDetailPage({super.key});

  @override
  State<TemporaryOrderDetailPage> createState() =>
      _TemporaryOrderDetailPageState();
}

class _TemporaryOrderDetailPageState extends State<TemporaryOrderDetailPage> {
  final TemporaryOrderLogic logic = Get.find<TemporaryOrderLogic>();
  final TemporaryOrderState state = Get.find<TemporaryOrderLogic>().state;
  var titleTextStyle =
  const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold);
  var itemTextStyle = const TextStyle(color: Colors.black54);

  Widget _item(TemporaryOrderDetailReceiptInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    expandedTextSpan(
                      flex: 4,
                      hint: 'temporary_order_detail_material'.tr,
                      text: '(${data.materialCode})${data.materialName}',
                    ),
                    expandedTextSpan(
                      hint: 'temporary_order_detail_test_status'.tr,
                      text: data.getTestStateText(),
                      textColor: data.getTestStateColor(),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _itemText('temporary_order_detail_type_body'.trArgs(
                      ['${data.factoryModel}'],
                    )),
                    _itemText('temporary_order_detail_production_no'.trArgs(
                      ['${data.productionNumber}'],
                    )),
                    _itemText('temporary_order_detail_size'.trArgs(
                      ['${data.size}'],
                    )),
                    _itemText('temporary_order_detail_delivery_date'.trArgs(
                      ['${data.deliveryDate}'],
                    )),
                    _itemText('temporary_order_detail_received_qty'.trArgs(
                      ['${data.quantityTemporarilyReceived}'],
                    )),
                  ],
                ),
                Row(
                  children: [
                    _itemText('temporary_order_detail_basic_qty'.trArgs(
                      [data.basicQuantity.toShowString()],
                    )),
                    _itemText('temporary_order_detail_inspection_qty'.trArgs(
                      [data.inspectionQuantity.toShowString()],
                    )),
                    _itemText('temporary_order_detail_qualified_qty'.trArgs(
                      [data.qualifiedQuantity.toShowString()],
                    )),
                    _itemText('temporary_order_detail_unqualified_qty'.trArgs(
                      [data.unqualifiedQuantity.toShowString()],
                    )),
                    _itemText('temporary_order_detail_missing_qty'.trArgs(
                      [data.missingQuantity.toShowString()],
                    )),
                  ],
                ),
                Row(
                  children: [
                    _itemText('temporary_order_detail_warehouse_in_qty'.trArgs(
                      [data.enterWarehouseQuantity.toShowString()],
                    )),
                    _itemText('temporary_order_detail_common_unit'.trArgs(
                      ['${data.commonUnits}'],
                    )),
                    _itemText('temporary_order_detail_coefficient'.trArgs(
                      [data.coefficient.toShowString()],
                    )),
                    _itemText('temporary_order_detail_basic_unit'.trArgs(
                      ['${data.basicUnits}'],
                    )),
                    _itemText('temporary_order_detail_specification'.trArgs(
                      ['${data.specification}'],
                    )),
                  ],
                ),
                Row(
                  children: [
                    _itemText('temporary_order_detail_contract_no'.trArgs(
                      ['${data.contractNo}'],
                    )),
                    _itemText(
                        'temporary_order_detail_purchase_order_line_no'.trArgs(
                          ['${data.purchaseOrderLineNumber}'],
                        )),
                    _itemText(
                        'temporary_order_detail_delivery_order_line_no'.trArgs(
                          ['${data.deliveryOrderLineNumber}'],
                        )),
                    _itemText('temporary_order_detail_purchase_type'.trArgs(
                      ['${data.purchaseType}'],
                    )),
                    _itemText('temporary_order_detail_remark'.trArgs(
                      ['${data.remarks}'],
                    )),
                  ],
                ),
              ],
            ),
          ),
          Obx(() => (data.quantityTemporarilyReceived ?? 0) > 0
              ? Checkbox(
            value: data.isSelected.value,
            onChanged: (v) {
              data.isSelected.value = v!;
            },
          )
              : Container())
        ],
      ),
    );
  }

  _itemText(String text) => Expanded(child: Text(text, style: itemTextStyle));

  _titleText(String text) => Expanded(child: Text(text, style: titleTextStyle));

  @override
  Widget build(BuildContext context) {
    var detail = state.detailInfo!;
    var itemCanSelect =
    detail.receipt!.any((v) => (v.quantityTemporarilyReceived ?? 0) > 0);
    return pageBody(
      title: 'temporary_order_detail_temporary_order_detail'.tr,
      actions: [
        if (itemCanSelect)
          Obx(() => CombinationButton(
            combination: Combination.left,
            isEnabled: detail.receipt!.any((v) => v.isSelected.value),
            text: 'temporary_order_detail_test_application'.tr,
            click: () => testApplicationDialog(
              temporaryOrderNumber: detail.temporaryNumber ?? '',
              selectedList:
              detail.receipt!.where((v) => v.isSelected.value).toList(),
            ),
          )),
        if (itemCanSelect)
          Obx(() => CombinationButton(
              combination: Combination.right,
              isEnabled: detail.receipt!.any((v) => v.isSelected.value),
              text: 'temporary_order_detail_inspection'.tr,
              click: () {
                if (checkUserPermission('105180501')) {
                  if (logic.checkToInspection()) {
                    Get.to(() => const StuffQualityInspectionPage(),
                        arguments: {
                          'inspectionType': '2',
                          'temporaryDetail':
                          jsonEncode(state.detailInfo!.toJson()),
                          //品检单列表
                        })?.then((v) {
                      if (v == true) {
                        Get.back(result: true); //结束界面
                      }
                    });
                  }
                } else {
                  errorDialog(
                    content: 'temporary_order_detail_no_permission'.tr,
                  );
                }
              })),
        const SizedBox(width: 10)
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Row(
              children: [
                _titleText(
                  'temporary_order_detail_company'.trArgs(
                    ['${detail.companyName}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_producer'.trArgs(
                    ['${detail.producerNumber}) ${detail.producerName}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_producer_date'.trArgs(
                    ['${detail.producerDate}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_temporary_no'.trArgs(
                    ['${detail.temporaryNumber}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_storage_location'.trArgs(
                    ['${detail.storageLocationName}'],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _titleText(
                  'temporary_order_detail_temporary_date'.trArgs(
                    ['${detail.temporaryDate}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_supplier'.trArgs(
                    ['${detail.supplierName}'],
                  ),
                ),
                _titleText(
                  'temporary_order_detail_delivery_no'.trArgs(
                    ['${detail.deliveryNumber}'],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    children: [
                      _titleText(
                        'temporary_order_detail_remark'.trArgs(
                          ['${detail.remarks}'],
                        ),
                      ),
                      Obx(() => itemCanSelect
                          ? CheckBox(
                        onChanged: (v) => detail.selectedAll(v),
                        name: 'temporary_order_detail_select_all'.tr,
                        value: detail.isSelectedAll(),
                      )
                          : Container(height: 40))
                    ],
                  ),
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: detail.receipt!.length,
                itemBuilder: (c, i) => _item(detail.receipt![i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
