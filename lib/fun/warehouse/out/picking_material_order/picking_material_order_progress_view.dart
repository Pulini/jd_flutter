import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_state.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class PickingMaterialOrderProgressPage extends StatefulWidget {
  const PickingMaterialOrderProgressPage({super.key});

  @override
  State<PickingMaterialOrderProgressPage> createState() =>
      _PickingMaterialOrderProgressPageState();
}

class _PickingMaterialOrderProgressPageState
    extends State<PickingMaterialOrderProgressPage> {
  final PickingMaterialOrderLogic logic = Get.find<PickingMaterialOrderLogic>();
  final PickingMaterialOrderState state =
      Get.find<PickingMaterialOrderLogic>().state;
  int index = Get.arguments['index'];

  Widget _item(PickingMaterialOrderMaterialInfo data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.only(left: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: Colors.grey, width: 2),
      ),
      child: Column(
        children: [
          Row(children: [
            expandedTextSpan(
              hint: 'picking_material_order_material_tips'.tr,
              text: '(${data.materialCode}) ${data.materialName}',
              textColor: data.pickingStatusColor(),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                data.preparedMaterialsStatusText(),
                style: TextStyle(color: data.preparedMaterialsStatusColor()),
              ),
            ),
            Text('picking_material_order_preparing_material_qty'.tr),
            SizedBox(
              width: 200,
              child: data.isBasicUnit
                  ? NumberDecimalEditText(
                      max: data.canBasicPreparingMaterialsQty(),
                      initQty: data.basicPreparingMaterialsQty(),
                      resetQty: data.canBasicPreparingMaterialsQty(),
                      onChanged: (v) {
                        setState(
                            () => data.setLinesBasicPreparedMaterialsQty(v));
                      },
                    )
                  : NumberDecimalEditText(
                      max: data.canCommonPreparingMaterialsQty(),
                      initQty: data.commonPreparingMaterialsQty(),
                resetQty: data.canBasicPreparingMaterialsQty(),
                      onChanged: (v) {
                        setState(
                            () => data.setLinesCommonPreparedMaterialsQty(v));
                      },
                    ),
            ),
            data.isOnlyOneUnit()
                ? Text(data.basicUnit ?? '')
                : GestureDetector(
                    onTap: () => setState(() {
                      data.isBasicUnit = !data.isBasicUnit;
                    }),
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 7, top: 3, right: 7, bottom: 3),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        data.isBasicUnit
                            ? data.basicUnit ?? ''
                            : data.commonUnit ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
            const SizedBox(width: 10),
          ]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var data = state.orderList[index];
    return pageBody(
      title: 'picking_material_order_report_preparing_materials_progress'.tr,
      actions: [
        CombinationButton(
          text: 'picking_material_order_report'.tr,
          click: () => logic.reportPreparedMaterialsProgress(data),
        ),
        const SizedBox(width: 10)
      ],
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: 'picking_material_order_picking_no'.tr,
                  text: data.orderNumber ?? '',
                ),
                textSpan(
                  hint: 'picking_material_order_supplier'.tr,
                  text: data.supplierName ?? '',
                  textColor: Colors.green.shade700,
                ),
                textSpan(
                  hint: 'picking_material_order_create'.tr,
                  text: '${data.date} ${data.created}',
                  textColor: Colors.black54,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: data.materialList!.length,
                itemBuilder: (c, i) => _item(data.materialList![i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
