import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/75w45h_fixed_label.dart';
import 'package:jd_flutter/widget/tsc_label_templates/75w_dynamic_label.dart';

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
    state.getLabelInfoList(error: (msg) => errorDialog(content: msg));
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
    var list = <String>['maintain_label_all'.tr];
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
    state.createSingleLabel(
      success: () => refreshDataList(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getBarCodeCount(bool isMix, Function(List<PickingBarCodeInfo>) callback) {
    state.barCodeCount(
      isMix: isMix,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteAllLabel() {
    state.deleteAllLabel(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteLabels(List<String> select) {
    state.deleteLabels(
      select: select,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialProperties(
    Function(RxList<MaintainMaterialPropertiesInfo>) callback,
  ) {
    state.getMaterialProperties(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialCapacity(
    Function(RxList<MaintainMaterialCapacityInfo>) callback,
  ) {
    state.getMaterialCapacity(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getMaterialLanguages(
    Function(RxList<MaintainMaterialLanguagesInfo>) callback,
  ) {
    state.getMaterialLanguages(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkLanguage({
    required Function(List<List<LabelInfo>>, List<String>) callback,
  }) {
    var languageList = <String>[];
    if (state.isMaterialLabel.value) {
      var select = state.labelList.where((v) => v.select).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
      for (var order in select) {
        order.materialOtherName
            ?.where((v) => v.languageName?.isNotEmpty == true)
            .forEach((v) {
          if (!languageList.contains(v.languageName)) {
            languageList.add(v.languageName!);
          }
        });
      }
      if (languageList.isEmpty) {
        errorDialog(content: 'maintain_label_label_language_empty_tips'.tr);
        return;
      }
      for (var language in languageList) {
        for (var label in select) {
          if (label.materialOtherName
                  ?.every((v) => v.languageName != language) ==
              true) {
            errorDialog(
              content: 'maintain_label_label_language_lack_tips'.trArgs([
                label.barCode ?? '',
                language,
              ]),
            );
            return;
          }
        }
      }
      callback.call([select], languageList);
    } else {
      var select =
          state.labelGroupList.where((v) => v.any((v2) => v2.select)).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label');
        return;
      }

      for (var list in select) {
        for (var order in list) {
          order.materialOtherName
              ?.where((v) => v.languageName?.isNotEmpty == true)
              .forEach((v) {
            if (!languageList.contains(v.languageName)) {
              languageList.add(v.languageName!);
            }
          });
        }
      }
      if (languageList.isEmpty) {
        errorDialog(content: 'maintain_label_label_language_empty_tips'.tr);
        return;
      }
      for (var language in languageList) {
        for (var list in select) {
          for (var label in list) {
            if (label.materialOtherName
                    ?.every((v) => v.languageName != language) ==
                true) {
              errorDialog(
                content: 'maintain_label_label_language_lack_tips'.trArgs([
                  label.barCode ?? '',
                  language,
                ]),
              );
              return;
            }
          }
        }
      }
      callback.call(select, languageList);
    }
  }

  Function(List<Widget>) labelsCallback = (label) {
    if (label.length > 1) {
      Get.to(() => PreviewLabelList(labelWidgets: label));
    } else {
      Get.to(() => PreviewLabel(labelWidget: label[0]));
    }
  };

  printLabel({
    required List<List<LabelInfo>> select,
    String language = '',
  }) {
    if (state.isMaterialLabel.value) {
      var sizeList = <String>[];
      var insNum = <String>[];
      for (var order in select[0]) {
        for (var item in order.items ?? <LabelSizeInfo>[]) {
          if (item.billNo?.isNotEmpty == true &&
              !insNum.contains(item.billNo)) {
            insNum.add(item.billNo!);
          }
          if (item.size?.isNotEmpty == true && !sizeList.contains(item.size)) {
            insNum.add(item.size!);
          }
        }
      }
      if (insNum.length <= 1 && sizeList.length <= 1) {
        createMaterialFixedLabel(
          language: language,
          list: select[0],
          labels: labelsCallback,
        );
      } else {
        createSizeMaterialDynamicLabel(
          language: language,
          list: select[0],
          labels: labelsCallback,
        );
      }
    } else if (state.isSingleLabel) {
      createSingleSizeFixedLabel(
        language: language,
        list: select,
        labels: labelsCallback,
      );
    } else {
      createMixDynamicLabel(
        language: language,
        list: select,
        labels: labelsCallback,
      );
    }
  }

  //物料标
  createMaterialFixedLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var languageInfo =
          data.materialOtherName!.firstWhere((v) => v.languageName == language);
      if (languageInfo.languageCode == 'zh') {
        labelList.add(maintainLabelMaterialChineseFixedLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          materialCode: data.materialCode ?? '',
          materialName: data.materialName ?? '',
          pageNumber: languageInfo.pageNumber ?? '',
          qty: data.items?.isEmpty == true
              ? 0
              : data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
        ));
      } else {
        labelList.add(maintainLabelMaterialEnglishFixedLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          materialCode: data.materialCode ?? '',
          materialName: data.materialName ?? '',
          grossWeight: data.grossWeight ?? 0,
          netWeight: data.netWeight ?? 0,
          meas: data.meas ?? '',
          pageNumber: languageInfo.pageNumber ?? '',
          qty: data.items?.isEmpty == true
              ? 0
              : data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
        ));
      }
    }
    labels.call(labelList);
  }

  //动态标
  createSizeMaterialDynamicLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      //标签语言类型
      var languageInfo =
          data.materialOtherName!.firstWhere((v) => v.languageName == language);

      //表格列表
      Map<String, List<List<String>>> map = {};
      groupBy(data.items ?? <LabelSizeInfo>[], (v) => v.billNo ?? '').forEach(
        (billNo, sizeInfo) {
          map[billNo] = [
            for (var data in sizeInfo)
              [data.size ?? '', data.qty.toShowString()]
          ];
        },
      );
      if (languageInfo.languageCode == 'zh') {
        labelList.add(maintainLabelSizeMaterialChineseDynamicLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          total: data.items.isNullOrEmpty()
              ? 0
              : data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          materialCode: data.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      } else {
        maintainLabelSizeMaterialEnglishDynamicLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          materialCode: data.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          grossWeight: data.grossWeight ?? 0,
          netWeight: data.netWeight ?? 0,
          meas: data.meas ?? '',
          total: data.items.isNullOrEmpty()
              ? 0
              : data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        );
      }
    }
    labels.call(labelList);
  }

  //固定单码标
  createSingleSizeFixedLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var languageInfo = data.first.materialOtherName!
          .firstWhere((v) => v.languageName == language);
      if (languageInfo.languageCode == 'zh') {
        labelList.add(maintainLabelSingleSizeChineseFixedLabel(
          barCode: data.first.barCode ?? '',
          factoryType: data.first.factoryType ?? '',
          billNo: data.first.billNo ?? '',
          materialCode: data.first.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          size: data.first.items?.first.size ?? '',
          pageNumber: languageInfo.pageNumber ?? '',
          date: languageInfo.deliveryDate ?? '',
          unit: languageInfo.unitName ?? '',
        ));
      } else {
        labelList.add(maintainLabelSingleSizeEnglishFixedLabel(
          barCode: data.first.barCode ?? '',
          factoryType: data.first.factoryType ?? '',
          billNo: data.first.billNo ?? '',
          materialCode: data.first.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          grossWeight: data.first.grossWeight ?? 0,
          netWeight: data.first.netWeight ?? 0,
          meas: data.first.meas ?? '',
          qty: data.first.items?.first.qty ?? 0,
          pageNumber: languageInfo.pageNumber ?? '',
          size: data.first.items?.first.size ?? '',
        ));
      }
    }
    labels.call(labelList);
  }

  //合并动态标签
  createMixDynamicLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      //标签语言类型
      var languageInfo = data.first.materialOtherName!
          .firstWhere((v) => v.languageName == language);

      var insList = <LabelSizeInfo>[];
      for (var item in data) {
        if (!item.items.isNullOrEmpty()) {
          insList.addAll(item.items!);
        }
      }
      //表格列表
      Map<String, List<List<String>>> map = {};
      groupBy(insList, (v) => v.billNo ?? '').forEach((billNo, sizeInfo) {
        map[billNo] = [
          for (var data in sizeInfo) [data.size ?? '', data.qty.toShowString()]
        ];
      });

      if (languageInfo.languageCode == 'zh') {
        labelList.add(maintainLabelMixChineseDynamicLabel(
          barCode: data.first.barCode ?? '',
          factoryType: data.first.factoryType ?? '',
          billNo: data.first.billNo ?? '',
          total: insList.isEmpty
              ? 0
              : insList.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          materialCode: data.first.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      } else {
        labelList.add(maintainLabelMixEnglishDynamicLabel(
          barCode: data.first.barCode ?? '',
          factoryType: data.first.factoryType ?? '',
          materialCode: data.first.materialCode ?? '',
          materialName: languageInfo.name ?? '',
          grossWeight: data.first.grossWeight ?? 0,
          netWeight: data.first.netWeight ?? 0,
          meas: data.first.meas ?? '',
          total: insList.isEmpty
              ? 0
              : insList.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      }
    }
    labels.call(labelList);
  }

  List<Widget> createSubItem({
    required List<LabelInfo> data,
    required Widget Function(
      String text1,
      String text2,
      String text3,
      int type,
    ) subItem,
  }) {
    var widgetList = <Widget>[
      subItem.call(
        'maintain_label_sub_item_instruction'.tr,
        'maintain_label_sub_item_size'.tr,
        'maintain_label_sub_item_packing_qty'.tr,
        1,
      )
    ];
    groupBy(data, (v) => v.items?[0].size).forEach((k, v) {
      for (var v2 in v) {
        widgetList.add(subItem.call(
          v2.items![0].billNo ?? 'maintain_label_sub_item_instruction_error'.tr,
          v2.items![0].size ?? '',
          v2.items![0].qty.toShowString(),
          2,
        ));
      }
      if (state.isSingleLabel) {
        var subtotal = 0.0;
        for (var v2 in v) {
          subtotal = subtotal.add(v2.items![0].qty ?? 0.0);
        }
        widgetList.add(subItem.call(
          '',
          k!,
          v
              .map((v2) => v2.items?[0].qty ?? 0)
              .reduce((a, b) => a.add(b))
              .toShowString(),
          3,
        ));
      }
    });
    return widgetList;
  }

}
