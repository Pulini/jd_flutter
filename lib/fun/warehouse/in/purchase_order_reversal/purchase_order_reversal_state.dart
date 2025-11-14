import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/purchase_order_reversal_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PurchaseOrderReversalState {
  var orderList = <PurchaseOrderReversalInfo>[].obs;

  void getReceiptVoucherList({
    required String startDate,
    required String endDate,
    required String supplierNumber,
    required String factory,
    required String warehouse,
    required String materialVoucher,
    required String typeBody,
    required String salesOrderNo,
    required String purchaseOrder,
    required String materielCode,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'purchase_order_reversal_getting_receipt_voucher_list'.tr,
      method: webApiSapGetReceiptVoucherList,
      body: {
        'DATEF': startDate, //开始时间
        'DATET': endDate, //结束时间
        'MBLNR': materialVoucher, //物料凭证号
        'ZZGCXT': typeBody, //型体
        'VBELN': salesOrderNo, //销售订单号
        'LIFNR': supplierNumber, //供应商
        'EBELN': purchaseOrder, //采购凭证号
        'MATNR': materielCode, //物料编号
        'ZQY': factory, //厂区
        'WERKS': warehouse, //工厂
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<PurchaseOrderReversalInfo>,
          ParseJsonParams(response.data, PurchaseOrderReversalInfo.fromJson),
        ).then((list) {
          orderList.value = list;
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void reversal({
    required List<PurchaseOrderReversalInfo> submitList,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'purchase_order_reversal_reversing_receipt'.tr,
      method: webApiPurchaseOrderReversal,
      body: {
        'OffCGOrderInstock2SapList': [
          for (PurchaseOrderReversalInfo item in submitList)
            {
              'MaterialDocumentNo': item.materialDocumentNo,
              'MaterialVoucherYear': item.materialVoucherYear,
              'MaterialDocumentLineItemNumber': item.materialVoucherItem,
              'UserName': userInfo?.number,
              'ChineseName': userInfo?.name,
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
