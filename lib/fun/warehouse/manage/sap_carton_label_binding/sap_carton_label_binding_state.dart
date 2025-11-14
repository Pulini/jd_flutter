import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

enum ScanLabelOperationType {
  unKnown,
  create,
  binding,
  unbind,
  transfer,
}

String getOperationTypeText(ScanLabelOperationType type) {
  var text = '';
  switch (type) {
    case ScanLabelOperationType.create:
      text = 'carton_label_binding_operation_type_create'.tr;
      break;
    case ScanLabelOperationType.binding:
      text = 'carton_label_binding_operation_type_binding'.tr;
      break;
    case ScanLabelOperationType.unbind:
      text = 'carton_label_binding_operation_type_unbind'.tr;
      break;
    case ScanLabelOperationType.transfer:
      text = 'carton_label_binding_operation_type_transfer'.tr;
      break;
    default:
      text = 'carton_label_binding_operation_type_unknown'.tr;
  }
  return text;
}

class SapCartonLabelBindingState {
  var labelList = <SapLabelBindingInfo>[].obs;
  var operationType = ScanLabelOperationType.unKnown;
  var operationTypeText =
      getOperationTypeText(ScanLabelOperationType.unKnown).obs;
  var newBoxLabelID = ''.obs;

  void getLabelInfo({
    required String labelCode,
    required Function(List<SapLabelBindingInfo>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'carton_label_binding_getting_label_info'.tr,
      method: webApiSapGetLabelBindingInfo,
      body: {
        'ZTYPE': '04',
        'bqid': labelCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) SapLabelBindingInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void getLabelPrintInfo({
    required Function(Map<SapPrintLabelInfo, List<SapPrintLabelSubInfo>>)
        success,
    required Function(String) error,
  }) {
    sapPost(
      loading: 'carton_label_binding_getting_label_info'.tr,
      method: webApiSapGetPrintLabelListInfo,
      body: {
        'BQID': newBoxLabelID.value,
        'OPERATE': '10', //10 绑定 20 解绑  输出内容都一样 ,拆分不用传
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = [
          for (var json in response.data) SapPrintLabelInfo.fromJson(json)
        ];
        var map = <SapPrintLabelInfo, List<SapPrintLabelSubInfo>>{};
        list.where((v) => v.isBoxLabel).forEach((v) {
          var materials = <SapPrintLabelSubInfo>[];
          list.where((v2) => v2.boxLabelID == v.labelID).forEach((v2) {
            materials.addAll(v2.subLabel ?? []);
          });
          map[v] = materials;
        });
        if (map.isEmpty) {
          error.call('carton_label_binding_no_label'.tr);
        } else {
          success.call(map);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  void operationSubmit({
    required double long,
    required double width,
    required double height,
    required double outWeight,
    required String targetBoxLabelID,
    required String factoryNo,
    required String supplierNumber,
    required List<SapLabelBindingInfo> labelList,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'carton_label_binding_submitting_label'
          .trArgs([operationTypeText.value]),
      method: webApiSubmitLabelBindingOperation,
      body: {
        'USNAM': userInfo?.number,
        'ZNAME_CN': userInfo?.name,
        'WERKS': factoryNo,
        'LIFNR': supplierNumber,
        'OPERATE': operationType == ScanLabelOperationType.unbind
                ? '20'
                : '10',
        'ZZCJC': long,
        'ZZCJK': width,
        'ZZCJG': height,
        'ZNTGEW_PZ': outWeight,
        'ZDBBQID': targetBoxLabelID,
        'gt_reqitems1': [
          for (var label in labelList)
            {'bqid': label.labelID, 'zdbbqid': label.boxLabelID}
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        newBoxLabelID.value = response.data;
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}
