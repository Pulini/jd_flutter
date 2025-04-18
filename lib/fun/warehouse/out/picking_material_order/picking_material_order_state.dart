import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/picking_material_order_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class PickingMaterialOrderState {
  var isPosted = 0.obs;
  var orderList = <PickingMaterialOrderInfo>[].obs;

  getPickingMaterialOrderList({
    required String startDate,
    required String endDate,
    required String instruction,
    required String pickingMaterialOrder,
    required String sapSupplier,
    required String sapFactory,
    required String sapWarehouse,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'picking_material_order_querying_wait_deliver_order'.tr,
      method: webApiSapGetPickingMaterialList,
      body: {
        'DATEF': startDate,
        'DATET': endDate,
        'LIFNR': sapSupplier,
        'VBELN': instruction,
        'WOFNR': pickingMaterialOrder,
        'WERKS': sapFactory,
        'LGORT': sapWarehouse,
        'UNAME': userInfo?.number,
        'MBSTA': isPosted.value == 0
            ? ''
            : isPosted.value == 1
                ? '01'
                : '02',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<PickingMaterialOrderInfo>,
          ParseJsonParams(
            response.data,
            PickingMaterialOrderInfo.fromJson,
          ),
        ).then((list) {
          list.sort((a, b) => b.getTimestamp().compareTo(a.getTimestamp()));
          orderList.value = list;
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getMaterialPrintInfo({
    required String orderNumber,
    required Function(PickingMaterialOrderPrintInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'picking_material_order_getting_material_print_info'.tr,
      method: webApiSapGetMaterialPrintInfo,
      body: {'WOFNR': orderNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(PickingMaterialOrderPrintInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  postingPickingMaterialOrder({
    required String faceImage,
    required PickingMaterialOrderInfo order,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'picking_material_order_submitting_posting'.tr,
      method: webApiSapSubmitPickingMaterialOrder,
      body: {
        'DIRECTPOSTING': 'X',
        'GT_REQITEMS': [
          for (var material in order.materialList!)
            for (var item in material.lineList!.where((v) => v.pickingQty > 0))
              {
                'ZZAEMNG': item.pickingQty.toShowString(),
                'BUDAT': getDateYMD(),
                'USNAM': userInfo?.number,
                'ZNAME_CN': userInfo?.name,
                'WOFNR': order.orderNumber,
                'WOLNR': item.lineNo
              }
        ],
        'GT_PICTURE': [
          {'ZZKEYWORD': userInfo?.number, 'ZZITEMNO': 1, 'ZZDATA': faceImage},
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reportPreparedMaterialsProgress({
    required PickingMaterialOrderInfo order,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'picking_material_order_reporting_preparing_materials'.tr,
      method: webApiSapReportPreparedMaterialsProgress,
      body: {
        'GT_REQITEMS': [
          for (var material in order.materialList!)
            for (var item in material.lineList!)
              {
                'BDMNG_BH': item.preparingMaterialsQty.toShowString(),
                'WOFNR': order.orderNumber,
                'WOLNR': item.lineNo
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

  uploadOutTicket({
    required bool isCreate,
    required String orderNumber,
    required List<PickingMaterialOrderMaterialInfo> materialLines,
    required Function(String) success,
    required Function(String) error,
  }) {
    var hasOut = <PickingMaterialOrderMaterialDetailLineInfo>[];
    var noOut = <PickingMaterialOrderMaterialDetailLineInfo>[];
    for (var material in materialLines) {
      for (var item in material.lineList!) {
        if (item.hasOutTicket?.isNotEmpty == true) {
          hasOut.add(item);
        } else {
          noOut.add(item);
        }
      }
    }

    sapPost(
      loading: isCreate ? '正在生成出门单' : '正在撤销出门单',
      method: webApiSapCreateOutTicket,
      body: {
        'GT_REQITEMS': [
          for (var item in isCreate ? noOut : hasOut)
            {
              'UNAME': userInfo?.number,
              'ZOAOUTDOORDEL': isCreate ? '' : 'X',
              'WOFNR': orderNumber,
              'WOLNR': item.lineNo
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
