import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/create_custom_label_data.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
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

class MaintainLabelLogic extends GetxController {
  final MaintainLabelState state = MaintainLabelState();

  @override
  void onInit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshDataList();
    });
    super.onInit();
  }

  void getCreateLabelType({
    required VoidCallback onlyCustom,
    required VoidCallback allType,
    required VoidCallback mixAndCustom,
  }) {
    switch (state.sapProcessName) {
      case 'BL':
      case 'ZL':
      case 'YT':
        onlyCustom.call();
        break;
      case 'PQ':
      case 'ZC':
      case 'ZHUS':
      case 'ZDJG':
      case 'HDD':
      case 'LLDM':
      case 'BZD':
      case 'BFST':
      case 'TYT':
      case 'ZD':
      case 'BGDTP':
      case 'BJC':
      case 'ZS':
      case 'MLCD':
      case 'MLCD1':
      case 'MLCD2':
      case 'MLCD3':
      case 'DLCD':
      case 'DDCD':
      case 'BDD':
      case 'GP':
        allType.call();
        break;
      case 'GBJG':
        mixAndCustom.call();
        break;
    }
  }

  int getLabelType(LabelCreateType createType) {
    int type = -1;

    getCreateLabelType(
      onlyCustom: () {
        switch (createType) {
          case LabelCreateType.single:
          case LabelCreateType.mixed:
            type = -1;
            break;
          case LabelCreateType.customOneOrder:
          case LabelCreateType.customOrders:
            type = 101;
            break;
        }
      },
      allType: () {
        switch (createType) {
          case LabelCreateType.single:
          case LabelCreateType.customOneOrder:
            type = 102;
            break;
          case LabelCreateType.mixed:
          case LabelCreateType.customOrders:
            type = 103;
            break;
        }
      },
      mixAndCustom: () {
        switch (createType) {
          case LabelCreateType.single:
            type = -1;
            break;
          case LabelCreateType.mixed:
          case LabelCreateType.customOneOrder:
          case LabelCreateType.customOrders:
            type = 103;
            break;
        }
      },
    );

    return type;
  }

  void refreshDataList() {
    state.getLabelInfoList(error: (msg) => errorDialog(content: msg));
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
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void getBarCodeCountMix(Function(List<List<PickingBarCodeInfo>>) callback) {
    state.getOrderDetailsForMix(
      success: callback,
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

  void printLabelState({
    required List<List<LabelInfo>> selectLabel,
    required int type,
    required Function(int) success,
  }) {
    state.setLabelState(
      selectLabels: selectLabel,
      labelType: type,
      success: (int type) {
        success.call(type);
      },
    );
  }

  void checkPrintType() {
    var select = <LabelInfo>[];
    if (state.isMaterialLabel.value) {
      select = state.labelList.where((v) => v.select).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    } else {
      for (var data in state.labelGroupList) {
        for (var value in data) {
          if (value.select == true) {
            select.add(value);
          }
        }
      }
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    }
    if (select[0].labelType == 1002 || select[0].labelType == 1003) {
      printLabelState(
          type: select[0].labelType!,
          selectLabel: [select],
          success: (labelType) {
            printAbroadLabel(
              type: labelType,
              select: [select],
              language: '',
            );
          });
    } else {
      checkLanguage();
    }
  }

  //打缅甸，印尼标
  void printAbroadLabel({
    required int type,
    required List<List<LabelInfo>> select,
    required String language,
  }) {
    var printType = select[0][0].labelType;
    switch (printType) {
      case 1002:
        {
          createIndonesiaLabel(list: select[0], labels: labelsCallback);
        }
      case 1003:
        {
          createMyanmarLabel(list: select[0], labels: labelsCallback);
        }
        break;
      default:
        break;
    }
  }

  void checkLanguage() {
    var languageList = <String>[];
    var select = <LabelInfo>[];

    if (state.isMaterialLabel.value) {
      select = state.labelList.where((v) => v.select).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    } else {
      for (var data in state.labelGroupList) {
        for (var value in data) {
          if (value.select == true) {
            select.add(value);
          }
        }
      }
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    }

    var labelType = <String>[];

    for (var type in select) {
      if (!labelType.contains(type.labelType.toString())) {
        labelType.add(type.labelType.toString());
      }
    }
    if (labelType.length > 1) {
      errorDialog(content: 'maintain_label_select_label_not_same'.tr);
      return;
    }
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
    if (select[0].labelType != 101 &&
        select[0].labelType != 102 &&
        select[0].labelType != 103) {
      showSnackBar(
          message:
              'maintain_label_error'.trArgs([select[0].labelType.toString()]));
    } else {
      if (languageList.isEmpty) {
        printLabelState(
            type: select[0].labelType!,
            selectLabel: [select],
            success: (labelType) {
              printLabel(
                type: labelType,
                select: [select],
                language: '',
              );
            });
      } else {
        if (languageList.length == 1) {
          printLabelState(
              type: select[0].labelType!,
              selectLabel: [select],
              success: (labelType) {
                printLabel(
                  select: [select],
                  language: languageList[0],
                  type: labelType,
                );
              });
        } else {
          selectLanguageDialog(
              list: languageList,
              callback: (s) => printLabelState(
                  type: select[0].labelType!,
                  selectLabel: [select],
                  success: (labelType) {
                    printLabel(
                      select: [select],
                      language: s,
                      type: labelType,
                    );
                  }));
        }
      }
    }
  }

  Function(List<Widget>, bool cut) labelsCallback = (label, cut) {
    if (label.length > 1) {
      Get.to(() => PreviewLabelList(
            labelWidgets: label,
            isDynamic: cut,
          ));
    } else {
      Get.to(() => PreviewLabel(
            labelWidget: label[0],
            isDynamic: cut,
          ));
    }
  };

  void printLabel({
    required int type,
    required List<List<LabelInfo>> select,
    required String language,
  }) {
    switch (type) {
      case 101:
        createMaterialLabel(
          language: language,
          list: select[0],
          labels: labelsCallback,
        );
        break;
      case 102:
        createFixedLabel(
          language: language,
          list: select[0],
          labels: labelsCallback,
        );
        break;
      case 103:
        createGroupDynamicLabel(
          language: language,
          list: select[0],
          labels: labelsCallback,
        );
        break;
      default:
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
      // labelList.add(dynamicMaterialLabel1098(
      //   labelID: data.barCode ?? '',
      //   myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
      //   typeBody: data.factoryType ?? '',
      //   trackNo: data.trackNo ?? '',
      //   instructionNo: data.billNo ?? '',
      //   materialList: [],
      //   customsDeclarationType: data.customsDeclarationType ?? '',
      //   pieceNo: data.pieceNo ?? '',
      //   pieceID: data.pieceID ?? '',
      //   grossWeight: data.grossWeight.toShowString(),
      //   netWeight: data.netWeight.toShowString(),
      //   specifications: data.meas ?? '',
      //   volume: data.volume ?? '',
      //   supplier: data.departName ?? '',
      //   manufactureDate: data.manufactureDate ?? '',
      //   hasNotes: false,
      //   notes: '',
      // ));
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
      // labelList.add(dynamicSizeMaterialLabel1098(
      //   labelID: data.barCode ?? '',
      //   myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
      //   typeBody: data.factoryType ?? '',
      //   trackNo: data.trackNo ?? '',
      //   materialList: createSizeList(
      //     label: data,
      //     sizeTitle: 'Size',
      //     totalTitle: 'Total',
      //   ),
      //   instructionNo: '',
      //   materialCode: '',
      //   size: '',
      //   inBoxQty: data.items!
      //       .map((v) => v.qty ?? 0)
      //       .reduce((a, b) => a.add(b))
      //       .toShowString(),
      //   customsDeclarationUnit: data.customsDeclarationUnit ?? '',
      //   customsDeclarationType: data.customsDeclarationType ?? '',
      //   pieceNo: data.pieceNo ?? '',
      //   pieceID: data.pieceID ?? '',
      //   grossWeight: data.grossWeight.toShowString(),
      //   netWeight: data.netWeight.toShowString(),
      //   specifications: data.meas ?? '',
      //   volume: data.volume ?? '',
      //   supplier: data.departName ?? '',
      //   manufactureDate: data.manufactureDate ?? '',
      //   hasNotes: false,
      //   notes: '',
      // ));
    }
    labels.call(labelList, true);
  }

  Map<String, List> createSizeList({
    required LabelInfo label,
    required String sizeTitle,
    required String totalTitle,
  }) {
    var materials = <String, List>{};
    // if (label.items!.any((v) => v.size?.isNotEmpty == true)) {
    //   var sizeList = <String>[];
    //   for (var label in label.items!) {
    //     if (!sizeList.contains(label.size)) {
    //       sizeList.add(label.size ?? '');
    //     }
    //   }
    //   sizeList.sort();
    //   materials[sizeTitle] = [...sizeList, totalTitle];
    //   groupBy(
    //     label.items!,
    //     (v) => v.billNo ?? '',
    //   ).forEach((k, labels) {
    //     var list = [];
    //     for (var size in sizeList) {
    //       try {
    //         list.add(labels
    //             .firstWhere((label) => label.size == size)
    //             .qty
    //             .toShowString());
    //       } on StateError catch (_) {
    //         list.add(' ');
    //       }
    //     }
    //     list.add(labels
    //         .map((v) => v.qty ?? 0)
    //         .reduce((a, b) => a.add(b))
    //         .toShowString());
    //     materials[k] = list;
    //   });
    // }
    return materials;
  }

  //单一物料单尺码标
  void createSingleSizeLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      // labelList.add(dynamicSizeMaterialLabel1098(
      //   labelID: data.barCode ?? '',
      //   myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
      //   typeBody: data.factoryType ?? '',
      //   trackNo: data.trackNo ?? '',
      //   materialList: {},
      //   instructionNo: data.billNo ?? '',
      //   materialCode: data.materialCode ?? '',
      //   size: data.items!.first.size ?? '',
      //   inBoxQty: data.items!.first.qty.toShowString(),
      //   customsDeclarationUnit: data.customsDeclarationUnit ?? '',
      //   customsDeclarationType: data.customsDeclarationType ?? '',
      //   pieceNo: data.pieceNo ?? '',
      //   pieceID: data.pieceID ?? '',
      //   grossWeight: data.grossWeight.toShowString(),
      //   netWeight: data.netWeight.toShowString(),
      //   specifications: data.meas ?? '',
      //   volume: data.volume ?? '',
      //   supplier: data.departName ?? '',
      //   manufactureDate: data.manufactureDate ?? '',
      //   hasNotes: false,
      //   notes: '',
      // ));
    }
    labels.call(labelList, true);
  }

  //物料标
  void createMaterialLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];

    // for (var data in list) {
    //   var languageInfo =
    //       data.materialOtherName!.firstWhere((v) => v.languageName == language);
    //   if (languageInfo.languageCode == 'zh') {
    //     labelList.add(maintainLabelMaterialChineseFixedLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       billNo: data.billNo ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: data.materialName ?? '',
    //       pageNumber: languageInfo.pageNumber ?? '',
    //       qty: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
    //       unit: languageInfo.unitName ?? '',
    //     ));
    //   } else {
    //     labelList.add(maintainLabelMaterialEnglishFixedLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       billNo: data.billNo ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: data.materialName ?? '',
    //       grossWeight: data.grossWeight!,
    //       netWeight: data.netWeight!,
    //       meas: data.meas!,
    //       pageNumber: languageInfo.pageNumber!,
    //       qty: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
    //       unit: languageInfo.unitName ?? '',
    //     ));
    //   }
    // }
    labels.call(labelList, false);
  }

  //固定单码标
  void createFixedLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];

    // for (var data in list) {
    //   var languageInfo =
    //       data.materialOtherName!.firstWhere((v) => v.languageName == language);
    //
    //   if (languageInfo.languageCode == 'zh') {
    //     labelList.add(maintainLabelSingleSizeChineseFixedLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       billNo: data.items?[0].billNo ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: data.materialName ?? '',
    //       size: data.items?[0].size ?? '',
    //       pageNumber: languageInfo.pageNumber ?? '',
    //       date: languageInfo.deliveryDate ?? '',
    //       unit: (data.items?[0].qty.toShowString() ?? '') +
    //           (languageInfo.unitName ?? ''),
    //     ));
    //   } else {
    //     labelList.add(maintainLabelSingleSizeEnglishFixedLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       billNo: data.items?[0].billNo ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: languageInfo.name ?? '',
    //       grossWeight: data.grossWeight ?? 0.0,
    //       netWeight: data.netWeight ?? 0.0,
    //       meas: data.meas ?? '',
    //       qty: data.items?[0].qty ?? 0.0,
    //       pageNumber: languageInfo.pageNumber ?? '',
    //       size: data.items?[0].size ?? '',
    //       unit: languageInfo.unitName ?? '',
    //     ));
    //   }
    // }
    labels.call(labelList, false);
  }

  //合并动态标签
  void createGroupDynamicLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    // for (var data in list) {
    //   //标签语言类型
    //   var languageInfo =
    //       data.materialOtherName!.firstWhere((v) => v.languageName == language);
    //   var insList = <LabelSizeInfo>[];
    //   if (!data.items.isNullOrEmpty()) {
    //     insList.addAll(data.items!);
    //   }
    //   //标签指令列表
    //   var ins = groupBy(insList, (v) => v.billNo);
    //
    //   //表格列表
    //   Map<String, List<List<String>>> map = {};
    //   ins.forEach((k, v1) {
    //     map[k ?? ''] = [
    //       for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
    //     ];
    //   });
    //
    //   if (languageInfo.languageCode == 'zh') {
    //     labelList.add(maintainLabelSizeMaterialChineseDynamicLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       billNo: data.departName ?? '',
    //       total: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
    //       unit: languageInfo.unitName ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: data.materialName ?? '',
    //       map: map,
    //       pageNumber: languageInfo.pageNumber ?? '',
    //       deliveryDate: languageInfo.deliveryDate ?? '',
    //     ));
    //   } else {
    //     labelList.add(maintainLabelMixEnglishDynamicLabel(
    //       barCode: data.barCode ?? '',
    //       factoryType: data.factoryType ?? '',
    //       materialCode: data.materialCode ?? '',
    //       materialName: data.materialName ?? '',
    //       grossWeight: data.grossWeight ?? 0.0,
    //       netWeight: data.netWeight ?? 0.0,
    //       meas: data.meas ?? '',
    //       total: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
    //       unit: languageInfo.unitName ?? '',
    //       map: map,
    //       pageNumber: languageInfo.pageNumber ?? '',
    //       deliveryDate: languageInfo.deliveryDate ?? '',
    //     ));
    //   }
    // }
    labels.call(labelList, true);
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
    var itemList = <LabelSizeInfo>[];
    for (var v in data) {
      // if (!v.items.isNullOrEmpty()) itemList.addAll(v.items!);
    }

    groupBy(itemList, (v) => v.size).forEach((k, v) {
      for (var v2 in v) {
        widgetList.add(subItem.call(
          v2.billNo ?? 'maintain_label_sub_item_instruction_error'.tr,
          v2.size ?? '',
          v2.qty.toShowString(),
          2,
        ));
      }
      if (!state.isSingleLabel) {
        widgetList.add(subItem.call(
          '',
          '小计',
          v
              .map((v2) => v2.qty ?? 0.0)
              .reduce((a, b) => a.add(b))
              .toShowString(),
          3,
        ));
      }
    });
    if (!state.isSingleLabel) {
      // widgetList.add(subItem.call(
      //   '',
      //   '合计',
      //   data
      //       .map((v2) => v2.items!.first.qty ?? 0.0)
      //       .reduce((a, b) => a.add(b))
      //       .toShowString(),
      //   4,
      // ));
    }
    return widgetList;
  }

  String getPartOrderMaterial() {
    var materialList = <String>[];
    // for (var v in state.labelList) {
    //   v.items?.forEach((v2) {
    //     if (!v2.materialName.isNullOrEmpty()) {
    //       if (!materialList.contains(v2.materialName)) {
    //         materialList.add(v2.materialName!);
    //       }
    //     }
    //   });
    // }
    return materialList.join('、');
  }
}

