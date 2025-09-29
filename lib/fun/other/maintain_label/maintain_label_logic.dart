import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/label_info.dart';
import 'package:jd_flutter/bean/http/response/maintain_material_info.dart';
import 'package:jd_flutter/bean/http/response/picking_bar_code_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_110w.dart';
import 'package:jd_flutter/widget/tsc_label_templates/fixed_label_75w45h.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_75w.dart';

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
    if (!state.isMaterialLabel.value) {
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
    if (!state.isMaterialLabel.value) {
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
    if (!state.isMaterialLabel.value) {
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
    if (!state.isMaterialLabel.value) {
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

  printLabelState({
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

  checkPrintType({
    required Function(bool abroad, List<List<LabelInfo>>, int labelType)
        callback,
  }) {
    var select = <LabelInfo>[];
    if (state.isMaterialLabel.value) {
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
    } else {
      select = state.labelList.where((v) => v.select).toList();
      if (select.isEmpty) {
        errorDialog(content: 'maintain_label_select_label'.tr);
        return;
      }
    }
    if (select[0].labelType == 1002 || select[0].labelType == 1003) {
      callback.call(true, [select], select[0].labelType!);
    } else {
      callback.call(false, [], 0);
    }
  }

  //打缅甸，印尼标
  printAbroadLabel({
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

  checkLanguage({
    required Function(int labelType, List<List<LabelInfo>>, List<String>)
        callback,
  }) {
    var languageList = <String>[];
    var select = <LabelInfo>[];

    if (state.isMaterialLabel.value) {
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
    } else {
      select = state.labelList.where((v) => v.select).toList();
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
        if (label.materialOtherName?.every((v) => v.languageName != language) ==
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
    if (select[0].labelType != 101 &&
        select[0].labelType != 102 &&
        select[0].labelType != 103 &&
        select[0].labelType != 1) {
      showSnackBar(
          message:
              'maintain_label_error'.trArgs([select[0].labelType.toString()]));
    } else {
      callback.call(select[0].labelType!, [select], languageList);
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

  printLabel({
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
      default:
        break;
    }
  }

  //单一物料无尺码标
  createNoSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        instructionNo: data.billNo ?? '',
        materialList: [],
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.meas ?? '',
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
  createMultipleSizeLabel({
    String language = '',
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicSizeMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        materialList: createSizeList(
          label: data,
          sizeTitle: 'Size',
          totalTitle: 'Total',
        ),
        instructionNo: '',
        materialCode: '',
        size: '',
        inBoxQty: data.items!
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.meas ?? '',
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
    if (label.items!.any((v) => v.size?.isNotEmpty == true)) {
      var sizeList = <String>[];
      for (var label in label.items!) {
        if (!sizeList.contains(label.size)) {
          sizeList.add(label.size ?? '');
        }
      }
      sizeList.sort();
      materials[sizeTitle] = [...sizeList, totalTitle];
      groupBy(
        label.items!,
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

  //单一物料单尺码标
  createSingleSizeLabel({
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      labelList.add(dynamicSizeMaterialLabel1098(
        labelID: data.barCode ?? '',
        myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
        typeBody: data.factoryType ?? '',
        trackNo: data.trackNo ?? '',
        materialList: {},
        instructionNo: data.billNo ?? '',
        materialCode: data.materialCode ?? '',
        size: data.items!.first.size ?? '',
        inBoxQty: data.items!.first.qty.toShowString(),
        customsDeclarationUnit: data.customsDeclarationUnit ?? '',
        customsDeclarationType: data.customsDeclarationType ?? '',
        pieceNo: data.pieceNo ?? '',
        pieceID: data.pieceID ?? '',
        grossWeight: data.grossWeight.toShowString(),
        netWeight: data.netWeight.toShowString(),
        specifications: data.meas ?? '',
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
  createMaterialLabel({
    required String language,
    required List<LabelInfo> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];

    for (var data in list) {
      var languageInfo =
          data.materialOtherName!.firstWhere((v) => v.languageName == language);
      if (language == 'zh') {
        labelList.add(maintainLabelMaterialChineseFixedLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          materialCode: data.materialCode ?? '',
          materialName: data.materialName ?? '',
          pageNumber: languageInfo.pageNumber ?? '',
          qty: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
        ));
      } else {
        labelList.add(maintainLabelMaterialEnglishFixedLabel(
          barCode: data.barCode ?? '',
          factoryType: data.factoryType ?? '',
          billNo: data.billNo ?? '',
          materialCode: data.materialCode ?? '',
          materialName: data.materialName ?? '',
          grossWeight: data.grossWeight!,
          netWeight: data.netWeight!,
          meas: data.meas!,
          pageNumber: languageInfo.pageNumber!,
          qty: data.items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
        ));
      }
    }
    labels.call(labelList, false);
  }

  //固定单码标
  createFixedLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      var languageInfo = data[0]
          .materialOtherName!
          .firstWhere((v) => v.languageName == language);

      if (language == 'zh') {
        labelList.add(maintainLabelSingleSizeChineseFixedLabel(
          barCode: data[0].barCode ?? '',
          factoryType: data[0].factoryType ?? '',
          billNo: data[0].items![0].billNo ?? '',
          materialCode: data[0].materialCode ?? '',
          materialName: data[0].materialName ?? '',
          size: data[0].items?[0].size ?? '',
          pageNumber: languageInfo.pageNumber ?? '',
          date: languageInfo.deliveryDate ?? '',
          unit: (data[0].items?[0].qty.toShowString() ?? '') +
              (languageInfo.unitName ?? ''),
        ));
      } else {
        labelList.add(maintainLabelSingleSizeEnglishFixedLabel(
          barCode: data[0].barCode ?? '',
          factoryType: data[0].factoryType ?? '',
          billNo: data[0].items![0].billNo ?? '',
          materialCode: data[0].materialCode ?? '',
          materialName: data[0].materialName ?? '',
          grossWeight: data[0].grossWeight ?? 0.0,
          netWeight: data[0].netWeight ?? 0.0,
          meas: data[0].meas ?? '',
          qty: data[0].items?[0].qty ?? 0.0,
          pageNumber: languageInfo.pageNumber ?? '',
          size: data[0].items?[0].size ?? '',
        ));
      }
    }
    labels.call(labelList, false);
  }

  //合并动态标签
  createGroupDynamicLabel({
    required String language,
    required List<List<LabelInfo>> list,
    required Function(List<Widget>, bool) labels,
  }) {
    var labelList = <Widget>[];
    for (var data in list) {
      //标签语言类型
      var languageInfo = data[0]
          .materialOtherName!
          .firstWhere((v) => v.languageName == language);
      var insList = <LabelSizeInfo>[];
      for (var item in data) {
        if (!item.items.isNullOrEmpty()) {
          insList.addAll(item.items!);
        }
      }
      //标签指令列表
      var ins = groupBy(insList, (v) => v.billNo);

      //表格列表
      Map<String, List<List<String>>> map = {};
      ins.forEach((k, v1) {
        map[k ?? ''] = [
          for (var v2 in v1) [v2.size ?? '', v2.qty.toShowString()]
        ];
      });

      if (language == 'zh') {
        labelList.add(maintainLabelSizeMaterialChineseDynamicLabel(
          barCode: data[0].barCode ?? '',
          factoryType: data[0].factoryType ?? '',
          billNo: data[0].departName ?? '',
          total:
              data[0].items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          materialCode: data[0].materialCode ?? '',
          materialName: data[0].materialName ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      } else {
        labelList.add(maintainLabelMixEnglishDynamicLabel(
          barCode: data[0].barCode ?? '',
          factoryType: data[0].factoryType ?? '',
          materialCode: data[0].materialCode ?? '',
          materialName: data[0].materialName ?? '',
          grossWeight: data[0].grossWeight ?? 0.0,
          netWeight: data[0].netWeight ?? 0.0,
          meas: data[0].meas ?? '',
          total:
              data[0].items!.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b)),
          unit: languageInfo.unitName ?? '',
          map: map,
          pageNumber: languageInfo.pageNumber ?? '',
          deliveryDate: languageInfo.deliveryDate ?? '',
        ));
      }
    }
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

//缅甸标
createMyanmarLabel({
  required List<LabelInfo> list,
  required Function(List<Widget>, bool) labels,
}) {
  var labelList = <Widget>[];
  for (var data in list) {
    var qty = '';
    var size = '';
    var dataList = <String, List>{};
    if (data.items!.isEmpty) {
      // 无尺码
    } else if (data.items!.length == 1) {
      //单尺码
      qty = data.items![0].qty!.toShowString();
      size = data.items![0].size ?? '';
    } else if (data.items!.length > 1) {
      //多尺码
      qty = data.items!
          .map((v) => v.qty ?? 0)
          .reduce((a, b) => a.add(b))
          .toShowString();
      dataList = createSizeList(
        list: data.items!,
        sizeTitle: '尺码/Size/ukuran',
        totalTitle: '总计/total',
      );
    }
    labelList.add(dynamicSizeMaterialLabel1098(
      labelID: data.barCode ?? '',
      myanmarApprovalDocument: data.myanmarApprovalDocument ?? '',
      typeBody: data.factoryType ?? '',
      trackNo: data.trackNo ?? '',
      materialList: dataList,
      instructionNo: data.billNo ?? '',
      materialCode: data.materialCode ?? '',
      size: size,
      inBoxQty: qty,
      customsDeclarationUnit: data.customsDeclarationUnit ?? '',
      customsDeclarationType: data.customsDeclarationType ?? '',
      pieceNo: data.pieceNo ?? '',
      pieceID: data.pieceID ?? '',
      grossWeight: data.grossWeight.toShowString(),
      netWeight: data.netWeight.toShowString(),
      specifications: data.meas ?? '',
      volume: data.volume ?? '',
      supplier: '供应商123456',
      manufactureDate: data.manufactureDate ?? '',
      hasNotes: true,
      notes: data.notes ?? '',
    ));
  }
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
createIndonesiaLabel({
  required List<LabelInfo> list,
  required Function(List<Widget>, bool) labels,
}) {
  var labelList = <Widget>[];
  for (var data in list) {
    var qty = '';
    var typeBody = '';
    var dataList = <String, List>{};
    if (data.items!.isEmpty) {
      // 无尺码
    } else if (data.items!.length == 1) {
      //单尺码
      typeBody = (data.factoryType ?? '') + (data.items![0].size ?? '');
      qty = data.items![0].qty!.toShowString();
    } else if (data.items!.length > 1) {
      //多尺码
      typeBody = data.factoryType ?? '';
      qty = data.items!
          .map((v) => v.qty ?? 0)
          .reduce((a, b) => a.add(b))
          .toShowString();
      dataList = createSizeList(
        list: data.items!,
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
      instructionNo: data.billNo ?? '',
      generalMaterialNumber: data.materialCode ?? '',
      materialDescription: data.materialName ?? '',
      materialList: dataList,
      inBoxQty: qty,
      customsDeclarationUnit: data.customsDeclarationUnit ?? '',
      customsDeclarationType: data.customsDeclarationType ?? '',
      pieceID: data.pieceID ?? '',
      pieceNo: data.pieceNo ?? '',
      grossWeight: data.grossWeight.toShowString(),
      netWeight: data.netWeight.toShowString(),
      specifications: data.meas ?? '',
      volume: data.volume ?? '',
      supplier: '',
      manufactureDate: data.manufactureDate ?? '',
      consignee: '收货方123456',
      hasNotes: true,
      notes: data.notes ?? '',
    ));
  }
  labels.call(labelList, true);
}
