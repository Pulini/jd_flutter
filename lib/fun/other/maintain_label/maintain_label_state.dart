import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class MaintainLabelState {
  var materialCodes = <String>[];
  var sapProcessName = '';
  var interID = 0;
  var isMaterialLabel = false.obs;
  var isPartOrder = false;
  var isSingleLabel = false;
  var materialName = ''.obs;
  var typeBody = ''.obs;
  var cbUnprinted = false.obs;
  var cbPrinted = false.obs;
  var labelList = <LabelInfo>[].obs;
  var labelGroupList = <List<LabelInfo>>[].obs;
  var filterSize = 'maintain_label_all'.tr.obs;
  var language ='zh';
  var isShowPreview = false.obs;
  MaintainLabelState() {
    sapProcessName = Get.arguments['SapProcessName'] ?? '';
    materialCodes = Get.arguments['materialCodes'];
    interID = Get.arguments['interID'];
    isMaterialLabel.value = Get.arguments['isMaterialLabel'];
    isPartOrder = Get.arguments['isPartOrder'] ?? false;
    isShowPreview.value=spGet(spSaveLabelMaintainIsPreview)??false;
    language=spGet('language');
    ever(isShowPreview, (value) {
      spSave(spSaveLabelMaintainIsPreview, value);
    });
  }

  List<LabelInfo> getLabelList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelList
        : labelList.where((v) => v.hasSize(filterSize.value)).toList();
  }

  List<List<LabelInfo>> getLabelGroupList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelGroupList
        : labelGroupList
            .where((v) => v.any((v2) => v2.hasSize(filterSize.value)))
            .toList();
  }

  void getLabelInfoList({
    required Function(List<LabelInfo>) success,
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
        ).then((list) =>success.call(list));
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

  void createSingleLabel({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiCreateSingleLabel,
      loading: 'maintain_label_generating_label'.tr,
      params: {
        'InterID': interID,
        'PackTypeID': '478',
        'LabelType': 102,
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

  //获取包装清单贴标总数量
  void getOrderDetailsForMix({
    required Function(List<PickingBarCodeInfo> list) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPackingListBarCodeCount,
      loading: 'maintain_label_getting_label_info'.tr,
      params: {
        'InterID': interID,
        'Type': isMaterialLabel.value == true ? 1 : 0,
        'UserID': userInfo!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) PickingBarCodeInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //获取包装清单贴标总数量
  void getOrderDetailsForCustom({
    required Function(List<PickingBarCodeInfo> list) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetPackingListBarCodeCount,
      loading: 'maintain_label_getting_label_info'.tr,
      params: {
        'InterID': interID,
        'Type': isMaterialLabel.value == true ? 1 : 0,
        'UserID': userInfo!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) PickingBarCodeInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void deleteAllLabel({
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

  void deleteLabels({
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

  void getMaterialProperties({
    required Function(RxList<MaintainMaterialPropertiesInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMaterialProperties,
      loading: 'maintain_label_getting_material_info'.tr,
      params: {
        'MaterialCode': materialCodes.first,
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

  void getMaterialCapacity({
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

  void getMaterialLanguages({
    required Function(RxList<MaintainMaterialLanguagesInfo>) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMaterialLanguages,
      loading: 'maintain_label_getting_material_language_info'.tr,
      params: {'MaterialCode': materialCodes.first},
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

  void setLabelState({
    required List<LabelInfo> selectLabels,
    required Function() success,
  }) {
    httpPost(
      method: webApiSetPrintLabelFlag,
      loading: 'maintain_label_select_label_set_state'.tr,
      body: {
        'InterID': selectLabels[0].interID,
        'BarCodes': [for (var code in selectLabels) code.barCode]
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call();
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
