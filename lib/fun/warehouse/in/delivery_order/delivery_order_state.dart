import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/delivery_order_info.dart';
import 'package:jd_flutter/bean/http/response/sap_purchase_stock_in_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class DeliveryOrderState {
  var stockType = 0.obs;
  var orderType = 1.obs;
  var deliveryOrderList = <List<DeliveryOrderInfo>>[].obs;
  late DeliveryOrderDetailInfo detailInfo;
  var factoryNumber = '';
  var locationList = <LocationInfo>[].obs;
  var locationId = ''.obs;
  var locationName = ''.obs;
  var inspectorNumber = ''.obs;
  var inspectorName = ''.obs;

  var canAddPiece = false.obs;
  var orderItemInfo = <DeliveryOrderInfo>[];
  var materialList = <String, double>{};
  var orderLabelList = <DeliveryOrderLabelInfo>[];
  var scannedLabelList = <DeliveryOrderLabelInfo>[].obs;
  var canSubmitLabelBinding = false.obs;

  getDeliveryOrders({
    required String startDate,
    required String endDate,
    required String typeBody,
    required String instruction,
    required String supplier,
    required String purchaseOrder,
    required String materialCode,
    required String company,
    required String workerNumber,
    required String workCenter,
    required String warehouse,
    required String factory,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'delivery_order_querying_delivery_orders'.tr,
      method: webApiGetDeliveryOrders,
      params: {
        'beginDate': startDate,
        'endDate': endDate,
        'productName': typeBody,
        'scMONO': instruction,
        'supplyNo': supplier,
        'deliNO': purchaseOrder,
        'materialNo': materialCode,
        'finishType': orderType.value.toString(),
        'factoryArea': company,
        'character': userInfo?.sapRole,
        'empCode': workerNumber,
        'line': workCenter,
        'stockNo': warehouse,
        'finishStock': stockType.value == 1
            ? 'NotInStorage'
            : stockType.value == 2
                ? 'InStorageNoOut'
                : stockType.value == 3
                    ? 'OutOfStock'
                    : 'All',
        'factoryNo': factory,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<DeliveryOrderInfo>,
          ParseJsonParams(
            response.data,
            DeliveryOrderInfo.fromJson,
          ),
        ).then((list) {
          var newList = <List<DeliveryOrderInfo>>[];
          groupBy(list, (v) => v.deliNo ?? '').forEach((k, v) {
            newList.add(v);
          });
          deliveryOrderList.value = newList;
        });
        success.call(response.message ?? '');
      } else {
        deliveryOrderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getDeliveryOrdersDetails({
    required String produceOrderNo,
    required String deliNo,
    required String line,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'delivery_order_querying_delivery_order_detail'.tr,
      method: webApiGetDeliveryOrdersDetails,
      params: {
        'scWorkcardNo': produceOrderNo,
        'DeliNO': deliNo,
        'Line': line,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToData<DeliveryOrderDetailInfo>,
          ParseJsonParams(response.data, DeliveryOrderDetailInfo.fromJson),
        ).then((data) {
          detailInfo = data;
          success.call();
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getTemporaryDetail({
    required String zno,
    required Function() success,
    required Function(String) error,
  }) {
    httpGet(
      loading: 'delivery_order_querying_delivery_order_detail'.tr,
      method: webApiGetTemporaryDetail,
      params: {
        'Type': 'Deli',
        'Zno': zno,
        'materialCode': '',
        'EmpCode': userInfo?.number,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getStorageLocationList() {
    locationName.value = 'delivery_order_getting_storage_location'.tr;
    httpGet(
      method: webApiGetStorageLocationList,
      params: {'FactoryNumber': factoryNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        locationList.value = [
          for (var json in response.data) LocationInfo.fromJson(json)
        ];
        var location = spGet(spSaveDeliveryOrderCheckLocation) ?? '';
        var cache = locationList.firstWhere(
            (v) => v.storageLocationNumber == location,
            orElse: () => locationList[0]);
        locationId.value = cache.storageLocationNumber ?? '';
        locationName.value = cache.name ?? '';
        spSave(spSaveDeliveryOrderCheckLocation, locationId.value);
      } else {
        locationName.value = response.message ?? 'query_default_error'.tr;
      }
    });
  }

  saveCheck({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'delivery_order_checking_data'.tr,
      method: webApiSaveDeliveryOrderCheck,
      body: {
        'MES_Items': [
          for (DeliveryOrderDetailItemInfo item
              in detailInfo.deliveryDetailItem ?? [])
            {
              'DeliveryNumber': detailInfo.deliveryNumber,
              'DeliveryOrderLineNumber': item.deliveryOrderLineNumber,
              'Location': locationId.value,
              'CheckQuantity': item.checkQuantity.toShowString(),
              'Inspector': inspectorNumber.value,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? 'query_default_error'.tr);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  checkReversalStockIn({
    required List<DeliveryOrderInfo> reversalList,
    required Function(List<ReversalLabelInfo>) reversalWithCode,
    required Function() reversal,
  }) {
    sapPost(
      loading: 'delivery_order_checking_stock_in_order'.tr,
      method: webApiSapReversalStockInCheck,
      body: {
        'GT_REQITEMS': [
          for (var item in reversalList)
            {
              'MATNR': '',
              'ZDELINO': item,
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reversalWithCode.call(
            [for (var json in response.data) ReversalLabelInfo.fromJson(json)]);
      } else {
        reversal.call();
      }
    });
  }

  reversalStockIn({
    required String workCenterID,
    required String reason,
    required List<DeliveryOrderInfo> reversalList,
    required List<String> label,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'delivery_order_reversing_stock_in'.tr,
      method: webApiReversalStockIn,
      body: {
        'EmpCode': userInfo?.number,
        'ChineseName': userInfo?.name,
        'Line': workCenterID,
        'Remarks': reason,
        'DeilNoList': [for (var item in reversalList) item.deliNo],
        'CGOrderInstockJBQ2Saplist': [
          for (var item in label) {'PieceNo': item}
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

  reversalStockOut({
    required String workCenterID,
    required String reason,
    required List<DeliveryOrderInfo> reversalList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'delivery_order_reversing_stock_out'.tr,
      method: webApiReversalStockOut,
      body: {
        'EmpCode': userInfo?.number,
        'ChineseName': userInfo?.name,
        'Line': workCenterID,
        'Remarks': reason,
        'DeilNoList': [
          for (var item in reversalList)
            {
              'DeilNo': item.deliNo,
              'ScWorkcardNo': item.produceOrderNo,
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

  getSupplierLabelInfo({
    required String factoryNumber,
    required String supplierNumber,
    required String deliveryOrderNumber,
    required Function(List<DeliveryOrderLabelInfo>) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'delivery_order_getting_order_scan_detail'.tr,
      method: webApiSapGetSupplierLabelInfo,
      body: {
        'WERKS': factoryNumber,
        'LIFNR': supplierNumber,
        'ZDELINO': deliveryOrderNumber,
      },
    ).then((response) {
      orderLabelList.clear();
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) DeliveryOrderLabelInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getLabelBindingStaging({
    required Function(List<DeliveryOrderLabelInfo>) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'delivery_order_getting_temporary_label'.tr,
      method: webApiSapGetLabelBindingStaging,
      body: {
        'GT_REQITEMS': [
          {'ZDELINO': orderItemInfo[0].deliNo}
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) DeliveryOrderLabelInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  stagingLabelBinding({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'delivery_order_submitting_temporary_label'.tr,
      method: webApiSapStagingLabelBinding,
      body: {
        'ZUSNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'ZLGORT': '',
        'ZEXAMINER': '',
        'GT_REQITEMS': [
          for (var item in scannedLabelList)
            {
              'ZPIECE_NO': item.pieceNo,
              'ZDELINO': orderItemInfo[0].factoryNO,
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

  submitLabelBinding({
    required String storageLocation,
    required String inspectorNumber,
    required Function(String) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: 'delivery_order_submitting_label_bind'.tr,
      method: webApiSapSubmitLabelBinding,
      body: {
        'ZUSNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'ZLGORT': storageLocation,
        'ZEXAMINER': inspectorNumber,
        'GT_REQITEMS': [
          for (var item in scannedLabelList)
            {
              'ZPIECE_NO': item.pieceNo,
              'ZDELINO': orderItemInfo[0].deliNo,
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? "");
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
