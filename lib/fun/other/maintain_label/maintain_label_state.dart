import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/create_custom_label_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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

  MaintainLabelState() {
    sapProcessName = Get.arguments['SapProcessName']??'';
    materialCodes = Get.arguments['materialCodes'];
    interID = Get.arguments['interID'];
    isMaterialLabel.value = Get.arguments['isMaterialLabel'];
    isPartOrder = Get.arguments['isPartOrder']??false;
  }

  List<LabelInfo> getLabelList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelList
        : labelList.where((v) => v.hasSize(filterSize.value)).toList();
  }

  List<List<LabelInfo>> getLabelGroupList() {
    return filterSize.value == 'maintain_label_all'.tr
        ? labelGroupList
        : labelGroupList.where((v) => v.any((v2) => v2.hasSize(filterSize.value))).toList();
  }

  void getLabelInfoList({
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
          typeBody.value = list.first.subList!.first.factoryType ?? '';
          var materials = [];
          for (var v in list) {
            for (var v2 in v.subList!) {
              if(!materials.contains( v2.getMaterialLanguage())){
                materials.add( v2.getMaterialLanguage());
              }
            }
          }
          if(materials.length > 1){
            materialName.value = materials.join(',');
          }else{
            materialName.value =materials.first;
          }
          if (isMaterialLabel.value) {
            list.sort((a, b) => a.labelState().compareTo(b.labelState()));
            labelList.value = list;
          } else {
            isSingleLabel = list.first.packType ?? false;
            var group = <List<LabelInfo>>[];
            groupBy(list, (v) => v.barCode).forEach((k, v) {
              group.add(v);
            });
            labelGroupList.value = group;
          }
          debugPrint('isMaterialLabel=${isMaterialLabel.value} labelList=${labelList.length}  isSingleLabel=$isSingleLabel  labelGroupList=${labelGroupList.length}');
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
    required Function(List<List<PickingBarCodeInfo>> list) success,
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
        logger.f('---------------------');
        final List<PickingBarCodeInfo> dataList = [
          for (var json in response.data) PickingBarCodeInfo.fromJson(json)
        ];

        final List<List<PickingBarCodeInfo>> orderData = [];

        groupBy(dataList, (item) => item.size ?? '').forEach((size, items) {
          debugPrint('size=$size');
          logger.f(items);
          var totalSurplusQty =
              items.map((v) => v.surplusQty).reduce((a, b) => a.add(b));
          if (totalSurplusQty > 0) {
            orderData.add(items.where((v) => v.surplusQty > 0).toList());
          }
        });
        success(orderData);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //获取包装清单贴标总数量
  void getOrderDetailsForCustom({
    required Function(List<List<CreateCustomLabelsData>> list) success,
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
        final List<PickingBarCodeInfo> dataList = [
          for (var json in response.data) PickingBarCodeInfo.fromJson(json)
        ];

        final List<List<CreateCustomLabelsData>> orderData = [];

        final Map<String, List<PickingBarCodeInfo>> groupedByMto =
            groupBy(dataList, (item) => item.mtono ?? '');

        groupedByMto.forEach((mtono, items) {
          final List<CreateCustomLabelsData> subList = [];
          for (var item in items) {
            final double surplus = (item.totalQty ?? 0.0) - (item.qty ?? 0.0);
            subList.add(CreateCustomLabelsData(
              select: dataList.length == 1,
              // 假设 Data.size 是指整个列表长度
              size: item.size ?? '0',
              createdLabels: item.labelCount ?? 0,
              goodsTotal: item.totalQty ?? 0.0,
              createdGoods: item.qty ?? 0.0,
              surplusGoods: surplus,
              capacity: surplus < 100 ? surplus.toShowString() : "100",
              createGoods: surplus < 100 ? surplus.toShowString() : "100",
              instruct: mtono,
            ));
          }
          orderData.add(subList);
        });

        // 调用 success 回调并传入处理后的结果
        success(orderData);
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
    required List<List<LabelInfo>> selectLabels,
    required int labelType,
    required Function(int type) success,
  }) {
    httpPost(
      method: webApiSetPrintLabelFlag,
      loading: 'maintain_label_select_label_set_state'.tr,
      body: {
        'InterID': selectLabels[0][0].interID,
        'BarCodes': [for (var code in selectLabels[0]) code.barCode]
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
