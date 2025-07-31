import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/sap_ink_color_match_info.dart';
import 'package:jd_flutter/utils/socket_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SapInkColorMatchingState {
  var idTested = false.obs;
  var orderList = <SapInkColorMatchOrderInfo>[].obs;

  var mixDeviceName = '';
  var mixDeviceServerIp = '';
  var mixDeviceScalePort = 0;
  SocketClientUtil? mixDeviceSocket;
  var mixDeviceWeight = (0.0);
  var mixDeviceUnit = '';
  late ConnectState mixDeviceConnectState;

  var newTypeBody = '';
  var readMixDeviceWeight = (0.0).obs;
  var inkColorList = <SapInkColorMatchItemInfo>[].obs;
  var typeBodyMaterialList = <SapInkColorMatchTypeBodyMaterialInfo>[];
  var typeBodyServerIp = '';
  var typeBodyScalePortList = <SapInkColorMatchTypeBodyScalePortInfo>[];

  var presetWeight = 0.0;
  var finalWeight = (0.0).obs;
  var presetInkColorList = <SapRecreateInkColorItemInfo>[];


  SapInkColorMatchingState(){
    idTested.value=  spGet('${Get.currentRoute}/idTested')??false;
  }


  clean() {
    newTypeBody = '';
    readMixDeviceWeight.value=0;
    inkColorList.value = [];
    typeBodyMaterialList = [];
    typeBodyServerIp = '';
    typeBodyScalePortList = [];

    mixDeviceName='';
    mixDeviceServerIp='';
    mixDeviceScalePort=0;
    mixDeviceSocket?.clean();
    mixDeviceSocket=null;
    mixDeviceWeight=0;
    mixDeviceUnit='';
    mixDeviceConnectState=ConnectState.unConnect;
  }

  cleanRecreate() {
    presetWeight = 0;
    finalWeight.value = 0;
    presetInkColorList=[];

    mixDeviceName='';
    mixDeviceServerIp='';
    mixDeviceScalePort=0;
    mixDeviceSocket?.clean();
    mixDeviceSocket=null;
    mixDeviceWeight=0;
    mixDeviceUnit='';
    mixDeviceConnectState=ConnectState.unConnect;
  }

  queryOrder({
    required String startDate,
    required String endDate,
    required String typeBody,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_ink_color_matching_getting_color_list'.tr,
      method: webApiSapGetInkColorMatchOrder,
      body: {
        'WERKS': userInfo?.sapFactory ?? '',
        'ZZXTNO': typeBody,
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
      loading: 'sap_ink_color_matching_getting_material_info'.tr,
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
            mixDeviceName= mix!.deviceName ?? '';
            mixDeviceServerIp=data.serverIp ?? '';
            mixDeviceScalePort=mix.scalePort ?? 0;
          } catch (_) {}
          success.call();
        });
      } else {
        this.newTypeBody = '';
        typeBodyMaterialList = [];
        typeBodyServerIp = '';
        typeBodyScalePortList = [];
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  submitOrder({
    required String orderNumber,
    required String inkMaster,
    required double mixActualWeight,
    required double mixTheoreticalWeight,
    required String remarks,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'sap_ink_color_matching_submitting_toning_order'.tr,
      method: webApiSapCreateInkColorMatch,
      body: {
        'WOFNR': orderNumber,
        'WERKS': userInfo?.sapFactory ?? '',
        'ZCOLORNAM': inkMaster,
        'ZZXTNO': newTypeBody,
        'ZZPART1': remarks,
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
