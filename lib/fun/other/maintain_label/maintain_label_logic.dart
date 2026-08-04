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
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_create_custom_view.dart';
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_create_mix_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/print_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
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

  Function(List<Widget>, bool cut) labelsCallback = (label, cut) {
    if (label.length > 1) {
      Get.to(() => PreviewLabelList(labelWidgets: label, isDynamic: cut));
    } else {
      Get.to(() => PreviewLabel(labelWidget: label.first, isDynamic: cut));
    }
  };

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
        debugPrint(
            'isMaterialLabel=${state.isMaterialLabel.value} labelList=${state.labelList.length} labelGroupList=${state.labelGroupList.length}');
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

  //贴标维护，快捷设置满箱
  void setFull() {
    if (state.createCustomLabelsData.isNotEmpty) {
      for (var v in state.createCustomLabelsData) {
        if (v.isSelect.value == true) {
          // 按每箱容量 capacity 向下取整（去掉不满一箱的零头）；容量异常(<=0)时保持原剩余货数，避免除零/NaN
          final cap = v.capacity.value;
          final fullValue = cap > 0
              ? ((v.surplusGoods / cap).floor() * cap).toDouble()
              : v.surplusGoods;
          v.createGoodsController!.text = fullValue.toShowString();
          v.createGoods.value = fullValue;
        }
      }
      state.createCustomLabelsData.refresh();
    }
  }

  void toCustomLabelCreate() {
    state.getOrderDetailsForCustom(
      success: (dataList) {
        final List<List<CreateCustomLabelsData>> orderData = [];
        groupBy(dataList, (item) => item.mtono ?? '').forEach((ins, items) {
          final List<CreateCustomLabelsData> subList = [];
          for (var item in items) {
            final double surplus = (item.totalQty ?? 0.0) - (item.qty ?? 0.0);
            subList.add(CreateCustomLabelsData(
              isSelect: dataList.length == 1,
              size: item.size ?? '0',
              createdLabels: item.labelCount ?? 0,
              goodsTotal: item.totalQty ?? 0.0,
              createdGoods: item.qty ?? 0.0,
              surplusGoods: surplus,
              capacity: surplus < 100 ? surplus : 100,
              createGoods: surplus < 100 ? surplus : 100,
              instruct: ins,
            ));
          }
          orderData.add(subList);
        });
        orderData.sort((a, b) => (a.first.size).compareTo(b.first.size));

        if (orderData.length > 1) {
          selectInstructDialog(
            orderData,
            selectCallback: (list) {
              state.createCustomLabelsData.value = list;
              _toCreateCustomLabelPage(
                  getLabelType(LabelCreateType.customOneOrder));
            },
            allCallback: () {
              state.createCustomLabelsData.value =
                  _createNewDataList(orderData);
              _toCreateCustomLabelPage(
                  getLabelType(LabelCreateType.customOrders));
            },
          );
        } else {
          state.createCustomLabelsData.value = orderData.first;
          _toCreateCustomLabelPage(
              getLabelType(LabelCreateType.customOneOrder));
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void _toCreateCustomLabelPage(int labelType) {
    Get.to(
      () => MaintainLabelCreateCustomPage(labelType: labelType),
    )?.then((v) {
      if (v) refreshDataList();
    });
  }

  List<CreateCustomLabelsData> _createNewDataList(
      List<List<CreateCustomLabelsData>> dataList) {
    final cacheList = <CreateCustomLabelsData>[];

    // 将所有指令数据合并到缓存列表中
    for (var ins in dataList) {
      cacheList.addAll(ins);
    }

    // 按尺寸分组并计算汇总数据
    final grouped =
        groupBy(cacheList, (CreateCustomLabelsData data) => data.size);

    return grouped.entries.map((entry) {
      final key = entry.key;
      final value = entry.value;

      // 计算剩余数量
      final surplus = value
          .map((s) => s.goodsTotal.sub(s.createdGoods))
          .reduce((a, b) => a.add(b));

      return CreateCustomLabelsData(
        isSelect: true,
        size: key,
        createdLabels:
            value.map((s) => s.createdLabels).reduce((a, b) => a + b),
        goodsTotal: value.map((s) => s.goodsTotal).reduce((a, b) => a.add(b)),
        createdGoods:
            value.map((s) => s.createdGoods).reduce((a, b) => a.add(b)),
        surplusGoods:
            value.map((s) => s.surplusGoods).reduce((a, b) => a.add(b)),
        capacity: surplus,
        createGoods: surplus,
        instruct: '',
      );
    }).toList();
  }

  void toMixLabelCreate() {
    state.getOrderDetailsForMix(
      success: (dataList) {
        final List<List<PickingBarCodeInfo>> orderData = [];
        groupBy(dataList, (item) => item.size ?? '').forEach((size, items) {
          if (items.map((v) => v.surplusQty).reduce((a, b) => a.add(b)) > 0) {
            orderData.add(items.where((v) => v.surplusQty > 0).toList());
          }
        });
        orderData
            .sort((a, b) => (a.first.size ?? '').compareTo(b.first.size ?? ''));
        state.createMixLabelsData.value = orderData;
        Get.to(() => const MaintainLabelCreateMixPage())?.then((v) {
          if (v) refreshDataList();
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void refreshMaxLabel() {
    var maxLabelList = <int>[];
    for (var item in state.createMixLabelsData) {
      maxLabelList.addAll(
        item
            .where((v) => v.isSelected.value && v.packingQty.value > 0)
            .map((v) => v.maxLabel())
            .toList(),
      );
    }
    state.maxLabel.value =
        maxLabelList.isEmpty ? 0 : maxLabelList.reduce((a, b) => a < b ? a : b);
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

  void unLockLabel() {
    if (checkUserPermission('601080112')) {
      errorDialog(content: 'maintain_label_unlock_no_permission'.tr);
    } else {
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
      state.setLabelState(
        isPrint: false,
        selectLabels: select,
        success: (msg) => successDialog(content: msg),
      );
    }
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
    if (state.exitLabelType == 1002) {
      state.setLabelState(
        selectLabels: select,
        success: (msg) => createIndonesiaLabel(
            list: select,
            labels: labelsCallback),
      );
    } else if (state.exitLabelType == 1003) {
      state.setLabelState(
        selectLabels: select,
        success: (msg) => createMyanmarLabel(
            list: select,
            labels: labelsCallback),
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
      if (select.every((v) => v.labelModel != '')) {
        if (languageList.length > 1) {
          selectLanguageDialog(
            list: languageList,
            callback: (s) => state.setLabelState(
              selectLabels: select,
              success: (msg) => printLabel(
                select: select,
                language: s,
                type: select.first.labelType!,
              ),
            ),
          );
        } else {
          state.setLabelState(
            selectLabels: select,
            success: (msg) => printLabel(
              select: select,
              language: languageList.isEmpty ? '' : languageList.first,
              type: select.first.labelType!,
            ),
          );
        }
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
              success: (msg) => printLabel(
                select: select,
                language: s,
                type: select.first.labelType!,
              ),
            ),
          );
        } else {
          state.setLabelState(
            selectLabels: select,
            success: (msg) => printLabel(
              select: select,
              language: languageList.isEmpty ? '' : languageList.first,
              type: select.first.labelType!,
            ),
          );
        }
      }
    }
  }

  void printLabel({
    required int type,
    required List<LabelInfo> select,
    required String language,
  }) {
    if (select.first.labelModel == 'multipurpose_dynamic_label_part_dispatch') {
      createPartDispatchOrderDynamicLabel(
        language: language,
        list: select,
        labelCommandPrint: (labelList) => pu.printLabelList(
          labelList: labelList,
          start: () => loadingShow('正在下发标签...'),
          progress: (i, j) => loadingShow('正在下发标签($i/$j)'),
          finished: (success, fail) => successDialog(
            title: '标签下发结束',
            content: '完成${success.length}张, 失败${fail.length}张',
          ),
        ),
      );
      return;
    }
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
        if (state.isPartOrder) {
          createPartOrderDynamicLabel(
            language: language,
            list: select,
            labelViewPreview: labelsCallback,
            labelCommandPrint: (labelList) => pu.printLabelList(
              labelList: labelList,
              start: () => loadingShow('正在下发标签...'),
              progress: (i, j) => loadingShow('正在下发标签($i/$j)'),
              finished: (success, fail) => successDialog(
                title: '标签下发结束',
                content: '完成${success.length}张, 失败${fail.length}张',
              ),
            ),
          );
        } else {
          createGroupDynamicLabel(
            language: language,
            list: select,
            labels: labelsCallback,
          );
        }
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
    List<String>? sizes,
  }) {
    var materials = <String, List>{};
    if (label.subList!
        .any((v) => v.items!.any((v2) => v2.size?.isNotEmpty == true))) {
      var sizeList = <String>[];
      for (var sub in label.subList!) {
        for (var label in sub.items!) {
          if (!sizeList.contains(label.size) &&
              (sizes == null || sizes.contains(label.size))) {
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
    //101
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) async {
    if (state.isShowPreview.value) {
      var labelList = <Widget>[];

      for (var data in list) {
        var languageInfo = data.subList!.first.materialOtherName!
            .firstWhere((v) => v.languageName == language);
        var allTotalQty = 0.0;
        for (var v in data.subList!) {
          v.items?.forEach((c) {
            allTotalQty += c.qty ?? 0.0;
          });
        }
        if (languageInfo.languageCode == 'zh') {
          labelList.add(maintainLabelMaterialChineseFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: languageInfo.name ?? '',
            pageNumber: languageInfo.pageNumber ?? '',
            qty: allTotalQty,
            unit: languageInfo.unitName ?? '',
          ));
        } else {
          labelList.add(maintainLabelMaterialEnglishFixedLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: languageInfo.name ?? '',
            grossWeight: data.grossWeight!,
            netWeight: data.netWeight!,
            meas: data.subList!.first.meas!,
            pageNumber: languageInfo.pageNumber!,
            qty: allTotalQty,
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
        var allTotalQty = 0.0;
        for (var v in data.subList!) {
          v.items?.forEach((c) {
            allTotalQty += c.qty ?? 0.0;
          });
        }
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
          bottomRightText1: allTotalQty.truncate().toString(),
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
            materialName: languageInfo.name ?? '',
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
          content: '(${data.subList!.first.materialCode})${languageInfo.name}',
          subContent1: languageInfo.languageCode == 'zh'
              ? ''
              : 'GW:${data.grossWeight.toShowString()}KG  NW:${data.netWeight.toShowString()}KG',
          subContent2: languageInfo.languageCode == 'zh'
              ? ''
              : 'MEAS:${data.subList!.first.meas}',
          bottomLeftText1: languageInfo.languageCode == 'zh'
              ? ('${data.subList!.first.items?[0].size}#')
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
        var allTotalQty = 0.0;
        map.forEach((k, v) {
          for (var sublist in v) {
            // 假设第二个元素是需要转换为数字的字符串
            if (sublist.length > 1) {
              allTotalQty += double.tryParse(sublist[1]) ?? 0.0;
            }
          }
        });

        if (languageInfo.languageCode == 'zh') {
          labelList.add(maintainLabelSizeMaterialChineseDynamicLabel(
            barCode: data.barCode ?? '',
            factoryType: data.subList!.first.factoryType ?? '',
            billNo: data.departName ?? '',
            total: allTotalQty,
            unit: languageInfo.unitName ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            materialName: data.subList!.first.materialName ?? '',
            map: map,
            titleText: '尺码',
            totalText: '合计',
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
            total: allTotalQty,
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

        var allTotalQty = 0.0;
        map.forEach((k, v) {
          for (var sublist in v) {
            // 假设第二个元素是需要转换为数字的字符串
            if (sublist.length > 1) {
              allTotalQty += double.tryParse(sublist[1]) ?? 0.0;
            }
          }
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
              ? '${allTotalQty.truncate().toString()}${languageInfo.unitName ?? ''}'
              : '',
          tableSubTitle: languageInfo.languageCode == 'zh'
              ? '(${data.subList!.first.materialCode})${languageInfo.name}'
              : 'MEAS:${data.subList!.first.meas}     ${allTotalQty.truncate().toString()}${languageInfo.unitName}',
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

  // 下发打标前校验：毛重(grossWeight)、净重(netWeight)、体积(volume)、
  // 以及 subList 内每个 meas（规格）都不允许为空。
  // 返回 null 表示通过，否则返回具体的缺失信息（含单号）。
  String? _validateLabelRequiredFields(LabelInfo data) {
    final missing = <String>[];
    if (data.grossWeight==0.0) missing.add('毛重(GrossWeight)');
    if (data.netWeight==0.0) missing.add('净重(NetWeight)');
    if (data.volume.isNullOrEmpty()) missing.add('体积(Volume)');
    // 仅在 subList 不为空时校验 meas；subList 为空不报错
    if (!data.subList.isNullOrEmpty() &&
        data.subList!.any((v) => v.meas.isNullOrEmpty())) {
      missing.add('规格(Meas)');
    }
    if (missing.isEmpty) return null;
    return '${data.barCode ?? '未知单号'} 缺少必填项：${missing.join('、')}';
  }

//缅甸标
  void createMyanmarLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      // 下发打标前：毛重/净重/体积/subList 内 meas 任一为空则拦截，不生成标签
      final requiredErr = _validateLabelRequiredFields(data);
      if (requiredErr != null) {
        errorDialog(content: requiredErr);
        return;
      }
      var qty = '';
      var size = '';
      if (data.subList!.first.items!.isEmpty) {
        // 无尺码
      } else if (data.subList!.first.items!.length == 1) {
        //单尺码
        qty = data.subList!.first.items![0].qty!.toShowString();
        size = data.subList!.first.items![0].size ?? '';
      } else if (data.subList!.first.items!.length > 1) {
        qty = data.subList!.first.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
      }

      // 构造单张标签（materialList / inBoxQty 随每张变化）
      Widget buildLabel(Map<String, List> materialList, String boxQty) =>
          dynamicSizeMaterialLabel1098(
            labelID: data.barCode ?? '',
            myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
            typeBody: data.subList!.first.factoryType ?? '',
            trackNo: data.trackNo ?? '',
            materialList: materialList,
            instructionNo: data.subList!.first.billNo ?? '',
            materialCode: data.subList!.first.materialCode ?? '',
            size: size,
            inBoxQty: boxQty,
            customsDeclarationUnit: data.customsDeclarationUnit ?? '',
            customsDeclarationType: data.customsDeclarationType ?? '',
            pieceNo: data.pieceNo ?? '',
            pieceID: data.pieceID ?? '',
            grossWeight: data.grossWeight.toShowString(),
            netWeight: data.netWeight.toShowString(),
            specifications: data.subList!.first.meas ?? '',
            volume: data.volume ?? '',
            supplier: '',
            manufactureDate: data.manufactureDate ?? '',
            hasNotes: true,
            notes: data.notes ?? '',
          );

      final dm = data.subList!.first.items!.length > 1
          ? createSizeList(
              label: data,
              sizeTitle: 'Size',
              totalTitle: 'Total',
            )
          : <String, List>{};
      labelList.add(buildLabel(dm, qty));
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
      // 下发打标前：毛重/净重/体积/subList 内 meas 任一为空则拦截，不生成标签
      final requiredErr = _validateLabelRequiredFields(data);
      if (requiredErr != null) {
        errorDialog(content: requiredErr);
        return;
      }
      var qty = '';
      var typeBody = '';
      if (data.subList!.first.items!.isEmpty) {
        // 无尺码
      } else if (data.subList!.first.items!.length == 1) {
        //单尺码
        typeBody = (data.subList!.first.factoryType ?? '') +
            (data.subList!.first.items![0].size ?? '');
        qty = data.subList!.first.items![0].qty!.toShowString();
      } else if (data.subList!.first.items!.length > 1) {
        //多尺码（qty 仅用于 printType==false 时的整单总数）
        typeBody = data.subList!.first.factoryType ?? '';
        qty = data.subList!.first.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString();
      }

      // 构造单张标签（materialList / inBoxQty 随每张变化）
      Widget buildLabel(Map<String, List> materialList, String boxQty) =>
          dynamicSizeMaterialLabel1095n1096(
            labelID: data.barCode ?? '',
            productName: data.productName ?? '',
            orderType: data.orderType ?? '',
            typeBody: typeBody,
            trackNo: data.trackNo ?? '',
            instructionNo: data.subList!.first.billNo ?? '',
            generalMaterialNumber: data.subList!.first.materialCode ?? '',
            materialDescription: data.subList!.first.materialName ?? '',
            materialList: materialList,
            inBoxQty: boxQty,
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
            repeatHeader: false, // 印尼标：不重复表头、不绘制合计列
            headerFlex: 5, // 首列(尺码/指令)与顶部字段名列(flex 5)等宽
          );

      final dm = data.subList!.first.items!.length > 1
          ? createSizeList(
              label: data,
              sizeTitle: '尺码/Size/ukuran',
              totalTitle: '总计/total',
            )
          : <String, List>{};
      labelList.add(buildLabel(dm, qty));
    }
    labels.call(labelList, true);
  }

  void createPartOrderDynamicLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool cut) labelViewPreview,
    required Function(List<List<Uint8List>>) labelCommandPrint,
  }) async {
    var labelViewList = <Widget>[];
    var labelCommandList = <List<Uint8List>>[];
    for (var data in list) {
      var languageInfo = data.subList!.first.materialOtherName!
          .firstWhere((v) => v.languageName == language);
      var ins = groupBy(data.subList!, (v) => v.billNo ?? '').map(
        (k, v) => MapEntry(k, v.expand((v2) => v2.items!).toList()),
      );
      var map = ins.map((k, v1) => MapEntry(
            k,
            v1
                .map((v2) => [
                      v2.size ?? '',
                      v1
                          .where((v3) => v3.size == v2.size)
                          .map((v3) => v3.qty ?? 0)
                          .reduce((a, b) => a.add(b))
                          .toShowString()
                    ])
                .toList(),
          ));
      var materialList = data.subList!
          .map((v) => v.getMaterialLanguage(languageInfo.languageCode ?? ''))
          .toSet()
          .join('、');
      var titleText = languageInfo.languageCode == 'zh'
          ? '尺码'
          : languageInfo.languageCode == 'id'
              ? 'Ukuran'
              : 'Size';
      var totalText = languageInfo.languageCode == 'zh' ? '合计' : 'Total';

      if (state.isShowPreview.value) {
        labelViewList.add(maintainLabelSizeMaterialChineseDynamicLabel(
          barCode: data.barCode ?? '',
          factoryType: data.subList!.first.factoryType ?? '',
          billNo: data.departName ?? '',
          total: data.totalQty(),
          unit: languageInfo.unitName ?? '',
          materialCode: '',
          materialName: materialList,
          map: map,
          titleText: titleText,
          totalText: totalText,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      } else {
        labelCommandList.add(await labelMultipurposeDynamic(
          isCut: true,
          qrCode: data.barCode ?? '',
          title: data.subList!.first.factoryType ?? '',
          subTitle: data.departName ?? '',
          tableFirstLineTitle: titleText,
          tableLastLineTitle: totalText,
          tableTitleTips:
              '${data.totalQty().toShowString()}${languageInfo.unitName}',
          tableSubTitle: materialList,
          tableData: map,
          bottomLeftText1: languageInfo.pageNumber ?? '',
          bottomRightText1: languageInfo.deliveryDate ?? '',
          speed: spGet(spSavePrintSpeed) ?? 5.0,
          density: spGet(spSavePrintDensity) ?? 10.0,
        ));
      }
    }
    if (state.isShowPreview.value) {
      labelViewPreview.call(labelViewList, true);
    } else {
      labelCommandPrint.call(labelCommandList);
    }
  }

  void createPartDispatchOrderDynamicLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<List<Uint8List>>) labelCommandPrint,
  }) async {
    var labelCommandList = <List<Uint8List>>[];
    for (var data in list) {
      var languageInfo = data.subList!.first.materialOtherName!
          .firstWhere((v) => v.languageName == language);
      var ins = groupBy(data.subList!, (v) => v.billNo ?? '').map(
        (k, v) => MapEntry(k, v.expand((v2) => v2.items!).toList()),
      );
      var map = ins.map((k, v1) => MapEntry(
            k,
            v1
                .map((v2) => [
                      v2.size ?? '',
                      v1
                          .where((v3) => v3.size == v2.size)
                          .map((v3) => v3.qty ?? 0)
                          .reduce((a, b) => a.add(b))
                          .toShowString()
                    ])
                .toList(),
          ));
      var materialList = data.subList!
          .map((v) => v.getMaterialLanguage(languageInfo.languageCode ?? ''))
          .toSet()
          .toList();
      var boxCapacity =
          data.subList?.map((v) => v.totalQty()).reduce((a, b) => a.add(b)) ??
              0;
      var titleText = languageInfo.languageCode == 'zh'
          ? '尺码'
          : languageInfo.languageCode == 'id'
              ? 'Ukuran'
              : 'Size';
      var totalText = languageInfo.languageCode == 'zh' ? '合计' : 'Total';

      labelCommandList.add(await labelMultipurposeDynamic2(
        qrCode: data.barCode ?? '',
        qrCodeTips: '$boxCapacity Pr/pc',
        title: data.subList!.first.factoryType ?? '',
        subTitleList: materialList,
        tableFirstLineTitle: titleText,
        tableLastLineTitle: totalText,
        tableData: map,
        bottomLeftText2: languageInfo.pageNumber ?? '',
        bottomRightText2: languageInfo.deliveryDate ?? '',
        speed: spGet(spSavePrintSpeed) ?? 5.0,
        density: spGet(spSavePrintDensity) ?? 10.0,
      ));
    }
    labelCommandPrint.call(labelCommandList);
  }

  void fillRemainingQty() {
    for (var v in state.createMixLabelsData) {
      v
          .where((v2) => v2.isSelected.value && v2.packingQty.value == 0)
          .forEach((item) {
        item.packingQty.value = item.surplusQty;
        item.packingQtyController!.text = item.packingQty.value.toShowString();
      });
    }
    refreshMaxLabel();
  }

  void createMixLabel(int maxLabel) {
    if (state.createMixLabelsData
        .every((v1) => v1.every((v2) => !v2.isSelected.value))) {
      showSnackBar(
        message: 'maintain_label_dialog_select_instruction_and_size'.tr,
        isWarning: true,
      );
      return;
    }
    if (maxLabel == 0) {
      showSnackBar(
        message: 'maintain_label_dialog_cant_generate'.tr,
        isWarning: true,
      );
      return;
    }

    var submitList = <PickingBarCodeInfo>[];
    for (var item in state.createMixLabelsData) {
      submitList.addAll(item.where((v) => v.isSelected.value).toList());
    }
    state.createMixLabel(
      maxLabel: maxLabel,
      submitList: submitList,
      labelType: getLabelType(LabelCreateType.mixed),
      success: (msg) => successDialog(
        content: msg,
        back: () => Get.back(result: true),
      ),
    );
  }

  void createCustomLabels(int labelType) {
    state.createCustomLabel(
      selectList:
          state.createCustomLabelsData.where((v) => v.isCanCreate()).toList(),
      labelType: labelType,
      success: (msg) => successDialog(
        content: msg,
        back: () => Get.back(result: true),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void customLabelsBatchSet(int batchBoxCapacity, int batchCreateGoods) {
    for (var item
        in state.createCustomLabelsData.where((v) => v.isSelect.value)) {
      item.capacity.value = batchBoxCapacity.toDouble();
      item.capacityController!.text = batchBoxCapacity.toString();
      item.createGoods.value = batchCreateGoods.toDouble();
      item.createGoodsController!.text = batchCreateGoods.toString();
    }
  }

  void cleanMixedAssemble() {
    for (var v in state.createCustomLabelsData) {
      v.isSelect.value = false;
    }
    state.packedBoxes.clear();
    state.createCustomLabelsData.refresh();
  }

  // 自动混码拼装（多箱）：根据输入的混码箱容，循环把全部条目装箱，
  // 每箱尽量装满、合计不超过箱容，且每箱拼接的尺码（条目）数不超过 maxSizesPerBox；
  // 最后在弹窗里展示每箱明细。
  void mixedAssemble(String mixCapacity) {
    // 仅 1002（印尼标）控制每箱最多 5 个尺码混装；其余类型不限制尺码数。
    final bool controlSize = state.exitLabelType == 1002;
    final int maxSizesPerBox = controlSize ? 7 : state.createCustomLabelsData.length;
    final target = mixCapacity.toDoubleTry();
    final items = state.createCustomLabelsData;
    if (items.isEmpty || target <= 0) {
      return;
    }

    // 剩余未装箱条目的"原始索引"
    final remaining = List<int>.generate(items.length, (i) => i);
    final boxes = <List<int>>[]; // 每箱装的是哪些原始索引

    while (remaining.isNotEmpty) {
      // 单条剩余货数就超过箱容的条目无法在不超容前提下装入，直接忽略（不装箱）
      remaining.removeWhere((idx) => items[idx].surplusGoods > target + 1e-9);
      if (remaining.isEmpty) break;

      // 取剩余条目对应的"剩余货数"作为贡献值
      final values = remaining.map((idx) => items[idx].surplusGoods).toList();

      final mask = values.length <= 40
          ? _closestSubsetMask(values, target, maxSizesPerBox)
          : _greedySubsetMask(values, target, maxSizesPerBox);

      // 把掩码还原成这一箱装了哪些剩余条目（相对索引 -> 原始索引）
      final box = <int>[];
      for (var i = 0; i < values.length; i++) {
        if ((mask & (1 << i)) != 0) box.add(remaining[i]);
      }

      boxes.add(box);
      remaining.removeWhere((idx) => box.contains(idx));
    }

    // 把装箱结果存到 state，方便外部（如创建贴标）按"每一箱"取数据
    state.packedBoxes =
        boxes.map((b) => b.map((idx) => items[idx]).toList()).toList();

    // 拼装提示文本：逐箱列出尺码+数量+每箱合计
    final mes = StringBuffer();
    mes.writeln(
        '混码箱容=$target，${controlSize ? '每箱最多 $maxSizesPerBox 个尺码' : '不限制每箱尺码数'}，共需 ${boxes.length} 箱：');
    for (var b = 0; b < boxes.length; b++) {
      final box = boxes[b];
      final total =
          box.fold<double>(0.0, (s, idx) => s + items[idx].surplusGoods);
      final over = total > target + 1e-9;
      mes.writeln(
          '【第 ${b + 1} 箱】合计 ${total.toShowString()}${over ? ' ⚠超过箱容' : ''}');
      for (final idx in box) {
        mes.writeln(
            '   尺码：${items[idx].size}　数量：${items[idx].surplusGoods.toShowString()}');
      }
    }

    askDialog(
        content: mes.toString(),
        confirm: () async {
          try {
            for (final box in state.packedBoxes) {
              await state.createCustomizeMixLabel(
                submitList: box,
                labelType: getLabelType(LabelCreateType.mixed),
              );
            }
            successDialog(
              content: '混码标签已全部生成',
              back: () => Get.back(result: true),
            );
          } catch (e) {
            errorDialog(content: e.toString().replaceFirst('Exception: ', ''));
          }
        });
  }

  // 在 values 中找出一个子集，使其元素之和不超过 target、选中个数不超过 maxCount，
  // 且尽量接近 target（即尽量装满）；返回对应的位掩码。
  // maxCount 控制每箱最多拼接的尺码数。采用 meet-in-the-middle：左半 / 右半分别枚举
  // 子集（和 + 选中个数 + 掩码），右半按"选中个数"分组后二分匹配。
  int _closestSubsetMask(List<double> values, double target, int maxCount) {
    final n = values.length;
    final half = n ~/ 2;
    final right = n - half;

    // 左半：枚举所有子集的和、掩码、选中个数（位 0..half-1）
    final left = <({double sum, int mask, int count})>[];
    for (var mask = 0; mask < (1 << half); mask++) {
      var s = 0.0;
      var c = 0;
      for (var i = 0; i < half; i++) {
        if ((mask & (1 << i)) != 0) {
          s += values[i];
          c++;
        }
      }
      left.add((sum: s, mask: mask, count: c));
    }

    // 右半：枚举所有子集的和、掩码、选中个数（位 0..right-1），
    // 并按"选中个数"分组、组内按和排序，便于限制右半最多再选 (maxCount - 左半已选) 个。
    final rightByCount =
        List<List<({double sum, int mask, int count})>>.generate(
            maxCount + 1, (_) => <({double sum, int mask, int count})>[]);
    for (var mask = 0; mask < (1 << right); mask++) {
      var s = 0.0;
      var c = 0;
      for (var i = 0; i < right; i++) {
        if ((mask & (1 << i)) != 0) {
          s += values[half + i];
          c++;
        }
      }
      if (c <= maxCount) rightByCount[c].add((sum: s, mask: mask, count: c));
    }
    for (final list in rightByCount) {
      list.sort((a, b) => a.sum.compareTo(b.sum));
    }

    var bestMask = 0;
    var bestTotal = -1.0; // 记录不超过箱容的最大合计

    for (final l in left) {
      if (l.count > maxCount) continue;
      if (l.sum > target + 1e-9) continue; // 左半自身已超箱容，跳过
      final need = target - l.sum;
      final maxRight = maxCount - l.count;
      if (maxRight < 0) continue;

      // 在所有允许个数的右半子集中，找和 <= need 的最大和（使合计尽量接近 target 且不超）
      var bestRight = (sum: -1.0, mask: 0, count: 0);
      var found = false;
      for (var c = 0; c <= maxRight; c++) {
        final arr = rightByCount[c];
        var lo = 0;
        var hi = arr.length - 1;
        var pos = -1;
        while (lo <= hi) {
          final mid = (lo + hi) ~/ 2;
          if (arr[mid].sum <= need) {
            pos = mid;
            lo = mid + 1;
          } else {
            hi = mid - 1;
          }
        }
        if (pos < 0) continue;
        // 浮点误差保护：若合计因精度略超目标，回退到更小的组合，确保绝对不超过箱容
        var p = pos;
        while (p >= 0 && l.sum + arr[p].sum > target) {
          p--;
        }
        if (p >= 0 && (!found || arr[p].sum > bestRight.sum + 1e-9)) {
          bestRight = arr[p];
          found = true;
        }
      }
      if (!found) continue;
      final total = l.sum + bestRight.sum;
      if (total > bestTotal + 1e-9) {
        bestTotal = total;
        bestMask = l.mask | (bestRight.mask << half);
      }
    }
    return bestMask;
  }

  // 退化的贪心算法：数据量过大（>40）时退而求其次，优先装大值、不超目标、选中个数不超过 maxCount，精度有限。
  int _greedySubsetMask(List<double> values, double target, int maxCount) {
    final n = values.length;
    final idx = List<int>.generate(n, (i) => i);
    idx.sort((a, b) => values[b].compareTo(values[a]));
    var mask = 0;
    var sum = 0.0;
    var count = 0;
    for (final i in idx) {
      if (count < maxCount && sum + values[i] <= target) {
        sum += values[i];
        count++;
        mask |= (1 << i);
      }
    }
    return mask;
  }
}
