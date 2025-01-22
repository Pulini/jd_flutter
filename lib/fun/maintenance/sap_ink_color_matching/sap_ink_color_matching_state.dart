import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapInkColorMatchingState {
  var typeBody = ''.obs;
  var idTested = false.obs;
  var orderList = <SapInkColorMatchOrderInfo>[].obs;
  var newTypeBody = '';
  var inkColorList = <SapInkColorMatchItemInfo>[].obs;
  var typeBodyMaterialList = <SapInkColorMatchTypeBodyMaterialInfo>[];
  var typeBodyServerIp = '';
  var typeBodyScalePortList = <SapInkColorMatchTypeBodyScalePortInfo>[];

  SapInkColorMatchItemInfo? mixDeviceScalePort;

  SapInkColorMatchingState() {
    ///Initialize variables
  }

  clean() {
    newTypeBody = '';
    inkColorList.value = [];
    typeBodyMaterialList = [];
    typeBodyServerIp = '';
    typeBodyScalePortList = [];
    mixDeviceScalePort?.close();
    mixDeviceScalePort = null;
  }

  queryOrder({
    required String startDate,
    required String endDate,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取调色单列表...',
      method: webApiSapGetInkColorMatchOrder,
      body: {
        'WERKS': userInfo?.sapFactory ?? '',
        'ZZXTNO': typeBody.value,
        'BUDAT_BEGIN': startDate,
        'BUDAT_END': endDate,
        'ZZDUZT': idTested.value ? 'X' : '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<SapInkColorMatchOrderInfo>,
          ParseJsonParams(
            response.data,
            SapInkColorMatchOrderInfo.fromJson,
          ),
        ).then((list) {
          orderList.value = list;
        });
      } else {
        orderList.value = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  checkTypeBody({
    required bool isNew,
    required String newTypeBody,
    required Function() success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取型体及物料数据...',
      method: webApiSapCheckInkColorMatchTypeBody,
      body: {
        'WERKS': userInfo?.sapFactory ?? '',
        'ZZXTNO': isNew ? newTypeBody : '#Modify#',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToData<SapInkColorMatchTypeBodyInfo>,
          ParseJsonParams(
            response.data,
            SapInkColorMatchTypeBodyInfo.fromJson,
          ),
        ).then((data) {
          this.newTypeBody = newTypeBody;
          typeBodyMaterialList = data.materials ?? [];
          typeBodyServerIp = data.serverIp ?? '';
          typeBodyScalePortList = data.scalePorts ?? [];
          try {
            var mix = data.scalePorts?.firstWhere((v) => v.isMix == 'X');
            mixDeviceScalePort = SapInkColorMatchItemInfo(
                isNewItem: true,
                deviceName: mix!.deviceName ?? '',
                deviceIp: data.serverIp ?? '',
                // deviceIp: '192.168.101.231',
                scalePort: mix.scalePort ?? 0,
                // scalePort: 5800,
                materialCode: '',
                materialName: '',
                materialColor: '');
          } catch (_) {
            mixDeviceScalePort?.close();
            mixDeviceScalePort = null;
          }
          success.call();
        });
      } else {
        this.newTypeBody = '';
        typeBodyMaterialList = [];
        typeBodyServerIp = '';
        typeBodyScalePortList = [];
        mixDeviceScalePort?.close();
        mixDeviceScalePort = null;
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitOrder({
    required String orderNumber,
    required String inkMaster,
    required double mixActualWeight,
    required double mixTheoreticalWeight,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交调色单...',
      method: webApiSapCreateInkColorMatch,
      body: {
        'WOFNR': orderNumber,
        'WERKS': userInfo?.sapFactory ?? '',
        'ZCOLORNAM': inkMaster,
        'ZZXTNO': newTypeBody,
        'ZMIXNTGEW': mixActualWeight,
        'ZMIXNTGEW_IDEAL': mixTheoreticalWeight,
        'ITEM': [
          for (var item in inkColorList)
            {
              'MATNR': item.materialCode,
              'ZNTGEW_BEF': item.weightBeforeColorMix.value,
              'ZNTGEW_AFT': item.weightAfterColorMix.value,
              'ZMENG3': item.consumption(),
              'MEINS': item.unit.value,
            }
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
}
