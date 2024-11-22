import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/sap_production_picking/sap_production_picking_bar_code_list_view.dart';
import 'package:jd_flutter/fun/warehouse/sap_production_picking/sap_production_picking_dialog.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/sap_production_picking_info.dart';
import '../../../widget/combination_button_widget.dart';
import '../../../widget/dialogs.dart';
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
                          hint: '派工单号：',
                          text: data.dispatchNumber,
                          textColor: Colors.red,
                        ),
                        expandedTextSpan(
                          flex: 8,
                          hint: '派工机台：',
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
                          hint: '制程：',
                          text: data.process,
                          isBold: false,
                          textColor: Colors.blue.shade900,
                          hintColor: Colors.grey.shade700,
                        ),
                        expandedTextSpan(
                          flex: 8,
                          hint: '派工日期：',
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
                    hint: '物料名称：',
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
                                  hint: '型体：',
                                  text: data.materialList[i].typeBody ?? '',
                                  isBold: false,
                                  textColor: Colors.blue.shade900,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 5,
                                  hint: '单位：',
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
                                  hint: '可领：',
                                  text: data.remainderList[i].toShowString(),
                                  isBold: false,
                                  textColor: Colors.blue.shade700,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 6,
                                  hint: '线仓：',
                                  text: data.materialList[i].lineStock
                                      .toShowString(),
                                  isBold: false,
                                  textColor: Colors.blue.shade700,
                                  hintColor: Colors.grey.shade700,
                                ),
                                expandedTextSpan(
                                  flex: 5,
                                  hint: '领取：',
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
                            if (data.pickQtyList[i] > 0 ||
                                (data.materialList[i].lineStock ?? 0) > 0) {
                              data.materialList[i].select = c;
                            } else {
                              showSnackBar(
                                title: '错误',
                                message: '无法勾选领料数量为 0 或线仓库存为 0 的物料！',
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
      title: 'SAP生产领料',
      actions: [
        if (isScan)
          state.barCodeList.isNotEmpty
              ? TextButton(
                  onPressed: () => Get.to(() => const BarCodeListPage()),
                  child: const Text(
                    '标签列表',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: () => logic.getBarCodeList(),
                  child: const Text(
                    '刷新标签',
                    style: TextStyle(
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
              Row(
                children: [
                  Expanded(
                    child: CombinationButton(
                      text: '领料',
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
                          errorDialog(content: '请选择要领料的物料！');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          )),
    );
  }
}
