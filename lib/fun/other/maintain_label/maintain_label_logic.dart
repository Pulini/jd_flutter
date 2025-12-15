import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/create_custom_label_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/constant.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_110w.dart';
import 'package:jd_flutter/widget/tsc_label_templates/fixed_label_75w45h.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_75w.dart';

import 'maintain_label_dialogs.dart';
import 'maintain_label_state.dart';

enum LabelCreateType {
  single,
  mixed,
  customOneOrder,
  customOrders,
}

const onlyCustomProcesses = {'BL', 'ZL', 'YT'};
const allTypeProcesses = {
  'PQ',
  'ZC',
  'ZHUS',
  'ZDJG',
  'HDD',
  'LLDM',
  'BZD',
  'BFST',
  'TYT',
  'ZD',
  'BGDTP',
  'BJC',
  'ZS',
  'MLCD',
  'MLCD1',
  'MLCD2',
  'MLCD3',
  'DLCD',
  'DDCD',
  'BDD',
  'GP'
};
const mixAndCustomProcesses = {'GBJG'};

class MaintainLabelLogic extends GetxController {
  final MaintainLabelState state = MaintainLabelState();

  var pu = PrintUtil();

  int getLabelType(LabelCreateType createType) {
    int type = -1;
    if (onlyCustomProcesses.contains(state.sapProcessName)) {
      if (createType == LabelCreateType.customOneOrder ||
          createType == LabelCreateType.customOrders) {
        type = 101;
      }
    } else if (allTypeProcesses.contains(state.sapProcessName)) {
      type = createType == LabelCreateType.single ||
              createType == LabelCreateType.customOneOrder
          ? 102
          : 103;
    } else if (mixAndCustomProcesses.contains(state.sapProcessName)) {
      if (createType != LabelCreateType.single) type = 103;
    }
    return type;
  }

