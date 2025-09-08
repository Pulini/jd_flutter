import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_bar_code_list_view.dart';
import 'package:jd_flutter/fun/warehouse/out/sap_production_picking/sap_production_picking_dialog.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/scanner.dart';

import 'sap_production_picking_logic.dart';
import 'sap_production_picking_state.dart';

class SapProductionPickingDetailPage extends StatefulWidget {
  const SapProductionPickingDetailPage({super.key});

  @override
  State<SapProductionPickingDetailPage> createState() =>
      _SapProductionPickingDetailPageState();
}

class _SapProductionPickingDetailPageState
    extends State<SapProductionPickingDetailPage> {
  final SapProductionPickingLogic logic = Get.find<SapProductionPickingLogic>();
  final SapProductionPickingState state =
      Get.find<SapProductionPickingLogic>().state;
  bool isScan = Get.arguments['scan'];

  _item(PickingOrderMaterialInfo data) {
    return Container(
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
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        expandedTextSpan(
                          flex: 10,
                          hint: 'sap_production_picking_detail_dispatch_no'.tr,
                          text: data.dispatchNumber,
                          textColor: Colors.red,
                        ),
                        expandedTextSpan(
                          flex: 8,
                          hint: 'sap_production_picking_detail_dispatch_machine'
                              .tr,
                          isBold: false,
                          text: data.machineNumber,
                          textColor: Colors.red,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          flex: 10,
                          hint: 'sap_production_picking_detail_process'.tr,
                          text: data.process,
                          isBold: false,
                          textColor: Colors.blue.shade900,
                          hintColor: Colors.grey.shade700,
                        ),
                        expandedTextSpan(
                          flex: 8,
                          hint:
                              'sap_production_picking_detail_dispatch_date'.tr,
                          text: data.dispatchDate,
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
                onChanged: (c) => setState(() {
                  data.select = !data.select;
                  if (c!) {
                    for (var i = 0; i < data.materialList.length; ++i) {
                      if ((data.materialList[i].lineStock ?? 0) > 0 ||
                          data.pickQtyList[i] > 0) {
                        data.materialList[i].select = true;
                      }
                    }
                  } else {
                    for (var v in data.materialList) {
                      v.select = false;
                    }
                  }
                }),
              )
            ],
          ),
          const Divider(height: 10, color: Colors.black),
          for (var i = 0; i < data.materialList.length; ++i)
            GestureDetector(
              onTap: () {
                if (!isScan) {
                  modifyPickingQty(
                    quantity: data.pickQtyList[i],
                    coefficient: data.materialList[i].coefficient ?? 1,
                    basicUnit: data.materialList[i].basicUnit ?? '',
                    commonUnit: data.materialList[i].commonUnit ?? '',
                    callback: (q) => setState(() {
                      data.pickQtyList[i] = q;
                      if (q <= 0 &&
                          (data.materialList[i].lineStock ?? 0) <= 0 &&
                          data.materialList[i].select) {
                        data.materialList[i].select = false;
                      }
                    }),
                  );
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textSpan(
                    hint: 'sap_production_picking_detail_material_name'.tr,
                    text:
                        '(${data.materialList[i].materialNumber})${data.materialList[i].materialName}',
                    textColor: Colors.green.shade700,
                    hintColor: Colors.grey.shade700,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                expandedTextSpan(
                                  flex: 12,
                                  hint:
                                      'sap_production_picking_detail_type_body'
                                          .tr,
                                  text: data.materialList[i].typeBody ?? '',
                                  isBold: false,
                                  textColor: Colors.blue.shade900,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 5,
                                  hint: 'sap_production_picking_detail_unit'.tr,
                                  text:
                                      '${data.materialList[i].commonUnit?.ifEmpty(data.materialList[i].basicUnit ?? '')}',
                                  isBold: false,
                                  textColor: Colors.blue.shade900,
                                  hintColor: Colors.grey.shade700,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                expandedTextSpan(
                                  flex: 6,
                                  hint: 'sap_production_picking_detail_can_pick'
                                      .tr,
                                  text: data.remainderList[i].toShowString(),
                                  isBold: false,
                                  textColor: Colors.blue.shade700,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 6,
                                  hint:
                                      'sap_production_picking_detail_scene_warehouse'
                                          .tr,
                                  text: data.materialList[i].lineStock
                                      .toShowString(),
                                  isBold: false,
                                  textColor: Colors.blue.shade700,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 5,
                                  hint: 'sap_production_picking_detail_pick'.tr,
                                  text: data.pickQtyList[i].toShowString(),
                                  isBold: false,
                                  textColor: Colors.blue.shade700,
                                  hintColor: Colors.grey.shade700,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: data.materialList[i].select,
                        onChanged: (c) => setState(() {
                          if (c!) {
                            if (data.canPicking(i)) {
                              data.materialList[i].select = c;
                            } else {
                              showSnackBar(
                                message:
                                    'sap_production_picking_detail_cannot_select_error_material_tips'
                                        .tr,
                                isWarning: true,
                              );
                            }
                          } else {
                            data.materialList[i].select = c;
                          }
                          data.select =
                              !data.materialList.any((v) => !v.select);
                        }),
                      )
                    ],
                  ),
                  const Divider(height: 10, color: Colors.black),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    if (isScan) {
      pdaScanner(scan: (code) {
        logic.checkMixCode(code);
      });
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) => logic.getOrderDetail(isScan));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    state.pickDetailList.clear();
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'sap_production_picking_detail_sap_production_picking'.tr,
      actions: [
        if (isScan)
          state.barCodeList.isNotEmpty
              ? TextButton(
                  onPressed: () => Get.to(() => const BarCodeListPage()),
                  child: Text(
                    'sap_production_picking_detail_label_list'.tr,
                    style: const TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => logic.getBarCodeList(),
                  child: Text(
                    'sap_production_picking_detail_refresh_label'.tr,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
      ],
      body: Obx(() => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.pickDetailList.length,
                  itemBuilder: (c, i) => _item(
                    state.pickDetailList[i],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: CombinationButton(
                  text: 'sap_production_picking_detail_pick_material'.tr,
                  click: () {
                    if (logic.hasSubmitSelect()) {
                      checkPickerDialog(
                        pickerCheck: (
                          pickerNumber,
                          pickerSignature,
                          userNumber,
                          userSignature,
                        ) =>
                            logic.submitPicking(
                          pickerNumber: pickerNumber,
                          pickerSignature: pickerSignature,
                          userNumber: userNumber,
                          userSignature: userSignature,
                          isPrint: false,
                          isScan: isScan,
                        ),
                      );
                    } else {
                      errorDialog(
                        content:
                            'sap_production_picking_detail_select_material_tips'
                                .tr,
                      );
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