//缅甸标
void createMyanmarLabel({
  required List<LabelInfo> list,
  required Function(List<Widget>, bool) labels,
}) {
  var labelList = <Widget>[];
  // for (var data in list) {
  //   var qty = '';
  //   var size = '';
  //   var dataList = <String, List>{};
  //   if (data.items!.isEmpty) {
  //     // 无尺码
  //   } else if (data.items!.length == 1) {
  //     //单尺码
  //     qty = data.items![0].qty!.toShowString();
  //     size = data.items![0].size ?? '';
  //   } else if (data.items!.length > 1) {
  //     //多尺码
  //     qty = data.items!
  //         .map((v) => v.qty ?? 0)
  //         .reduce((a, b) => a.add(b))
  //         .toShowString();
  //     dataList = createSizeList(
  //       list: data.items!,
  //       sizeTitle: '尺码/Size/ukuran',
  //       totalTitle: '总计/total',
  //     );
  //   }
  //   labelList.add(dynamicSizeMaterialLabel1098(
  //     labelID: data.barCode ?? '',
  //     myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
  //     typeBody: data.factoryType ?? '',
  //     trackNo: data.trackNo ?? '',
  //     materialList: dataList,
  //     instructionNo: data.billNo ?? '',
  //     materialCode: data.materialCode ?? '',
  //     size: size,
  //     inBoxQty: qty,
  //     customsDeclarationUnit: data.customsDeclarationUnit ?? '',
  //     customsDeclarationType: data.customsDeclarationType ?? '',
  //     pieceNo: data.pieceNo ?? '',
  //     pieceID: data.pieceID ?? '',
  //     grossWeight: data.grossWeight.toShowString(),
  //     netWeight: data.netWeight.toShowString(),
  //     specifications: data.meas ?? '',
  //     volume: data.volume ?? '',
  //     supplier: '供应商123456',
  //     manufactureDate: data.manufactureDate ?? '',
  //     hasNotes: true,
  //     notes: data.notes ?? '',
  //   ));
  // }
  labels.call(labelList, true);
}

