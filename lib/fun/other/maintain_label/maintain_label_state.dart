import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

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
  var filterSize = '全部'.obs;

  MaintainLabelState() {
    materialCode = Get.arguments['materialCode'];
    interID = Get.arguments['interID'];
    isMaterialLabel.value = Get.arguments['isMaterialLabel'];
  }

  List<LabelInfo> getLabelList() {
    return filterSize.value == '全部'
        ? labelList
        : labelList
            .where((v) => v.items!.any((v2) => v2.size == filterSize.value))
            .toList();
  }

  List<List<LabelInfo>> getLabelGroupList() {
    return filterSize.value == '全部'
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
      loading: '正在获取标签列表...',
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
          if (isMaterialLabel.value) {
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
      loading: '正在生成贴标...',
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
        loading: '正在获取条码信息...',
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
          loading: '正在获取条码信息...',
          params: {
            'InterID': interID,
            'UserID': userInfo?.userID,
          },
        );
      } else {
        http = httpGet(
          method: webApiGetPackingListBarCodeCount,
          loading: '正在获取条码信息...',
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
      loading: '正在删除包装清单...',
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
      loading: '正在删除标签...',
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
      loading: '正在获取物料属性信息...',
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
      loading: '正在获取包装清单箱容配置信息...',
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
      loading: '正在获物料多语言信息...',
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
}
