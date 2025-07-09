import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

class SapPackingScanState {
  var isAbnormal = false.obs;
  var abnormalSearchText = ''.obs;
  var deliveryOrderSearchText = ''.obs;
  var materialSearchText = ''.obs;
  PickerItem? factory;
  PickerItem? warehouse;
  DateTime? plannedDate;
  PickerItem? destination;
  String actualCabinet = '';
  var materialList = <SapPackingScanMaterialInfo>[].obs;
  var pieceList = <PieceMaterialInfo>[].obs;
  var abnormalList = <List<SapPackingScanAbnormalInfo>>[].obs;
  var reverseLabelList = <SapPackingScanReverseLabelInfo>[].obs;
  var deliveryOrderList = <PickingScanDeliveryOrderInfo>[].obs;

  getContainerLoadingInfo({
    required String code,
    required Function(List<SapPackingScanMaterialInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取标签信息...',
      method: webApiSapGetContainerLoadingInfo,
      body: {
        'WERKS': factory?.pickerId(),
        'LGORT': warehouse?.pickerId(),
        'ZZCQ': getDateYMD(time: plannedDate),
        'ZADGE_RCVER': destination?.pickerId(),
        'BQID': code,
        'ZZKHXH1': actualCabinet,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SapPackingScanMaterialInfo>,
          ParseJsonParams(
            response.data,
            SapPackingScanMaterialInfo.fromJson,
          ),
        ).then((list) {
          success.call(list);
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  checkContainer({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在检查货柜...',
      method: webApiSapCheckContainer,
      body: {
        'ZZCQ': getDateYMD(time: plannedDate),
        'ZADGE_RCVER': destination?.pickerId(),
        'ZZKHXH1': actualCabinet,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  sealingCabinet({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交封柜...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {},
        'ITEM2': {
          'ZZCQ': getDateYMD(time: plannedDate),
          'ZADGE_RCVER': destination?.pickerId(),
          'ZZKHXH1': actualCabinet,
          'ZSEALING_DATE': getDateYMD(),
          'USNAM': userInfo?.number,
        },
        'ITEM3': {},
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submit({
    required String postingDate,
    required List<String> list,
    required Function(String) success,
    required Function(String) error,
    required Function(List<SapPackingScanSubmitAbnormalInfo>, String) save,
  }) {
    sapPost(
      loading: '正在提交排柜信息...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {
          'WERKS': factory?.pickerId(),
          'ZZCQ': getDateYMD(time: plannedDate),
          'ZADGE_RCVER': destination?.pickerId(),
          'ZZKHXH1': actualCabinet,
          'LGORT': warehouse?.pickerId(),
          'BQIDS': [
            for (var item in list)
              {
                'BQID': item,
              }
          ],
          'BUDAT_MKPF': postingDate,
          'USNAM': userInfo?.number,
          'ZNAME_CN': userInfo?.name,
        },
        'ITEM2': {},
        'ITEM3': {},
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        materialList.clear();
        success.call(response.message ?? '');
      } else {
        if (response.data == '') {
          error.call(response.message ?? 'query_default_error'.tr);
        } else {
          save.call(
            [
              for (var json in response.data)
                SapPackingScanSubmitAbnormalInfo.fromJson(json)
            ],
            response.message ?? '',
          );
        }
      }
    });
  }

  saveAbnormalPiece({
    required List<SapPackingScanSubmitAbnormalInfo> abnormalList,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: '正在保存异常单...',
      method: webApiSapSaveAbnormalPiece,
      body: abnormalList.map((v) => v.toJson()).toList(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        materialList.clear();
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getAbnormalOrders({
    required Function() success,
    required Function(String msg) error,
  }) {
    sapPost(
      loading: '正在获取异常单信息...',
      method: webApiSapGetAbnormalList,
      body: {
        'WERKS': factory?.pickerId(),
        'LGORT': warehouse?.pickerId(),
        'ZZCQ': getDateYMD(time: plannedDate),
        'ZADGE_RCVER': destination?.pickerId(),
        'ZZKHXH1': actualCabinet,
      },
    ).then((response) {
      abnormalList.clear();
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SapPackingScanAbnormalInfo>,
          ParseJsonParams(
            response.data,
            SapPackingScanAbnormalInfo.fromJson,
          ),
        ).then((list) {
          groupBy(list, (v) => v.materialNumber).forEach((k, v) {
            abnormalList.add(v);
          });
          success.call();
        });
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  deleteAbnormal({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var list = <SapPackingScanAbnormalInfo>[
      for (var g in abnormalList)
        for (var s in g.where((v) => v.search(abnormalSearchText.value))) s
    ];
    sapPost(
      loading: '正在提交删除...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {},
        'ITEM2': {},
        'ITEM3': {
          'USNAM': userInfo?.number,
          'BQIDS': [
            for (var item in list.where((v) => v.isSelected.value))
              {
                'BQID': item.labelNumber,
              }
          ],
        },
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        for (var g in abnormalList) {
          for (var d in list) {
            g.removeWhere((v) => v.labelNumber == d.labelNumber);
          }
        }
        abnormalList.removeWhere((v) => v.isEmpty);
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reSubmit({
    required String postingDate,
    required List<SapPackingScanAbnormalInfo> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交排柜信息...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {
          'WERKS': factory?.pickerId(),
          'ZZCQ': getDateYMD(time: plannedDate),
          'ZADGE_RCVER': destination?.pickerId(),
          'ZZKHXH1': actualCabinet,
          'LGORT': warehouse?.pickerId(),
          'BQIDS': [
            for (var item in list)
              {
                'BQID': item.labelNumber,
              }
          ],
          'BUDAT_MKPF': postingDate,
          'USNAM': userInfo?.number,
          'ZNAME_CN': userInfo?.name,
        },
        'ITEM2': {},
        'ITEM3': {},
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        for (var g in abnormalList) {
          for (var d in list) {
            g.removeWhere((v) => v.labelNumber == d.labelNumber);
          }
        }
        abnormalList.removeWhere((v) => v.isEmpty);
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getReverseLabelInfo({
    required String code,
    required Function(SapPackingScanReverseLabelInfo) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取标签信息...',
      method: webApiSapGetReverseLabelInfo,
      body: {'BQID': code},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(SapPackingScanReverseLabelInfo.fromJson(response.data)
          ..labelId = code);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  reverseLabel({
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交冲销标签...',
      method: webApiSapReverseLabel,
      body: {
        'ZBUDAT_MKPF': '',
        'USNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'BQIDS': [
          for (var item in reverseLabelList)
            {
              'BQID': item.labelId,
            }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        reverseLabelList.clear();
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  saveLog({
    required String postingDate,
    required List<String> list,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在暂存排柜信息...',
      method: webApiSapSubmit,
      body: {
        'ITEM1': {},
        'ITEM2': {},
        'ITEM3': {},
        'ITEM4': {
          'WERKS': factory?.pickerId(),
          'ZZCQ': getDateYMD(time: plannedDate),
          'ZADGE_RCVER': destination?.pickerId(),
          'ZZKHXH1': actualCabinet,
          'LGORT': warehouse?.pickerId(),
          'BQIDS': [
            for (var item in list)
              {
                'BQID': item,
              }
          ],
          'BUDAT_MKPF': postingDate,
          'USNAM': userInfo?.number,
          'ZNAME_CN': userInfo?.name,
        },
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  queryDeliveryOrders({
    required String plannedDate,
    required String destination,
    required String cabinetNumber,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取交货单列表...',
      method: webApiSapGetDeliveryOrders,
      body: {
        'ZZCQ': plannedDate,
        'ZADGE_RCVER': destination,
        'ZZKHXH1': cabinetNumber,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        deliveryOrderList.value = [
          for (var item in response.data)
            PickingScanDeliveryOrderInfo.fromJson(item)
        ];
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  modifyDeliveryOrderDate({
    required List<String> deliveryOrders,
    required String modifyDate,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在修改交货单过账日期...',
      method: webApiSapModifyDeliveryOrderPostingDate,
      body: {
        'VLLIST': [
          for (var item in deliveryOrders) {'VBELN_VL': item}
        ],
        'BUDAT_MKPF': modifyDate,
        'USNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
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