  void refreshDataList() {
    state.getLabelInfoList(
      success: (List<LabelInfo> list) {

        state.typeBody.value = list.first.subList!.first.factoryType ?? '';
        var materials = [];
        var typeBodyList = [];
        for (var v in list) {
          for (var v2 in v.subList!) {
            if (!materials.contains(v2.getMaterialLanguage(state.language))) {
              materials.add(v2.getMaterialLanguage(state.language));
            }
            if (!typeBodyList.contains(v2.factoryType)) {
              typeBodyList.add(v2.factoryType);
            }
          }
        }
        state.materialName.value =
            materials.length > 1 ? materials.join(',') : materials.first;
        state.typeBody.value = typeBodyList.length > 1
            ? typeBodyList.join(',')
            : typeBodyList.first;
        if (state.isMaterialLabel.value) {
          list.sort((a, b) => a.labelState().compareTo(b.labelState()));
          state.labelList.value = list;
        } else {
          state.isSingleLabel = list.first.packType ?? false;
          state.labelGroupList.value =
              groupBy(list, (v) => v.barCode).values.toList();
        }
        debugPrint('isMaterialLabel=${state.isMaterialLabel.value} labelList=${state.labelList.length} labelGroupList=${state.labelGroupList.length}');
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void selectPrinted(bool c) {
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

  void selectUnprinted(bool c) {
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
        for (var v2 in v.subList!) {
          for (var v3 in v2.items!) {
            if (!list.contains(v3.size)) {
              list.add(v3.size ?? '');
            }
          }
        }
      }
    } else {
      for (var v in state.labelGroupList) {
        for (var v2 in v) {
          for (var v3 in v2.subList!) {
            for (var v4 in v3.items!) {
              if (!list.contains(v4.size)) {
                list.add(v4.size ?? '');
              }
            }
          }
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

  void createSingleLabel() {
    state.createSingleLabel(
      success: () => refreshDataList(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getBarCodeCount(Function(List<List<CreateCustomLabelsData>>) callback) {
    state.getOrderDetailsForCustom(
      success: (dataList) {
        final List<List<CreateCustomLabelsData>> orderData = [];
        groupBy(dataList, (item) => item.mtono ?? '').forEach((mtono, items) {
          final List<CreateCustomLabelsData> subList = [];
          for (var item in items) {
            final double surplus = (item.totalQty ?? 0.0) - (item.qty ?? 0.0);
            subList.add(CreateCustomLabelsData(
              select: dataList.length == 1,
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
        callback.call(orderData);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getBarCodeCountMix(Function(List<List<PickingBarCodeInfo>>) callback) {
    state.getOrderDetailsForMix(
      success: (dataList) {
        final List<List<PickingBarCodeInfo>> orderData = [];
        groupBy(dataList, (item) => item.size ?? '').forEach((size, items) {
          if (items.map((v) => v.surplusQty).reduce((a, b) => a.add(b)) > 0) {
            orderData.add(items.where((v) => v.surplusQty > 0).toList());
          }
        });
        callback.call(orderData);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteAllLabel() {
    state.deleteAllLabel(
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void deleteLabels(List<String> select) {
    state.deleteLabels(
      select: select,
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshDataList(),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getMaterialProperties(
    Function(RxList<MaintainMaterialPropertiesInfo>) callback,
  ) {
    state.getMaterialProperties(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getMaterialCapacity(
    Function(RxList<MaintainMaterialCapacityInfo>) callback,
  ) {
    state.getMaterialCapacity(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getMaterialLanguages(
    Function(RxList<MaintainMaterialLanguagesInfo>) callback,
  ) {
    state.getMaterialLanguages(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void checkPrintType() {
    var select = <LabelInfo>[];
    if (state.isMaterialLabel.value) {
      select = state.labelList.where((v) => v.select).toList();
    } else {
      for (var data in state.labelGroupList) {
        if (data.first.select == true) {
          select.addAll(data);
        }
      }
    }
    if (select.isEmpty) {
      errorDialog(content: 'maintain_label_select_label'.tr);
      return;
    }
    if (select.first.labelType == 1002) {
      state.setLabelState(
        selectLabels: select,
        success: () =>
            createIndonesiaLabel(list: select, labels: labelsCallback),
      );
    } else if (select.first.labelType == 1003) {
      state.setLabelState(
        selectLabels: select,
        success: () =>
            createMyanmarLabel(list: select, labels: labelsCallback),
      );
    } else {
      var languageList = <String>[];
      var labelType = <String>[];
      for (var order in select) {
        for (var v in order.subList!) {
          v.materialOtherName
              ?.where((v) => !v.languageName.isNullOrEmpty())
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
        for (var label in select) {
          for (var v in label.subList!) {
            if (v.materialOtherName?.every((v) => v.languageName != language) ==
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
      for (var type in select) {
        if (!labelType.contains(type.labelType.toString())) {
          labelType.add(type.labelType.toString());
        }
      }
      if (labelType.length > 1) {
        errorDialog(content: 'maintain_label_select_label_not_same'.tr);
        return;
      }
      if (select.every((v) =>
          v.labelType != 101 && v.labelType != 102 && v.labelType != 103)) {
        showSnackBar(
          message: 'maintain_label_error'.trArgs(
            [select.map((v) => v.labelType ?? '').join('、')],
          ),
        );
      } else {
        if (languageList.length > 1) {
          selectLanguageDialog(
            list: languageList,
            callback: (s) => state.setLabelState(
              selectLabels: select,
              success: () => printLabel(
                select: select,
                language: s,
                type:  select.first.labelType!,
              ),
            ),
          );
        } else {
          state.setLabelState(
            selectLabels: select,
            success: () => printLabel(
              select: select,
              language: languageList.isEmpty ? '' : languageList.first,
              type:  select.first.labelType!,
            ),
          );
        }
      }
    }
  }

  Function(List<Widget>, bool cut) labelsCallback = (label, cut) {
    if (label.length > 1) {
      Get.to(() => PreviewLabelList(labelWidgets: label, isDynamic: cut));
    } else {
      Get.to(() => PreviewLabel(labelWidget: label[0], isDynamic: cut));
    }
  };

  void printLabel({
    required int type,
    required List<LabelInfo> select,
    required String language,
  }) {
    switch (type) {
      case 101:
        createMaterialLabel(
          language: language,
          list: select,
          labels: labelsCallback,
        );
        break;
      case 102:
        createFixedLabel(
          language: language,
          list: select,
          labels: labelsCallback,
        );
        break;
      case 103:
        createGroupDynamicLabel(
          language: language,
          list: select,
          labels: labelsCallback,
        );
        break;
    }
  }

  //单一物料无尺码标
  void createNoSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.subList!.first.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        instructionNo: data.subList!.first.billNo ?? '',
        materialList: [],
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.subList!.first.meas ?? '',
        volume: data.volume ?? '',
        supplier: data.departName ?? '',
        manufactureDate: data.manufactureDate ?? '',
        hasNotes: false,
        notes: '',
      ));
    }
    labels.call(labelList, true);
  }

  ///单一物料多尺码标
  void createMultipleSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicSizeMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.subList!.first.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        materialList: createSizeList(
          label: data,
          sizeTitle: 'Size',
          totalTitle: 'Total',
        ),
        instructionNo: '',
        materialCode: '',
        size: '',
        inBoxQty: data.totalQty().toShowString(),
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.subList!.first.meas ?? '',
        volume: data.volume ?? '',
        supplier: data.departName ?? '',
        manufactureDate: data.manufactureDate ?? '',
        hasNotes: false,
        notes: '',
      ));
    }
    labels.call(labelList, true);
  }

  Map<String, List> createSizeList({
    required LabelInfo label,
    required String sizeTitle,
    required String totalTitle,
  }) {
    var materials = <String, List>{};
    if (label.subList!
        .any((v) => v.items!.any((v2) => v2.size?.isNotEmpty == true))) {
      var sizeList = <String>[];
      for (var sub in label.subList!) {
        for (var label in sub.items!) {
          if (!sizeList.contains(label.size)) {
            sizeList.add(label.size ?? '');
          }
        }
      }
      sizeList.sort();
      materials[sizeTitle] = [...sizeList, totalTitle];
      groupBy(
        label.subList!,
        (v) => v.billNo ?? '',
      ).forEach((k, sub) {
        var itemList = <LabelSizeInfo>[];
        for (var v in sub) {
          itemList.addAll(v.items!);
        }
        var list = [];
        for (var size in sizeList) {
          try {
            list.add(itemList
                .firstWhere((label) => label.size == size)
                .qty
                .toShowString());
          } on StateError catch (_) {
            list.add(' ');
          }
        }
        list.add(itemList
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString());
        materials[k] = list;
      });
    }
    return materials;
  }

  //单一物料单尺码标
  void createSingleSizeLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicSizeMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.subList!.first.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        materialList: {},
        instructionNo: data.subList!.first.billNo ?? '',
        materialCode: data.subList!.first.materialCode ?? '',
        size: data.subList!.first.items!.first.size ?? '',
        inBoxQty: data.subList!.first.items!.first.qty.toShowString(),
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.subList!.first.meas ?? '',
        volume: data.volume ?? '',
        supplier: data.departName ?? '',
        manufactureDate: data.manufactureDate ?? '',
        hasNotes: false,
        notes: '',
      ));
    }
    labels.call(labelList, true);
  }

  //物料标
  Future<void> createMaterialLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) async {
    if (state.isShowPreview.value) {
      var labelList = <Widget>[];
      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        if (languageInfo.languageCode == 'zh') {
          labelList.add(maintainLabelMaterialChineseFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: data.subList!.first.materialName ?? '',
            pageNumber: languageInfo.pageNumber ?? '',
            qty: data.subList!.first.items!
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b)),
            unit: languageInfo.unitName ?? '',
          ));
        } else {
          labelList.add(maintainLabelMaterialEnglishFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: data.subList!.first.materialName ?? '',
            grossWeight: data.grossWeight!,
            netWeight: data.netWeight!,
            meas: data.subList!.first.meas!,
            pageNumber: languageInfo.pageNumber!,
            qty: data.subList!.first.items!
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b)),
            unit: languageInfo.unitName ?? '',
          ));
        }
      }
      labels.call(labelList, false);
    } else {
      //不显示预览
      var labelList = <List<Uint8List>>[];
      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        labelList.add(await labelMultipurposeFixed(
          qrCode: data.barCode ?? '',
          title: data.subList!.first.factoryType ?? '',
          subTitle: data.subList!.first.billNo ?? '',
          content: '(${data.subList!.first.materialCode})${languageInfo.name}',
          subContent1: languageInfo.languageCode == 'zh'
              ? ''
              : 'GW:${data.grossWeight.toShowString()}KG   NW:${data.netWeight.toShowString()}KG',
          subContent2: languageInfo.languageCode == 'zh'
              ? ''
              : 'MEAS:${data.subList!.first.meas}',
          bottomLeftText1: languageInfo.pageNumber ?? '',
          bottomRightText1: data.subList!.first.items!
              .map((v) => v.qty ?? 0)
              .reduce((a, b) => a.add(b))
              .toShowString(),
          bottomRightText2: languageInfo.unitName ?? '',
          speed: spGet(spSavePrintSpeed) ?? 5.0,
          density: spGet(spSavePrintDensity) ?? 10.0,
        ));
      }
      pu.printLabelList(
        labelList: labelList,
        start: () {
          loadingShow('正在下发标签...');
        },
        progress: (i, j) {
          loadingShow('正在下发标签($i/$j)');
        },
        finished: (success, fail) {
          successDialog(
              title: '标签下发结束',
              content: '完成${success.length}张, 失败${fail.length}张',
              back: () {});
        },
      );
    }
  }

  //固定单码标
  void createFixedLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) async {
    if (state.isShowPreview.value) {
      var labelList = <Widget>[];

      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);

        if (languageInfo.languageCode == 'zh') {
          labelList.add(maintainLabelSingleSizeChineseFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: data.subList!.first.materialName ?? '',
            size: data.subList!.first.items?[0].size ?? '',
            pageNumber: languageInfo.pageNumber ?? '',
            date: languageInfo.deliveryDate ?? '',
            unit: (data.subList!.first.items?[0].qty.toShowString() ?? '') +
                (languageInfo.unitName ?? ''),
          ));
        } else {
          labelList.add(maintainLabelSingleSizeEnglishFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: languageInfo.name ?? '',
            grossWeight: data.grossWeight ?? 0.0,
            netWeight: data.netWeight ?? 0.0,
            meas: data.subList!.first.meas ?? '',
            qty: data.subList!.first.items?[0].qty ?? 0.0,
            pageNumber: languageInfo.pageNumber ?? '',
            size: data.subList!.first.items?[0].size ?? '',
            unit: languageInfo.unitName ?? '',
          ));
        }
      }
      labels.call(labelList, false);
    } else {
      //不显示预览
      var labelList = <List<Uint8List>>[];
      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        labelList.add(await labelMultipurposeFixed(
          qrCode: data.barCode ?? '',
          title: data.subList!.first.factoryType ?? '',
          subTitle: data.subList!.first.billNo ?? '',
          subTitleWrap: false,
          content:languageInfo.languageCode == 'zh'? '(${data.subList!.first.materialCode})${data.subList!.first.materialName}' : (languageInfo.name ?? ''),
          subContent1: languageInfo.languageCode == 'zh'
              ? ''
              : 'GW:${data.grossWeight.toShowString()}KG  NW:${data.netWeight.toShowString()}KG',
          subContent2: languageInfo.languageCode == 'zh'
              ? ''
              : 'MEAS:${data.subList!.first.meas}',
          bottomLeftText1: languageInfo.languageCode == 'zh'
              ? ('${data.subList!.first.items?[0].size}#' ?? '')
              : ((data.subList!.first.items?[0].qty.toShowString() ?? '') +
                  (languageInfo.unitName ?? '')),
          bottomMiddleText1: languageInfo.pageNumber ?? '',
          bottomMiddleText2: languageInfo.languageCode == 'zh'
              ? (languageInfo.deliveryDate ?? '')
              : 'Made in China',
          bottomRightText1: languageInfo.languageCode == 'zh'
              ? ((data.subList!.first.items?[0].qty.toShowString() ?? '') +
                  (languageInfo.unitName ?? ''))
              : ('${data.subList!.first.items?[0].size}#'),
          speed: spGet(spSavePrintSpeed) ?? 5.0,
          density: spGet(spSavePrintDensity) ?? 10.0,
        ));
      }
      pu.printLabelList(
        labelList: labelList,
        start: () {
          loadingShow('正在下发标签...');
        },
        progress: (i, j) {
          loadingShow('正在下发标签($i/$j)');
        },
        finished: (success, fail) {
          successDialog(
              title: '标签下发结束',
              content: '完成${success.length}张, 失败${fail.length}张',
              back: () {});
        },
      );
    }
  }

  //合并动态标签
  Future<void> createGroupDynamicLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) async {
    if (state.isShowPreview.value) {
      var labelList = <Widget>[];
      for (var data in list) {
        //标签语言类型
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        var ins = <String, List<LabelSizeInfo>>{};
        groupBy(data.subList!, (v) => v.billNo).forEach((k, v) {
          var insList = <LabelSizeInfo>[];
          for (var v2 in v) {
            insList.addAll(v2.items!);
          }
          ins[k ?? ''] = insList;
        });

        //表格列表
        Map<String, List<List<String>>> map = {};
        ins.forEach((k, v1) {
          map[k] = [
            for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
          ];
        });

        if (languageInfo.languageCode == 'zh') {
          labelList.add(maintainLabelSizeMaterialChineseDynamicLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.departName ?? '',
            total: data.subList!.first.items!
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b)),
            unit: languageInfo.unitName ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: data.subList!.first.materialName ?? '',
            map: map,
            pageNumber: languageInfo.pageNumber ?? '',
            deliveryDate: languageInfo.deliveryDate ?? '',
          ));
        } else {
          labelList.add(maintainLabelMixEnglishDynamicLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: languageInfo.name ?? '',
            grossWeight: data.grossWeight ?? 0.0,
            netWeight: data.netWeight ?? 0.0,
            meas: data.subList!.first.meas ?? '',
            total: data.subList!.first.items!
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b)),
            unit: languageInfo.unitName ?? '',
            map: map,
            pageNumber: languageInfo.pageNumber ?? '',
            deliveryDate: languageInfo.deliveryDate ?? '',
          ));
        }
      }
      labels.call(labelList, true);
    } else {
      //不显示预览
      var labelList = <List<Uint8List>>[];
      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        var ins = <String, List<LabelSizeInfo>>{};
        groupBy(data.subList!, (v) => v.billNo).forEach((k, v) {
          var insList = <LabelSizeInfo>[];
          for (var v2 in v) {
            insList.addAll(v2.items!);
          }
          ins[k ?? ''] = insList;
        });
        //表格列表
        Map<String, List<List<String>>> map = {};
        ins.forEach((k, v1) {
          map[k] = [
            for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
          ];
        });
        labelList.add(await labelMultipurposeDynamic(
          isCut: true,
          qrCode: data.barCode ?? '',
          title: data.subList!.first.factoryType ?? '',
          subTitle: languageInfo.languageCode == 'zh'
              ? (data.departName ?? '')
              : '(${data.subList!.first.materialCode})${languageInfo.name}',
          tableFirstLineTitle:
              languageInfo.languageCode == 'zh' ? '尺码' : 'Size',
          tableLastLineTitle:
              languageInfo.languageCode == 'zh' ? '合计' : 'Total',
          tableTitle: languageInfo.languageCode == 'zh'
              ? ''
              : 'GW:${data.grossWeight.toShowString()}KG  NW:${data.netWeight.toShowString()}KG',
          tableTitleTips: languageInfo.languageCode == 'zh'
              ? '${data.subList!.first.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)).toShowString()}${languageInfo.unitName ?? ''}'
              : '',
          tableSubTitle: languageInfo.languageCode == 'zh'
              ? '(${data.subList!.first.materialCode})${languageInfo.name}'
              : 'MEAS:${data.subList!.first.meas}     ${data.subList!.first.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)).toShowString()}${languageInfo.unitName}',
          tableData: map,
          bottomLeftText1: languageInfo.pageNumber ?? '',
          bottomLeftText2:
              languageInfo.languageCode == 'zh' ? '' : 'Made in China',
          bottomRightText1: languageInfo.deliveryDate ?? '',
          bottomRightText2:
              languageInfo.languageCode == 'zh' ? '' : 'Gold Emperor',
          speed: spGet(spSavePrintSpeed) ?? 5.0,
          density: spGet(spSavePrintDensity) ?? 10.0,
        ));
      }
      pu.printLabelList(
        labelList: labelList,
        start: () {
          loadingShow('正在下发标签...');
        },
        progress: (i, j) {
          loadingShow('正在下发标签($i/$j)');
        },
        finished: (success, fail) {
          successDialog(
              title: '标签下发结束',
              content: '完成${success.length}张, 失败${fail.length}张',
              back: () {});
        },
      );
    }
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
    for (var label in data) {
      for (var sub in label.subList!) {
        for (var v2 in sub.items!) {
          widgetList.add(subItem.call(
            sub.billNo ?? 'maintain_label_sub_item_instruction_error'.tr,
            v2.size ?? '',
            v2.qty.toShowString(),
            2,
          ));
        }
        if (!state.isSingleLabel) {
          widgetList.add(subItem.call(
            '',
            '小计',
            sub.totalQty().toShowString(),
            3,
          ));
        }
      }
    }

    if (!state.isSingleLabel) {
      widgetList.add(subItem.call(
        '',
        '合计',
        data
            .map((v2) => v2.totalQty())
            .reduce((a, b) => a.add(b))
            .toShowString(),
        4,
      ));
    }
    return widgetList;
  }

