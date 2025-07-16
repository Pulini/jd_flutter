import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MaintainLabelState {
  var materialCode = '';
  var interID = 0;
  var isMaterialLabel = false.obs;
  var isSingleLabel = false;
  var materialName = ''.obs;
  var typeBody = ''.obs;
  var cbUnprinted = false.obs;
  var cbPrinted = false.obs;
  var labelList = <LabelInfo>[].obs;
  var labelGroupList = <List<LabelInfo>>[].obs;
  var filterSize = 'maintain_label_all'.tr.obs;

  MaintainLabelState() {
    materialCode = Get.arguments['materialCode'];
    interID = Get.arguments['interID'];
    isMaterialLabel.value = Get.arguments['isMaterialLabel'];
  }

  List<LabelInfo> getLabelList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelList
        : labelList
            .where((v) => v.items!.any((v2) => v2.size == filterSize.value))
            .toList();
  }

  List<List<LabelInfo>> getLabelGroupList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelGroupList
        : labelGroupList
            .where((v) => v.any(
                (v2) => v2.items!.any((v3) => v3.size == filterSize.value)))
            .toList();
  }

  getLabelInfoList({
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetLabelList,
      loading: 'maintain_label_getting_label_list'.tr,
      params: {'WorkCardID': interID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        compute(
          parseJsonToList<LabelInfo>,
          ParseJsonParams(
            response.data,
            LabelInfo.fromJson,
          ),
        ).then((list) {
          typeBody.value = list[0].factoryType ?? '';
          if (list[0].materialOtherName?.isNotEmpty == true) {
            materialName.value = list[0]
                    .materialOtherName!
                    .firstWhere((v) => v.languageCode == 'zh')
                    .name ??
                '';
          }
          if (!isMaterialLabel.value) {
            list.sort((a, b) => a.labelState().compareTo(b.labelState()));
            labelList.value = list;
          } else {
            isSingleLabel = list[0].packType ?? false;
            var group = <List<LabelInfo>>[];
            groupBy(list, (v) => v.barCode).forEach((k, v) {
              group.add(v);
            });
            labelGroupList.value = group;
          }
        });
      } else {
        if (isMaterialLabel.value) {
          labelList.clear();
        } else {
          labelGroupList.clear();
        }
        error.call(response.message ?? '');
      }
    });
  }

  createSingleLabel({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiCreateSingleLabel,
      loading: 'maintain_label_generating_label'.tr,
      params: {
        'InterID': interID,
        'PackTypeID': '478',
        'LabelType': 1,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  barCodeCount({
    required bool isMix,
    required Function(List<PickingBarCodeInfo> list) success,
    required Function(String msg) error,
  }) {
    Future<BaseData> http;
    if (isMix) {
      http = httpGet(
        method: webApiGetPackingListBarCodeCount,
        loading: 'maintain_label_getting_label_info',
        params: {
          'InterID': interID,
          'LabelType': 3,
          'UserID': userInfo?.userID,
        },
      );
    } else {
      if (isMaterialLabel.value) {
        http = httpGet(
          method: webApiGetPackingListBarCodeCountBySize,
          loading: 'maintain_label_getting_label_info'.tr,
          params: {
            'InterID': interID,
            'UserID': userInfo?.userID,
          },
        );
      } else {
        http = httpGet(
          method: webApiGetPackingListBarCodeCount,
          loading: 'maintain_label_getting_label_info'.tr,
          params: {
            'InterID': interID,
            'LabelType': 3,
            'UserID': userInfo?.userID,
          },
        );
      }
    }
    http.then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) PickingBarCodeInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  deleteAllLabel({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiCleanLabel,
      loading: 'maintain_label_deleting_packing_order'.tr,
      params: {
        'InterID': interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  deleteLabels({
    required List<String> select,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiDeleteLabels,
      loading: 'maintain_label_deleting_label'.tr,
      body: {
        'WorkCardID': interID.toString(),
        'BarCodes': select,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getMaterialProperties({
    required Function(RxList<MaintainMaterialPropertiesInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMaterialProperties,
      loading: 'maintain_label_getting_material_info'.tr,
      params: {
        'MaterialCode': materialCode,
        'InterID': interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            MaintainMaterialPropertiesInfo.fromJson(json)
        ].obs);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getMaterialCapacity({
    required Function(RxList<MaintainMaterialCapacityInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMaterialCapacity,
      loading: 'maintain_label_getting_packing_order_info'.tr,
      params: {
        'InterID': interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            MaintainMaterialCapacityInfo.fromJson(json)
        ].obs);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getMaterialLanguages({
    required Function(RxList<MaintainMaterialLanguagesInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMaterialLanguages,
      loading: 'maintain_label_getting_material_language_info'.tr,
      params: {'MaterialCode': materialCode},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            MaintainMaterialLanguagesInfo.fromJson(json)
        ].obs);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  setLabelState({
    required List<List<LabelInfo>> selectLabels,
    required int labelType,
    required Function(int type) success,
  }) {
    httpPost(
      method: webApiSetPrintLabelFlag,
      loading: 'maintain_label_select_label_set_state'.tr,
      body: {
        'InterID': selectLabels[0][0].interID,
        'BarCodes': [
          for (var code in selectLabels[0])
            code.barCode
        ]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(labelType);
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
