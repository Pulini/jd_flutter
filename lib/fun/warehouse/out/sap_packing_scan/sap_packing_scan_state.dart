import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_scan_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/picker/picker_item.dart';

class SapPackingScanState {
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

  var deliveryOrderList = <PickingScanDeliveryOrderInfo>[].obs;

  void getContainerLoadingInfo({
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

  void checkContainer({
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

  void sealingCabinet({
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

  void submit({
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

  void saveAbnormalPiece({
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



  void saveLog({
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
        materialList.clear();
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void queryDeliveryOrders({
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

  void modifyDeliveryOrderDate({
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
