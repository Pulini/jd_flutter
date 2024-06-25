import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/utils.dart';

import '../../bean/http/response/label_info.dart';
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
        var list = <LabelInfo>[];
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(LabelInfo.fromJson(jsonList[i]));
        }
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
      state.isMaterialLabel.refresh();
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
      state.isMaterialLabel.refresh();
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

  getBarCodeCount(Function(List<List<PickingBarCodeInfo>>)callback) {
    httpGet(
      method: webApiGetPackingListBarCodeCount,
      loading: '正在获取条码信息...',
      params: {
        'InterID': state.interID,
        'LabelType': 3,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <PickingBarCodeInfo>[];
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(PickingBarCodeInfo.fromJson(jsonList[i]));
          list.add(PickingBarCodeInfo.fromJson(jsonList[i]));
          list.add(PickingBarCodeInfo.fromJson(jsonList[i]));
        }
        var group=<List<PickingBarCodeInfo>>[];
        groupBy(list, (v) => v.size).forEach((key, value) {
          group.add(value);
        });
        callback.call(group);
      } else {
        errorDialog(content: response.message);
      }
    });
  }
}
