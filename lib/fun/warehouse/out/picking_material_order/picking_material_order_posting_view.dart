import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_logic.dart';
import 'package:jd_flutter/fun/warehouse/out/picking_material_order/picking_material_order_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

class PickingMaterialOrderPostingPage extends StatefulWidget {
  const PickingMaterialOrderPostingPage({super.key});

  @override
  State<PickingMaterialOrderPostingPage> createState() =>
      _PickingMaterialOrderPostingPageState();
}

class _PickingMaterialOrderPostingPageState
    extends State<PickingMaterialOrderPostingPage> {
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
          colors: [Colors.blue.shade100, Colors.green.shade50],
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
            Text('picking_material_order_posting_qty'.tr),
            SizedBox(
              width: 150,
              child: data.isBasicUnit
                  ? NumberDecimalEditText(
                      max: data.canBasicPickingQty(),
                      initQty: data.basicPickingQty().toFixed(3),
                      onChanged: (v) {
                        setState(() => data.setLinesBasicPickingQty(v));
                      },
                    )
                  : NumberDecimalEditText(
                      max: data.canCommonPickingQty(),
                      initQty: data.commonPickingQty().toFixed(3),
                      onChanged: (v) {
                        setState(() => data.setLinesCommonPickingQty(v));
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

  _posting(PickingMaterialOrderInfo data) {
    if (userInfo?.picUrl == null || userInfo?.picUrl?.isEmpty == true) {
      errorDialog(content: 'picking_material_order_login_account_avatar_not_upload'.tr);
    } else {
      livenFaceVerification(
        faceUrl: userInfo?.picUrl ?? '',
        verifySuccess: (workerB64) => logic.posting(
          faceImage: workerB64,
          order: data,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = state.orderList[index];
    return pageBody(
      title: 'picking_material_order_posting_check'.tr,
      actions: [
        if (data.materialList!.any((v) => v.pickingStatus() != 0))
          CombinationButton(text: 'picking_material_order_submit_posting'.tr, click: () => _posting(data)),
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
                  hint: 'picking_material_order_picking_number'.tr,
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
