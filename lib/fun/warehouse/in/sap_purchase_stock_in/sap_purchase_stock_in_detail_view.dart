import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_logic.dart';
import 'package:jd_flutter/fun/warehouse/in/sap_purchase_stock_in/sap_purchase_stock_in_state.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class SapPurchaseStockInDetailPage extends StatefulWidget {
  const SapPurchaseStockInDetailPage({super.key});

  @override
  State<SapPurchaseStockInDetailPage> createState() =>
      _SapPurchaseStockInDetailPageState();
}

class _SapPurchaseStockInDetailPageState
    extends State<SapPurchaseStockInDetailPage> {
  final SapPurchaseStockInLogic logic = Get.find<SapPurchaseStockInLogic>();
  final SapPurchaseStockInState state =
      Get.find<SapPurchaseStockInLogic>().state;

  _item(SapPurchaseStockInDetailInfo info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textSpan(
            hint: 'sap_purchase_stock_in_dialog_material'.tr,
            text: '(${info.materialCode})${info.materialDescription}',
            textColor: Colors.red,
          ),
          textSpan(
            hint: 'sap_purchase_stock_in_dialog_purchase_no'.tr,
            text: '${info.purchaseOrderNumber}-${info.purchaseOrderLineNumber}',
            isBold: false,
            hintColor: Colors.grey.shade700,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'sap_purchase_stock_in_dialog_delivery_qty'.tr,
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.deliveryQty.toShowString(),
              ),
              textSpan(
                hint: 'sap_purchase_stock_in_dialog_stock_in_qty'.tr,
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.storageQuantity.toShowString(),
              ),
              textSpan(
                hint: 'sap_purchase_stock_in_dialog_check_qty'.tr,
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.checkQty.toShowString(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              textSpan(
                hint: 'sap_purchase_stock_in_dialog_delivery_date'.tr,
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.deliveryDate ?? '',
              ),
              textSpan(
                hint: 'sap_purchase_stock_in_dialog_piece_qty'.tr,
                isBold: false,
                hintColor: Colors.grey.shade700,
                text: info.numPage.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return pageBody(
      title: 'sap_purchase_stock_in_dialog_delivery_order_detail'.tr,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: 'sap_purchase_stock_in_dialog_suppler'.tr,
                  text: state.detailInfo[0].supplierName ?? '',
                  textColor: Colors.red,
                ),
                if (state.detailInfo[0].inspector?.isNotEmpty == true)
                  textSpan(
                    hint: 'sap_purchase_stock_in_dialog_reviewer'.tr,
                    isBold: false,
                    text: state.detailInfo[0].inspector ?? '',
                  )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                textSpan(
                  hint: 'sap_purchase_stock_in_dialog_delivery_order_no'.tr,
                  isBold: false,
                  text: state.detailInfo[0].deliveryNumber ?? '',
                ),
                textSpan(
                  hint: 'sap_purchase_stock_in_dialog_delivery_location'.tr,
                  isBold: false,
                  text: state.detailInfo[0].deliveryAddress ?? '',
                )
              ],
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10),
                itemCount: state.detailInfo.length,
                itemBuilder: (c, i) => _item(state.detailInfo[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
