import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

enum ScanLabelOperationType {
  unKnown(0, '初始'),
  create(1, '合并'),
  binding(2, '绑定'),
  unbind(3, '解绑'),
  transfer(4, '转移');

  final int value;
  final String text;

  const ScanLabelOperationType(this.value, this.text);
}

class SapCartonLabelBindingState {
  var labelList = <SapLabelBindingInfo>[].obs;
  var operationType = ScanLabelOperationType.unKnown;
  var operationTypeText = ScanLabelOperationType.unKnown.text.obs;
  var newBoxLabelID = '00505685E5761FD090D2EB8C111F2541'.obs;

  getLabelInfo({
    required String labelCode,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取标签信息...',
      method: webApiSapGetLabelBindingInfo,
      body: {
        'ZTYPE': '04',
        'bqid': labelCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <SapLabelBindingInfo>[
          for (var json in response.data) SapLabelBindingInfo.fromJson(json)
        ];
        if (labelList.isNotEmpty &&
            labelList[0].labelType() != list[0].labelType()) {
          error.call('标签供应商、工厂、物料大类、保管形式、单据类型不同，不能同时操作！');
        } else {
          for (var label in list) {
            if (!labelList.any((v) =>
                v.labelID == label.labelID || v.boxLabelID == label.labelID)) {
              labelList.add(label);
            }
          }
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getLabelPrintInfo({
    required Function(Map<SapPrintLabelInfo, List<SapPrintLabelSubInfo>>) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在获取标签信息...',
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
          error.call('没有可打印的标签！');
        } else {
          success.call(map);
        }
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  operationSubmit({
    required double long,
    required double width,
    required double height,
    required double outWeight,
    required String targetBoxLabelID,
    required String supplierNumber,
    required List<SapLabelBindingInfo> labelList,
    required Function(String) success,
    required Function(String) error,
  }) {
    sapPost(
      loading: '正在提交标签${operationTypeText.value}...',
      method: webApiSapSubmitLabelBindingOperation,
      body: {
        'WERKS': userInfo?.number,
        'USNAM': userInfo?.name,
        'ZNAME_CN': userInfo?.name,
        'LIFNR': supplierNumber,
        'OPERATE': '10',
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
