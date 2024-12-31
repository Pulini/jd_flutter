import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_no_label_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_no_label_stock_in/sap_no_label_stock_in_dialog.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/picker/picker_view.dart';

import 'sap_no_label_stock_in_logic.dart';
import 'sap_no_label_stock_in_state.dart';

class SapNoLabelStockInPage extends StatefulWidget {
  const SapNoLabelStockInPage({super.key});

  @override
  State<SapNoLabelStockInPage> createState() => _SapNoLabelStockInPageState();
}

class _SapNoLabelStockInPageState extends State<SapNoLabelStockInPage> {
  final SapNoLabelStockInLogic logic = Get.put(SapNoLabelStockInLogic());
  final SapNoLabelStockInState state = Get.find<SapNoLabelStockInLogic>().state;

  var dispatchOrderController = TextEditingController();

  var materialController = TextEditingController();

  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.sapNoLabelStockIn.name}${PickerType.startDate}',
  );

  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.sapNoLabelStockIn.name}${PickerType.endDate}',
  );

  late OptionsPickerController processController;

  _item(List<SapNoLabelStockInItemInfo> list) {
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    textSpan(
                      hint: '派工单号：',
                      text: list[0].materialList[0].dispatchNumber ?? '',
                      textColor: Colors.red,
                    ),
                    Row(
                      children: [
                        expandedTextSpan(
                          hint: '派工日期：',
                          text: list[0].materialList[0].dispatchDate ?? '',
                          textColor: Colors.blue.shade700,
                          isBold: false,
                        ),
                        expandedTextSpan(
                          hint: '报工日期：',
                          text: list[0].materialList[0].reportDate ?? '',
                          textColor: Colors.blue.shade700,
                          isBold: false,
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Checkbox(
                value: list.every((v) => v.select),
                onChanged: (c) => setState(() {
                  for (var v in list) {
                    v.select = c!;
                  }
                }),
              ),
            ],
          ),
          const Divider(height: 10, color: Colors.black),
          for (var m in list)
            GestureDetector(
              onTap: () => modifyMaterialStockInQtyDialog(
                max: m.notReceivedQty,
                qty: m.pickQty(),
                callback: (qty) => logic.modifyMaterialStockInQty(qty, m),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  textSpan(
                    hint: '物料：',
                    text:
                        '${m.materialList[0].materialName}(${m.materialList[0].materialCode})',
                    textColor: Colors.green.shade700,
                    isBold: false,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                expandedTextSpan(
                                  hint: '型体：',
                                  text: m.materialList[0].typeBody ?? '',
                                  textColor: Colors.blue.shade700,
                                  isBold: false,
                                ),
                                textSpan(
                                  hint: '单位：',
                                  text: m.materialList[0].basicUnit ?? '',
                                  textColor: Colors.blue.shade700,
                                  isBold: false,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                expandedTextSpan(
                                  hint: '待入库：',
                                  text: m.notReceivedQty.toShowString(),
                                  isBold: false,
                                ),
                                expandedTextSpan(
                                  hint: '入库数：',
                                  text: m.pickQty().toShowString(),
                                  isBold: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Checkbox(
                        value: m.select,
                        onChanged: (c) => setState(() => m.select = c!),
                      ),
                    ],
                  ),
                  const Divider(height: 10, color: Colors.black),
                ],
              ),
            )
        ],
      ),
    );
  }

  _query(String process) {
    logic.query(
      reportStartDate: dpcStartDate.getDateFormatSapYMD(),
      reportEndDate: dpcEndDate.getDateFormatSapYMD(),
      dispatchNumber: dispatchOrderController.text,
      materialCode: materialController.text,
      process: process,
    );
  }

  @override
  void initState() {
    processController = OptionsPickerController(
      PickerType.sapProcessFlow,
      saveKey:
          '${RouteConfig.sapNoLabelStockIn.name}${PickerType.sapProcessFlow}',
      onSelected: (i) => _query(i.pickerId()),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return pageBodyWithBottomSheet(
      bottomSheet: [
        EditText(
          controller: dispatchOrderController,
          hint: '派工单号',
        ),
        EditText(
          controller: materialController,
          hint: '物料编码',
        ),
        DatePicker(pickerController: dpcStartDate),
        DatePicker(pickerController: dpcEndDate),
        OptionsPicker(pickerController: processController),
      ],
      query: () => _query(processController.selectedId.value),
      body: Obx(() => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.orderList.length,
                  itemBuilder: (c, i) => _item(state.orderList[i]),
                ),
              ),
              if (state.orderList
                  .any((v) => v.any((v2) => v2.select && v2.pickQty() > 0)))
                SizedBox(
                  width: double.infinity,
                  child: CombinationButton(
                    text: '提交入库',
                    click: () => checkStockInHandoverDialog(
                      handoverCheck: (ln, ls, un, us, d) => logic.submitStockIn(
                        leaderNumber: ln,
                        leaderSignature: ls,
                        userNumber: un,
                        userSignature: us,
                        postingDate: d,
                        process: processController.selectedId.value,
                        success: () =>
                            _query(processController.selectedId.value),
                      ),
                    ),
                  ),
                ),
            ],
          )),
    );
  }

  @override
  void dispose() {
    Get.delete<SapNoLabelStockInLogic>();
    super.dispose();
  }
}
