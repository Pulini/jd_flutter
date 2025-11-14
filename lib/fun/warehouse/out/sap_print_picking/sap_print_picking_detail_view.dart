import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_bar_code_list_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_state.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_print_picking/sap_print_picking_transfer_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/scanner.dart';

class SapPrintPickingDetailPage extends StatefulWidget {
  const SapPrintPickingDetailPage({super.key});

  @override
  State<SapPrintPickingDetailPage> createState() =>
      _SapPrintPickingDetailPageState();
}

class _SapPrintPickingDetailPageState extends State<SapPrintPickingDetailPage> {
  final SapPrintPickingLogic logic = Get.find<SapPrintPickingLogic>();
  final SapPrintPickingState state = Get.find<SapPrintPickingLogic>().state;

  void _scanListener() {
    pdaScanner(scan: (code) {
      logic.scanCode(code);
    });
  }

  void _goLabelList(int dataId) {
    Get.to(
      () => const SapPrintPickingBarCodeListPage(),
      arguments: {'id': dataId},
    )?.then((_) {
      setState(() => _scanListener());
    });
  }

  @override
  void initState() {
    _scanListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => logic.getOrderDetail());
    super.initState();
  }

  GestureDetector _item(PrintPickingDetailInfo data) {
    return GestureDetector(
      onTap: () {
        if (data.order.location == '1001') {
          modifyPickingQty(
            quantity: data.pickQty,
            coefficient: data.order.coefficient ?? 1,
            basicUnit: data.order.basicUnit ?? '',
            commonUnit: data.order.commonUnit ?? '',
            callback: (qty) => setState(() => data.pickQty = qty),
          );
        } else {
          _goLabelList(data.dataId);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(left: 5, right: 5, bottom: 10),
        padding: const EdgeInsets.only(left: 7, top: 10, right: 7, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textSpan(
              hint: 'sap_print_picking_detail_material'.tr,
              text: data.order.orderType == '3'
                  ? '(${data.order.sizeMaterialNumber})${data.order.sizeMaterialName}'
                  : '(${data.order.materialNumber})${data.order.materialName}',
              textColor: Colors.red,
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          expandedTextSpan(
                            flex: 2,
                            hint: 'sap_print_picking_detail_type_body'.tr,
                            text: data.order.typeBody ?? '',
                            textColor: Colors.red,
                          ),
                          expandedTextSpan(
                            hint: 'sap_print_picking_detail_unit'.tr,
                            isBold: false,
                            text: data.order.commonUnit
                                .ifEmpty(data.order.basicUnit ?? ''),
                            textColor: Colors.red,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          expandedTextSpan(
                            hint: 'sap_print_picking_detail_can_pick'.tr,
                            text: data.order.getRemainder().toShowString(),
                            isBold: false,
                            textColor: Colors.blue.shade900,
                            hintColor: Colors.grey.shade700,
                          ),
                          expandedTextSpan(
                            hint: 'sap_print_picking_detail_pick'.tr,
                            text: data.pickQty.toShowString(),
                            isBold: false,
                            textColor: Colors.blue.shade900,
                            hintColor: Colors.grey.shade700,
                          ),
                          if (data.order.location != '1001')
                            expandedTextSpan(
                              hint: 'sap_print_picking_detail_label_qty'.tr,
                              text: state.orderDetailLabels
                                  .where((v) => v.distribution.any(
                                      (v2) => v2.ascriptionId == data.dataId))
                                  .length
                                  .toString(),
                              isBold: false,
                              textColor: Colors.blue.shade900,
                              hintColor: Colors.grey.shade700,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Checkbox(
                  value: data.select,
                  onChanged: (c) => setState(() => data.select = !data.select),
                )
              ],
            ),
            const Divider(height: 10, color: Colors.black),
            for (var item
                in data.order.recommend ?? <RecommendedPositionInfo>[])
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textSpan(
                    hint: 'sap_print_picking_detail_recommend_storage_location'
                        .tr,
                    text: '${item.warehouseLocation}-${item.palletNo}',
                    textColor: Colors.green.shade700,
                    hintColor: Colors.grey.shade700,
                  ),
                  const Divider(height: 10, color: Colors.black),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => pageBody(
          title: 'sap_print_picking_detail_print_pick'.tr,
          actions: [
            if (state.orderDetailLabels.isNotEmpty)
              TextButton(
                onPressed: () => _goLabelList(-1),
                child: Text(
                  'sap_print_picking_detail_label_list'.tr,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
          ],
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.orderDetailOrderList.length,
                  itemBuilder: (c, i) => _item(state.orderDetailOrderList[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: textSpan(
                    hint: 'sap_print_picking_detail_scanned'.tr,
                    text: state.orderDetailLabels
                        .where((v) => v.distribution.isNotEmpty)
                        .length
                        .toString()),
              ),
              SizedBox(
                width: double.infinity,
                child: CombinationButton(
                  text: 'sap_print_picking_detail_pick_material'.tr,
                  click: () => logic.checkSubmitSelect(
                    pick: (isSizeMaterial, list) {
                      checkPickerDialog(
                        pickerCheck: (
                          pickerNumber,
                          pickerSignature,
                          userNumber,
                          userSignature,
                        ) {
                          if (isSizeMaterial) {
                            logic.sizeMaterialPicking(
                              pickerNumber: pickerNumber,
                              pickerSignature: pickerSignature,
                              userNumber: userNumber,
                              userSignature: userSignature,
                              transfer: () {
                                Get.to(
                                  () => const SapPrintPickingTransferPage(),
                                )?.then((_) {
                                  _scanListener();
                                  logic.getOrderDetail();
                                });
                              },
                            );
                          } else {
                            logic.materialPicking(
                              pickerNumber: pickerNumber,
                              pickerSignature: pickerSignature,
                              userNumber: userNumber,
                              userSignature: userSignature,
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  @override
  void dispose() {
    super.dispose();
    state.orderDetailOrderList.clear();
  }
}