  String getPartOrderMaterial() {
    var materialList = <String>[];
    for (var v in state.labelList) {
      for (var sub in v.subList!) {
        if (!sub.materialName.isNullOrEmpty()) {
          if (!materialList.contains(sub.materialName)) {
            materialList.add(sub.materialName!);
          }
        }
      }
    }
    return materialList.join('、');
  }

//缅甸标
  void createMyanmarLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var qty = '';
      var size = '';
      var dataList = <String, List>{};
      if (data.subList!.first.items!.isEmpty) {
        // 无尺码
      } else if (data.subList!.first.items!.length == 1) {
        //单尺码
        qty = data.subList!.first.items![0].qty!.toShowString();
        size = data.subList!.first.items![0].size ?? '';
      } else if (data.subList!.first.items!.length > 1) {
        //多尺码
        qty = data.subList!.first.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
        dataList = createSizeList(
          label: data,
          sizeTitle: '尺码/Size/ukuran',
          totalTitle: '总计/total',
        );
      }
      labelList.add(dynamicSizeMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.subList!.first.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        materialList: dataList,
        instructionNo: data.subList!.first.billNo ?? '',
        materialCode: data.subList!.first.materialCode ?? '',
        size: size,
        inBoxQty: qty,
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.subList!.first.meas ?? '',
        volume: data.volume ?? '',
        supplier: '供应商123456',
        manufactureDate: data.manufactureDate ?? '',
        hasNotes: true,
        notes: data.notes ?? '',
      ));
    }
    labels.call(labelList, true);
  }

