import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/utils.dart';

import '../../bean/http/request/maintain_label_delete.dart';
import '../../bean/http/response/label_info.dart';
import '../../bean/http/response/maintain_material_info.dart';
import '../../bean/http/response/picking_bar_code_info.dart';
import '../../web_api.dart';
import '../../widget/dialogs.dart';
import 'maintain_label_state.dart';

class MaintainLabelLogic extends GetxController {
  final MaintainLabelState state = MaintainLabelState();

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDataList();
    });
    super.onInit();
  }

  refreshDataList() {
    httpGet(
      method: webApiGetLabelList,
      loading: '正在获取标签列表...',
      params: {'WorkCardID': state.interID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <LabelInfo>[
          for (var i = 0; i < response.data.length; ++i)
            LabelInfo.fromJson(response.data[i])
        ];
        state.typeBody.value = list[0].factoryType ?? '';
        if (list[0].materialOtherName?.isNotEmpty == true) {
          state.materialName.value = list[0]
                  .materialOtherName!
                  .firstWhere((v) => v.languageCode == 'zh')
                  .name ??
              '';
        }

        if (state.isMaterialLabel.value) {
          list.sort((a, b) => a.labelState().compareTo(b.labelState()));
          state.labelList.value = list;
        } else {
          state.isSingleLabel = list[0].packType ?? false;
          var group = <List<LabelInfo>>[];
          groupBy(list, (v) => v.barCode).forEach((k, v) {
            group.add(v);
          });
          state.labelGroupList.value = group;
        }
      } else {
        if (state.isMaterialLabel.value) {
          state.labelList.clear();
        } else {
          state.labelGroupList.clear();
        }
        errorDialog(content: response.message);
      }
    });
  }

  selectPrinted(bool c) {
    state.cbPrinted.value = c;
    if (state.isMaterialLabel.value) {
      for (var v in state.getLabelList().where((v) => v.isBillPrint ?? false)) {
        v.select = c;
      }
      state.labelList.refresh();
    } else {
      for (var v in state
          .getLabelGroupList()
          .where((v) => v[0].isBillPrint ?? false)) {
        for (var v2 in v) {
          v2.select = c;
        }
      }
      state.labelGroupList.refresh();
    }
  }

  selectUnprinted(bool c) {
    state.cbUnprinted.value = c;
    if (state.isMaterialLabel.value) {
      for (var v
          in state.getLabelList().where((v) => !(v.isBillPrint ?? false))) {
        v.select = c;
      }
      state.labelList.refresh();
    } else {
      for (var v in state
          .getLabelGroupList()
          .where((v) => !(v[0].isBillPrint ?? false))) {
        for (var v2 in v) {
          v2.select = c;
        }
      }
      state.labelGroupList.refresh();
    }
  }

  List<String> getSizeList() {
    var list = <String>['全部'];
    if (state.isMaterialLabel.value) {
      for (var v in state.labelList) {
        v.items?.forEach((v2) {
          if (!list.contains(v2.size)) {
            list.add(v2.size ?? '');
          }
        });
      }
    } else {
      for (var v in state.labelGroupList) {
        for (var v2 in v) {
          v2.items?.forEach((v3) {
            if (!list.contains(v3.size)) {
              list.add(v3.size ?? '');
            }
          });
        }
      }
    }

    return list;
  }

  List<String> getSelectData() {
    var list = <String>[];
    if (state.isMaterialLabel.value) {
      state.getLabelList().where((v) => v.select).forEach((data) {
        list.add(data.barCode ?? '');
      });
    } else {
      state.getLabelGroupList().forEach((g) {
        g.where((v) => v.select).forEach((data) {
          list.add(data.barCode ?? '');
        });
      });
    }
    return list;
  }

  createSingleLabel() {
    httpPost(
      method: webApiCreateSingleLabel,
      loading: '正在生成贴标...',
      params: {
        'InterID': state.interID,
        'PackTypeID': '478',
        'LabelType': 1,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        refreshDataList();
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  getBarCodeCount(bool isMix, Function(List<PickingBarCodeInfo>) callback) {
    _barCodeCount(isMix).then((response) {
      if (response.resultCode == resultSuccess) {
        callback.call([
          for (var i = 0; i < response.data.length; ++i)
            PickingBarCodeInfo.fromJson(response.data[i])
        ]);
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  Future<BaseData> _barCodeCount(bool isMix) {
    if (isMix) {
      return httpGet(
        method: webApiGetPackingListBarCodeCount,
        loading: '正在获取条码信息...',
        params: {
          'InterID': state.interID,
          'LabelType': 3,
          'UserID': userInfo?.userID,
        },
      );
    } else {
      if (state.isMaterialLabel.value) {
        return httpGet(
          method: webApiGetPackingListBarCodeCountBySize,
          loading: '正在获取条码信息...',
          params: {
            'InterID': state.interID,
            'UserID': userInfo?.userID,
          },
        );
      } else {
        return httpGet(
          method: webApiGetPackingListBarCodeCount,
          loading: '正在获取条码信息...',
          params: {
            'InterID': state.interID,
            'LabelType': 3,
            'UserID': userInfo?.userID,
          },
        );
      }
    }
  }

  deleteAllLabel() {
    httpPost(
      method: webApiCleanLabel,
      loading: '正在删除包装清单...',
      params: {
        'InterID': state.interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message, back: () => refreshDataList());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  deleteLabels(List<String> select) {
    httpPost(
      method: webApiDeleteLabels,
      loading: '正在删除标签...',
      body: MaintainLabelDelete(
        workCardID: state.interID.toString(),
        barCodes: select,
      ),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message, back: () => refreshDataList());
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  getMaterialProperties(
      Function(RxList<MaintainMaterialPropertiesInfo>) callback) {
    httpGet(
      method: webApiGetMaterialProperties,
      loading: '正在获取物料属性信息...',
      params: {
        'MaterialCode': state.materialCode,
        'InterID': state.interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        callback.call([
          for (var i = 0; i < response.data.length; ++i)
            MaintainMaterialPropertiesInfo.fromJson(response.data[i])
        ].obs);
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  getMaterialCapacity(Function(RxList<MaintainMaterialCapacityInfo>) callback) {
    httpGet(
      method: webApiGetMaterialCapacity,
      loading: '正在获取包装清单箱容配置信息...',
      params: {
        'InterID': state.interID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        callback.call([
          for (var i = 0; i < response.data.length; ++i)
            MaintainMaterialCapacityInfo.fromJson(response.data[i])
        ].obs);
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  getMaterialLanguages(
      Function(RxList<MaintainMaterialLanguagesInfo>) callback) {
    httpGet(
      method: webApiGetMaterialLanguages,
      loading: '正在获物料多语言信息...',
      params: {'MaterialCode': state.materialCode},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        callback.call([
          for (var i = 0; i < response.data.length; ++i)
            MaintainMaterialLanguagesInfo.fromJson(response.data[i])
        ].obs);
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
