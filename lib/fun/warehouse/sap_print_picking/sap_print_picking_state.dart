import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/sap_picking_info.dart';
import '../../../utils/web_api.dart';

class SapPrintPickingState {
  var pickOrderList = <SapPickingInfo>[].obs;
  var orderDetailDispatch = <SapProductionPickingDetailDispatchInfo>[];
  var orderDetailLabels = <SapPickingDetailLabelInfo>[].obs;
  var orderDetailOrderList = <PrintPickingDetailInfo>[].obs;
  var transferList = <List<PalletItem1Info>>[];
  var warehouse = '';
  bool needRefresh = false;

  SapPrintPickingState() {
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
        orderDetailDispatch = data.dispatch ?? [];
        orderDetailLabels.value = data.labels ?? [];
        orderDetailOrderList.value = [
          for (var i = 0; i < (data.order ?? []).length; ++i)
            PrintPickingDetailInfo.fromData(data.order![i])..dataId = i
        ];
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
    required Function(String) success,
    required Function(String) error,
  }) {
    var list =
        orderDetailOrderList.where((v) => v.select && v.canPicking()).toList();
    sapPost(
      loading: '正在提交领料...',
      method: webApiSapMaterialsPicking,
      body: {
        'DATA': [
          for (var item in list)
            {
              'ZTYPE': item.order.orderType,
              'KTSCH': item.order.process,
              'DISPATCH_NO': item.order.dispatchNumber,
              'DISPATCH_ITEM': item.order.dispatchLineNumber,
              'APMNG': item.pickQty.toShowString(),
              'LGORT': item.order.location,
              'ZSIGN': item.order.beyondFlag,
              'USNAM': userInfo?.number,
              'ZNAME_CN': userInfo?.name,
              'ZNAME_EN': '',
              'MEINS': item.order.basicUnit,
              'MATNR': item.order.materialNumber,
              'WERKS': '1500',
            }
        ],
        'DISPATCH': orderDetailDispatch.map((v) => v.toJson()).toList(),
        'PICTURE': [
          {
            'ZZKEYWORD': pickerNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(pickerSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
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

  submitSizeMaterialPrintPicking({
    required String pickerNumber,
    required ByteData pickerSignature,
    required String userNumber,
    required ByteData userSignature,
    required Function(List<String>) relocation,
    required Function(String) error,
  }) {
    var list =
        orderDetailOrderList.where((v) => v.select && v.canPicking()).toList();
    var labels =
        orderDetailLabels.where((v) => v.distribution.isNotEmpty).toList();
    sapPost(
      loading: '正在提交领料...',
      method: webApiSapPrintPicking,
      body: {
        'DATA': [
          for (var item in list)
            for (var label in labels)
              for (var dis in label.distribution
                  .where((v) => v.ascriptionId == item.dataId))
                {
                  'ZTYPE': item.order.orderType,
                  'KTSCH': item.order.process,
                  'DISPATCH_NO': item.order.dispatchNumber,
                  'DISPATCH_ITEM': item.order.dispatchLineNumber,
                  'AUFNR': item.order.productionOrderNumber,
                  'LGORT': item.order.location,
                  'WERKS': item.order.factoryNumber,
                  'APMNG': dis.qty.toShowString(),
                  'ZFTRAYNO': label.palletNumber,
                  'ZBQID': label.labelCode,
                  'ZSFDL': item.order.beyondFlag,
                  'USNAM': userInfo?.number,
                  'ZNAME_CN': userInfo?.name,
                  'ZNAME_EN': '',
                  'MEINS': item.order.basicUnit,
                  'MATNR': item.order.sizeMaterialNumber,
                  'ZLOCAL': label.warehouseLocation,
                  'EBELN': item.order.purchaseOrder,
                  'EBELP': item.order.purchaseOrderLine,
                }
        ],
        'DISPATCH': orderDetailDispatch.map((v) => v.toJson()).toList(),
        'PICTURE': [
          {
            'ZZKEYWORD': userNumber,
            'ZZITEMNO': 1,
            'ZZDATA': base64Encode(userSignature.buffer.asUint8List()),
          },
          {
            'ZZKEYWORD': pickerNumber,
            'ZZITEMNO': 2,
            'ZZDATA': base64Encode(pickerSignature.buffer.asUint8List()),
          },
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        //检查出库托盘上是否有未出库标签需要移库
        var pallets = <String>[];
        var list = orderDetailLabels.where((v) {
          var sum = v.distribution.isEmpty
              ? 0
              : v.distribution.map((v2) => v2.qty).reduce((a, b) => a.add(b));
          return sum < (v.quantity ?? 0);
        });
        groupBy(list, (v) => v.palletNumber).forEach((k, v) {
          pallets.add(k ?? '');
        });
        if (pallets.isNotEmpty) {
          relocation.call(pallets);
        } else {
          successDialog(
            content: response.message,
            back: () => getMaterialPickingOrderDetail(error: error),
          );
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  checkPallet({
    required List<String> pallets,
    required Function(PalletInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取托盘信息...',
      method: webApiSapGetPalletList,
      body: {
        'WERKS': '1500',
        'LGORT': warehouse,
        'ZTRAY_CFM': '',
        'ITEM': [
          for (var pallet in pallets)
            {
              'ZLOCAL': '',
              'ZFTRAYNO': pallet,
              'BQID': '',
              'SATNR': '',
              'MATNR': '',
              'SIZE1': '',
              'ZVBELN_ORI': '',
              'KDAUF': '',
            }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(PalletInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  transfer({
    required PalletItem2Info targetPallet,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交移库...',
      method: webApiSapPuttingOnShelves,
      body: {
        'ZCZLX_WMS': 'WM03',
        'WERKS': '1500',
        'LGORT': warehouse,
        'ITEM': [
          for (var pallet in transferList)
            for (var label in pallet)
              {
                'ZSHKZG': '',
                'ZLOCAL_F': label.location,
                'ZLOCAL_T': targetPallet.location,
                'ZFTRAYNO_F': label.palletNumber,
                'ZFTRAYNO_T': targetPallet.palletNumber,
                'BQID': label.labelNumber,
                'MATNR': label.sizeMaterialNumber,
                'CHARG': label.batch,
                'SOBKZ': label.salesOrderNo?.isNotEmpty == true ? 'E' : '',
                'KDAUF': label.salesOrderNo,
                'KDPOS': label.salesOrderLineItem,
                'ZZVBELN': label.instructionNo,
                'ZZXTNO': label.typeBody,
                'SIZE1': label.size,
                'MENGE': label.quantity,
                'MEINS': label.unit,
              }
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