Map<String, List> createSizeList({
  required List<LabelSizeInfo> list,
  required String sizeTitle,
  required String totalTitle,
}) {
  var materials = <String, List>{};
  if (list.any((v) => v.size?.isNotEmpty == true)) {
    var sizeList = <String>[];
    for (var label in list) {
      if (!sizeList.contains(label.size)) {
        sizeList.add(label.size ?? '');
      }
    }
    sizeList.sort();
    materials[sizeTitle] = [...sizeList, totalTitle];
    groupBy(
      list,
      (v) => v.billNo ?? '',
    ).forEach((k, labels) {
      var list = [];
      for (var size in sizeList) {
        try {
          list.add(labels
              .firstWhere((label) => label.size == size)
              .qty
              .toShowString());
        } on StateError catch (_) {
          list.add(' ');
        }
      }
      list.add(labels
          .map((v) => v.qty ?? 0)
          .reduce((a, b) => a.add(b))
          .toShowString());
      materials[k] = list;
    });
  }
  return materials;
}

//印尼标
void createIndonesiaLabel({
  required List<LabelInfo> list,
  required Function(List<Widget>, bool) labels,
}) {
  var labelList = <Widget>[];
  // for (var data in list) {
  //   var qty = '';
  //   var typeBody = '';
  //   var dataList = <String, List>{};
  //   if (data.items!.isEmpty) {
  //     // 无尺码
  //   } else if (data.items!.length == 1) {
  //     //单尺码
  //     typeBody = (data.factoryType ?? '') + (data.items![0].size ?? '');
  //     qty = data.items![0].qty!.toShowString();
  //   } else if (data.items!.length > 1) {
  //     //多尺码
  //     typeBody = data.factoryType ?? '';
  //     qty = data.items!
  //         .map((v) => v.qty ?? 0)
  //         .reduce((a, b) => a.add(b))
  //         .toShowString();
  //     dataList = createSizeList(
  //       list: data.items!,
  //       sizeTitle: '尺码/Size/ukuran',
  //       totalTitle: '总计/total',
  //     );
  //   }
  //   labelList.add(dynamicSizeMaterialLabel1095n1096(
  //     labelID: data.barCode ?? '',
  //     productName: 'productName',
  //     orderType: 'orderType',
  //     typeBody: typeBody,
  //     trackNo: data.trackNo ?? '',
  //     instructionNo: data.billNo ?? '',
  //     generalMaterialNumber: data.materialCode ?? '',
  //     materialDescription: data.materialName ?? '',
  //     materialList: dataList,
  //     inBoxQty: qty,
  //     customsDeclarationUnit: data.customsDeclarationUnit ?? '',
  //     customsDeclarationType: data.customsDeclarationType ?? '',
  //     pieceID: data.pieceID ?? '',
  //     pieceNo: data.pieceNo ?? '',
  //     grossWeight: data.grossWeight.toShowString(),
  //     netWeight: data.netWeight.toShowString(),
  //     specifications: data.meas ?? '',
  //     volume: data.volume ?? '',
  //     supplier: '',
  //     manufactureDate: data.manufactureDate ?? '',
  //     consignee: '收货方123456',
  //     hasNotes: true,
  //     notes: data.notes ?? '',
  //   ));
  // }
  labels.call(labelList, true);
}
