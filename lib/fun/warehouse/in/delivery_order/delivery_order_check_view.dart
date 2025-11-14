import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/combination_button_widget.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/edit_text_widget.dart';

import 'delivery_order_logic.dart';
import 'delivery_order_state.dart';

class DeliveryOrderCheckPage extends StatefulWidget {
  const DeliveryOrderCheckPage({super.key});

  @override
  State<DeliveryOrderCheckPage> createState() => _DeliveryOrderCheckPageState();
}

class _DeliveryOrderCheckPageState extends State<DeliveryOrderCheckPage> {
  final DeliveryOrderLogic logic = Get.find<DeliveryOrderLogic>();
  final DeliveryOrderState state = Get.find<DeliveryOrderLogic>().state;
  var numberController = TextEditingController();

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
                child: Row(
                  children: [
                    Text(
                      'delivery_order_check_check_qty'.tr,
                      style: const TextStyle(color: Colors.green),
                    ),
                    SizedBox(
                      width: 130,
                      child: NumberDecimalEditText(
                        initQty: data.checkQuantity,
                        onChanged: (v) => data.checkQuantity = v,
                      ),
                    ),
                  ],
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

  void _showLocation() {
    showCupertinoModalPopup(
      context: context,
      builder: (c) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(
                  Icons.cancel_outlined,
                  color: Colors.red,
                ))
          ],
        ),
        content: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: SizedBox(
            height: 200,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: logic.getPickerInitIndex(),
              ),
              diameterRatio: 1.5,
              magnification: 1.2,
              squeeze: 1.2,
              useMagnifier: true,
              itemExtent: 32,
              onSelectedItemChanged: (v) => logic.pickLocation(v),
              children: state.locationList
                  .map((data) => Center(child: Text(data.name ?? '')))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      numberController.text = state.inspectorNumber.value;
      var number = spGet(
          '$spSaveDeliveryOrderCheckInspectorNumber${state.detailInfo.division}');
      if (number != null) {
        numberController.text = number;
        logic.checkWorkerNumber(number);
      }
      state.getStorageLocationList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var titleStyle = const TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.black54,
    );
    return pageBody(
      title: 'delivery_order_check_title'.tr,
      actions: [
        Container(
          width: 600,
          height: 45,
          margin: const EdgeInsets.only(right: 10),
          padding: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Obx(() => Text(
                      state.locationName.value,
                      style: titleStyle,
                    )),
              ),
              Expanded(
                flex: 2,
                child: Obx(() => CombinationButton(
                      combination: Combination.left,
                      text: state.locationList.isNotEmpty
                          ? 'delivery_order_check_storage_location'.tr
                          : 'delivery_order_check_get_storage_location'.tr,
                      backgroundColor: state.locationList.isNotEmpty
                          ? Colors.blue
                          : Colors.red,
                      isEnabled: state.locationName.value !=
                          'delivery_order_check_getting_storage_location'.tr,
                      click: () {
                        if (state.locationList.isNotEmpty) {
                          _showLocation();
                        } else {
                          state.getStorageLocationList();
                        }
                      },
                    )),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.all(5),
                  child: Obx(() => TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        onChanged: (v) => logic.checkWorkerNumber(v),
                        controller: numberController,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            top: 0,
                            bottom: 0,
                            left: 10,
                            right: 10,
                          ),
                          filled: true,
                          fillColor: Colors.grey[300],
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                          labelText: state.inspectorName.isNotEmpty
                              ? 'delivery_order_check_inspector'.trArgs(
                                  [state.inspectorName.value],
                                )
                              : 'delivery_order_check_inspector_number'.tr,
                          labelStyle: TextStyle(
                            color: state.inspectorName.isNotEmpty
                                ? Colors.green
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                ),
              ),
              Expanded(
                flex: 2,
                child: Obx(() => CombinationButton(
                      combination: Combination.right,
                      isEnabled: state.inspectorName.isNotEmpty &&
                          state.locationId.isNotEmpty,
                      text: 'delivery_order_check_save'.tr,
                      click: () => logic.saveCheck(),
                    )),
              )
            ],
          ),
        )
      ],
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
