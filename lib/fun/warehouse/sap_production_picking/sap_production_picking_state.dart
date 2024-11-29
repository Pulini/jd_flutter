import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';

import '../../../bean/http/response/sap_picking_info.dart';
import '../../../utils/web_api.dart';

class SapProductionPickingState {
  var pickOrderList = <SapPickingInfo>[].obs;
  var dispatch = <SapProductionPickingDetailDispatchInfo>[].obs;
  var labels = <SapPickingDetailLabelInfo>[].obs;
  var barCodeList = <SapPickingBarCodeInfo>[].obs;
  var pickDetailList = <PickingOrderMaterialInfo>[].obs;
  bool needRefresh = false;

  SapProductionPickingState() {
    ///Initialize variables
  }

  getMaterialPickingOrderList({
    String? noticeNo,
    String? instructionNo,
    String? typeBody,
    int? orderType,
    String? startDate,
    String? endDate,
    String? process,
    String? workCenter,
    String? warehouse,
    String? picker,
    String? purchaseOrder,
    String? supplier,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取领料通知单列表...',
      method: webApiSapGetPickingOrders,
      body: {
        'NOTICE_NO': noticeNo ?? '',
        'ZVBELN_ORI': instructionNo ?? '',
        'ZZGCXT': typeBody ?? '',
        'ZTYPE': orderType ?? '',
        'ERDAT_F': startDate ?? '',
        'ERDAT_T': endDate ?? '',
        'KTSCH': process ?? '',
        'ZZPGJT': workCenter ?? '',
        'LGORT': warehouse ?? '',
        'USNAM': picker ?? '',
        'EBELN': purchaseOrder ?? '',
        'LIFNR': supplier ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        pickOrderList.value = [
          for (var json in response.data) SapPickingInfo.fromJson(json)
        ];
      } else {
        pickOrderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getMaterialPickingOrderDetail({
    required bool isScan,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取派工单列表明细...',
      method: webApiSapGetPickingOrderDetail,
      body: [
        for (var data in pickOrderList.where((v) => v.select))
          {
            'ZTYPE': data.orderType,
            'NOTICE_NO': data.noticeNo,
            'DISPATCH_NO': data.dispatchNumber,
            'ZZPGJT': data.machineNumber,
            'ERDAT': data.orderDate,
            'LGORT': data.location,
            'USNAM': data.picker,
            'KTSCH': data.process,
            'ZWOFNR': data.pickingOrderNo,
            'EBELN': data.purchaseOrder,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = SapPickingDetailInfo.fromJson(response.data);
        var list = <PickingOrderMaterialInfo>[];
        dispatch.value = data.dispatch ?? [];
        labels.value = data.labels ?? [];
        groupBy(data.order ?? <SapProductionPickingDetailOrderInfo>[],
            (v) => v.dispatchNumber).forEach((k, v) {
          list.add(PickingOrderMaterialInfo.fromData(v, isScan));
        });
        pickDetailList.value = list;
        if (isScan) {
          getProductionPickingBarCodeList(error: error);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitMaterialPrintPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required bool isPrint,
    required bool isScan,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交领料...',
      method: webApiSapMaterialsPicking,
      body: {
        'DATA': [
          for (var i = 0; i < pickDetailList.length; ++i)
            for (var j = 0; i < pickDetailList[i].materialList.length; ++j)
              if (pickDetailList[i].materialList[j].select)
                {
                  'ZTYPE': pickDetailList[i].materialList[j].orderType,
                  'KTSCH': pickDetailList[i].materialList[j].process,
                  'DISPATCH_NO':
                      pickDetailList[i].materialList[j].dispatchNumber,
                  'DISPATCH_ITEM':
                      pickDetailList[i].materialList[j].dispatchLineNumber,
                  'APMNG': pickDetailList[i].pickQtyList[j].toShowString(),
                  'LGORT': pickDetailList[i].materialList[j].location,
                  'ZSIGN': pickDetailList[i].materialList[j].beyondFlag,
                  'USNAM': userInfo?.number,
                  'ZNAME_CN': userInfo?.name,
                  'ZNAME_EN': '',
                  'MEINS': pickDetailList[i].materialList[j].basicUnit,
                  'MATNR': pickDetailList[i].materialList[j].materialNumber,
                  'WERKS': '1500',
                }
        ],
        'DISPATCH': isPrint ? dispatch.toList() : [],
        'PICTURE': [
          {
            'ZZKEYWORD': pickerNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(pickerSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        if (!isPrint && isScan) {
          mixBarCodePicking(
            voucherNo: response.data,
            success: () => success.call(response.data),
            error: error,
          );
        } else {
          success.call(response.data);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  mixBarCodePicking({
    required String voucherNo,
    required Function() success,
    required Function(String) error,
  }) {
    httpPost(
      method: webApiMixBarCodePicking,
      body: {
        'Barcodes':
            barCodeList.where((v) => v.scanned).map((v) => v.barCode).toList(),
        'VoucherNo': voucherNo,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        for (var v in barCodeList) {
          v.scanned = false;
        }
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getProductionPickingBarCodeList({
    String? loading,
    required Function(String) error,
  }) {
    httpPost(
      loading: loading,
      method: webApiGetProductionPickingBarCodeList,
      body: {
        'MaterialNumbers': [
          for (var d in pickDetailList)
            for (var m in d.materialList) m.materialNumber
        ],
        'SAPNumber': 'BL',
        'OrganizeID': 3, //金臻组织id=3
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        barCodeList.value = [
          for (var json in response.data) SapPickingBarCodeInfo.fromJson(json)
        ];
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