//印尼标
  void createIndonesiaLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var qty = '';
      var typeBody = '';
      var dataList = <String, List>{};
      if (data.subList!.first.items!.isEmpty) {
        // 无尺码
      } else if (data.subList!.first.items!.length == 1) {
        //单尺码
        typeBody = (data.subList!.first.factoryType ?? '') +
            (data.subList!.first.items![0].size ?? '');
        qty = data.subList!.first.items![0].qty!.toShowString();
      } else if (data.subList!.first.items!.length > 1) {
        //多尺码
        typeBody = data.subList!.first.factoryType ?? '';
        qty = data.subList!.first.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
        dataList = createSizeList(
          label: data,
          sizeTitle: '尺码/Size/ukuran',
          totalTitle: '总计/total',
        );
      }
      labelList.add(dynamicSizeMaterialLabel1095n1096(
        labelID: data.barCode ?? '',
        productName: 'productName',
        orderType: 'orderType',
        typeBody: typeBody,
        trackNo: data.trackNo ?? '',
        instructionNo: data.subList!.first.billNo ?? '',
        generalMaterialNumber: data.subList!.first.materialCode ?? '',
        materialDescription: data.subList!.first.materialName ?? '',
        materialList: dataList,
        inBoxQty: qty,
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceID: data.pieceID ?? '',
        pieceNo: data.pieceNo ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.subList!.first.meas ?? '',
        volume: data.volume ?? '',
        supplier: '',
        manufactureDate: data.manufactureDate ?? '',
        consignee: '',
        hasNotes: true,
        notes: data.notes ?? '',
      ));
    }
    labels.call(labelList, true);
  }
}
