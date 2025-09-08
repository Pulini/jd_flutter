import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import 'delivery_order_logic.dart';
import 'delivery_order_state.dart';

class DeliveryOrderDetailPage extends StatefulWidget {
  const DeliveryOrderDetailPage({super.key});

  @override
  State<DeliveryOrderDetailPage> createState() =>
      _DeliveryOrderDetailPageState();
}

class _DeliveryOrderDetailPageState extends State<DeliveryOrderDetailPage> {
  final DeliveryOrderLogic logic = Get.find<DeliveryOrderLogic>();
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;

  Widget _item(DeliveryOrderDetailItemInfo data) {
    var itemStyle = const TextStyle(
      color: Colors.black54,
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [Colors.blue.shade100, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'delivery_order_detail_material'
                .trArgs(['${data.materialCode}) ${data.materialDescription}']),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'delivery_order_detail_delivery_qty'.trArgs([
                    data.deliverySumQty.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_check_qty'.trArgs([
                    data.checkQuantity.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_piece'.trArgs([
                    '${data.numPage}',
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'delivery_order_detail_type_body'.trArgs([
                    data.factoryType.ifEmpty(data.distributiveForm ?? ''),
                  ]),
                  style: itemStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'delivery_order_detail_qualified_qty'.trArgs([
                    data.qualifiedQuantity.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_unqualified_qty'.trArgs([
                    data.unqualifiedQuantity.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_short_qty'.trArgs([
                    data.shortQuantity.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_stock_in_qty'.trArgs([
                    data.storageQuantity.toShowString(),
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_delivery_date'.trArgs([
                    '${data.deliveryDate}',
                  ]),
                  style: itemStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'delivery_order_detail_picking_department'.trArgs([
                    '${data.pickingDepartment}',
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_instruction_no'.trArgs([
                    '${data.salesAndDistributionVoucherNumber}',
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_stock_out_voucher'.trArgs([
                    '${data.stockOutVoucher}',
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_stock_out_reverse_voucher'.trArgs([
                    '${data.stockOutWriteOffVoucher}',
                  ]),
                  style: itemStyle,
                ),
              ),
              Expanded(
                child: Text(
                  'delivery_order_detail_stock_out_reverse_reason'.trArgs([
                    '${data.reasonsStockOutWriteOff}',
                  ]),
                  style: itemStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(data.size(), style: itemStyle),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );
    return pageBody(
      title: 'delivery_order_detail_delivery_detail'.tr,
      body: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                expandedTextSpan(
                  hint: 'delivery_order_detail_supplier'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.supplierName}',
                ),
                expandedTextSpan(
                  hint: 'delivery_order_detail_delivery_no'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.deliveryNumber}',
                ),
                expandedTextSpan(
                  hint: 'delivery_order_detail_delivery_location'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.deliveryAddress}',
                ),
              ],
            ),
            Row(
              children: [
                expandedTextSpan(
                  hint: 'delivery_order_detail_purchase_no'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.contractNo}',
                ),
                expandedTextSpan(
                  hint: 'delivery_order_detail_create_instruction_no'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.salesAndDistributionVoucherNumber}',
                ),
                expandedTextSpan(
                  hint: 'delivery_order_detail_coefficient'.tr,
                  hintColor: Colors.black45,
                  textColor: Colors.black45,
                  text: '${state.detailInfo.coefficient}',
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'delivery_order_detail_stock_in_voucher'.trArgs([
                      '${state.detailInfo.materialDocumentNo}',
                    ]),
                    style: titleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    'delivery_order_detail_stock_in_reverse_voucher'.trArgs([
                      '${state.detailInfo.materialDocumentNumberReversal}',
                    ]),
                    style: titleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    'delivery_order_detail_stock_in_reverse_reason'.trArgs([
                      '${state.detailInfo.reasonsStockInWriteOff}',
                    ]),
                    style: titleStyle,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'delivery_order_detail_build_info'.trArgs([
                      '${state.detailInfo.builder} <${state.detailInfo.buildDate}>',
                    ]),
                    style: titleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    'delivery_order_detail_modify_info'.trArgs([
                      '${state.detailInfo.modifier} <${state.detailInfo.modifyDate}>',
                    ]),
                    style: titleStyle,
                  ),
                ),
                Expanded(
                  child: Text(
                    'delivery_order_detail_audit_info'.trArgs([
                      '${state.detailInfo.auditor} <${state.detailInfo.auditDate}>',
                    ]),
                    style: titleStyle,
                  ),
                ),
              ],
            ),
            Text(
              'delivery_order_detail_remark'.trArgs([
                '${state.detailInfo.remarks}',
              ]),
              style: titleStyle,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(
                  top: 10,
                ),
                itemCount: state.detailInfo.deliveryDetailItem!.length,
                itemBuilder: (c, i) =>
                    _item(state.detailInfo.deliveryDetailItem![i]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
