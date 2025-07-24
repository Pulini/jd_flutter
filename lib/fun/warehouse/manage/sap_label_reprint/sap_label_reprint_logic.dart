import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'sap_label_reprint_state.dart';

class SapLabelReprintLogic extends GetxController {
  final SapLabelReprintState state = SapLabelReprintState();

  scanLabel(String code) {
    state.getLabelList(
      code: code,
      success: (label) {
        for (var newLabel in label) {
          if (state.labelList.none((v) => v.labelID == newLabel.labelID)) {
            state.labelList.add(newLabel);
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  searchPiece(String piece) {
    if (piece.isEmpty) return;
    state.getLabelList(
      piece: piece,
      success: (label) {
        for (var newLabel in label) {
          if (state.labelList.none((v) => v.labelID == newLabel.labelID)) {
            state.labelList.add(newLabel);
          }
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool isMyanmarLabel() => state.labelList
      .where((v) => v.isSelected.value)
      .any((v) => v.factoryNo == '1098');

  printLabel() {
    var selected = state.labelList.where((v) => v.isSelected.value).toList();
    if (selected.isNotEmpty) {
      createLabels(labels: selected, print: (labels) => toPrintView(labels));
    } else {
      errorDialog(content: '没有可打印的标签');
    }
  }

  toPrintView(List<Widget> labelView) {
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }

  Widget myanmarLabel(SapPrintLabelInfo label, bool hasNotes) =>
      dynamicMyanmarLabel110xN(
        labelID: label.labelID ?? '',
        myanmarApprovalDocument:
            label.subLabel![0].myanmarApprovalDocument ?? '',
        typeBody: label.typeBody ?? '',
        trackNo: label.trackNo ?? '',
        instructionNo: label.instructionNo ?? '',
        materialList: [
          for (var m in label.subLabel!)
            [m.materialNumber ?? '', m.specifications ?? '']
        ],
        inBoxQty: label.subLabel!
            .map((v) => v.inBoxQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.subLabel![0].customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.getLWH(),
        volume: label.volume.toShowString(),
        supplier: label.supplierNumber ?? '',
        manufactureDate: label.formatManufactureDate(),
        hasNotes: hasNotes,
        notes: label.remarks ?? '',
      );

  Map<String, List> createSizeList({
    required SapPrintLabelInfo label,
    required String sizeTitle,
    required String totalTitle,
  }) {
    var materials = <String, List>{};
    if (label.subLabel!.any((v) => v.size?.isNotEmpty == true)) {
      var sizeList = <String>[];
      for (var label in label.subLabel!) {
        if (!sizeList.contains(label.size)) {
          sizeList.add(label.size ?? '');
        }
      }
      sizeList.sort();
      materials[sizeTitle] = [...sizeList, totalTitle];
      groupBy(
        label.subLabel!,
        (v) => v.instructionNo ?? '',
      ).forEach((k, labels) {
        var list = [];
        for (var size in sizeList) {
          try {
            list.add(labels
                .firstWhere((label) => label.size == size)
                .inBoxQty
                .toShowString());
          } on StateError catch (_) {
            list.add(' ');
          }
        }
        list.add(labels
            .map((v) => v.inBoxQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString());
        materials[k] = list;
      });
    }
    return materials;
  }

  Widget myanmarSizeListLabel(SapPrintLabelInfo label, bool hasNotes) =>
      dynamicMyanmarSizeListLabel110xN(
        labelID: label.labelID ?? '',
        myanmarApprovalDocument:
            label.subLabel![0].myanmarApprovalDocument ?? '',
        typeBody: label.typeBody ?? '',
        trackNo: label.trackNo ?? '',
        materialList: createSizeList(
          label: label,
          sizeTitle: 'Size',
          totalTitle: 'Total',
        ),
        inBoxQty: label.subLabel!
            .map((v) => v.inBoxQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.subLabel![0].customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.getLWH(),
        volume: label.volume.toShowString(),
        supplier: label.supplierNumber ?? '',
        manufactureDate: label.formatManufactureDate(),
        hasNotes: hasNotes,
        notes: label.remarks ?? '',
      );

  Widget myanmarSizeLabel(SapPrintLabelInfo label, bool hasNotes) =>
      dynamicMyanmarSizeLabel110xN(
        labelID: label.labelID ?? '',
        myanmarApprovalDocument:
            label.subLabel![0].myanmarApprovalDocument ?? '',
        typeBody: label.typeBody ?? '',
        trackNo: label.trackNo ?? '',
        instructionNo: label.instructionNo ?? '',
        materialCode: label.subLabel!.first.generalMaterialNumber ?? '',
        size: label.subLabel!.first.size ?? '',
        inBoxQty: label.subLabel!
            .map((v) => v.inBoxQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.subLabel![0].customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceNo: label.pieceNo ?? '',
        pieceID: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.getLWH(),
        volume: label.volume.toShowString(),
        supplier: label.supplierNumber ?? '',
        manufactureDate: label.formatManufactureDate(),
        hasNotes: hasNotes,
        notes: label.remarks ?? '',
      );

  Widget outBoxLabel(SapPrintLabelInfo label, bool isMaterialLabel) {
    var materialList = <List>[];
    if (isMaterialLabel) {
      var subList = <SapPrintLabelSubInfo>[
        for (var sub in state.labelList.where((v) => !v.isBoxLabel))
          ...sub.subLabel!
      ];
      groupBy(subList, (v) => v.generalMaterialNumber).forEach((k, v) {
        materialList.add([
          k,
          v[0].materialDescription.allowWordTruncation(),
          v
              .map((v2) => v2.inBoxQty ?? 0)
              .reduce((a, b) => a.add(b))
              .toShowString(),
          v[0].customsDeclarationUnit,
        ]);
      });
    }
    return dynamicOutBoxLabel110xN(
      productName: label.materialDeclarationName ?? '',
      companyOrderType: '${label.factoryNo}${label.supplementType}',
      customsDeclarationType: label.customsDeclarationType ?? '',
      materialList: materialList,
      pieceNo: label.pieceNo ?? '',
      grossWeight: label.grossWeight.toShowString(),
      netWeight: label.netWeight.toShowString(),
      qrCode: label.labelID ?? '',
      pieceID: label.pieceID ?? '',
      specifications: label.getLWH(),
      volume: label.volume.toShowString(),
      supplier: label.supplierNumber ?? '',
      manufactureDate: label.manufactureDate ?? '',
      consignee: label.shipToParty ?? '',
    );
  }

  Widget inBoxLabel(SapPrintLabelInfo label) => dynamicInBoxLabel110xN(
        productName: label.materialDeclarationName ?? '',
        companyOrderType: '${label.factoryNo}${label.supplementType}',
        customsDeclarationType: label.customsDeclarationType ?? '',
        materialList: [
          for (var m in label.subLabel!)
            [
              m.materialNumber,
              m.materialName,
              m.inBoxQty.toShowString(),
              m.customsDeclarationUnit
            ]
        ],
        pieceNo: label.pieceNo ?? '',
        qrCode: label.labelID ?? '',
        pieceID: '${label.pieceID}',
        manufactureDate: label.manufactureDate ?? '',
        supplier: label.supplierNumber ?? '',
      );

  Widget materialStandardLabel(SapPrintLabelInfo label) =>
      dynamicMaterialStandardLabel110xN(
        labelID: label.labelID ?? '',
        productName: label.materialDeclarationName ?? '',
        supplementType: '${label.factoryNo}${label.supplementType}',
        typeBody: label.typeBody ?? '',
        trackNo: label.trackNo ?? '',
        instructionNo: label.instructionNo ?? '',
        generalMaterialNumber: label.subLabel![0].generalMaterialNumber ?? '',
        materialDescription: label.subLabel![0].materialDescription ?? '',
        materialList: createSizeList(
          label: label,
          sizeTitle: '尺码/Size/ukuran',
          totalTitle: '总计/total',
        ),
        inBoxQty: label.subLabel!
            .map((v) => v.inBoxQty ?? 0)
            .reduce((a, b) => a.add(b))
            .toShowString(),
        customsDeclarationUnit: label.subLabel![0].customsDeclarationUnit ?? '',
        customsDeclarationType: label.customsDeclarationType ?? '',
        pieceID: label.pieceID ?? '',
        pieceNo: label.pieceNo ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        specifications: label.getLWH(),
        volume: label.volume.toShowString(),
        supplier: label.supplierNumber ?? '',
        manufactureDate: label.manufactureDate ?? '',
        consignee: label.shipToParty ?? '',
      );

  createLabels({
    required List<SapPrintLabelInfo> labels,
    required Function(List<Widget>) print,
  }) {
    var index=0;
    try {
      var labelsView = <Widget>[];
      loadingShow('加载标签数据...');
      for (var label in labels) {
        if (label.factoryNo == '1098') {
          if (label.subLabel!.any((v) => v.size?.isNotEmpty == true)) {
            //缅甸标
            if (label.subLabel!.length > 1) {
              //多尺码物料标
              labelsView
                  .add(myanmarSizeListLabel(label, state.labelHasNots.value));
            } else {
              //单尺码物料标
              labelsView.add(myanmarSizeLabel(label, state.labelHasNots.value));
            }
          } else {
            //面料标
            labelsView.add(myanmarLabel(label, state.labelHasNots.value));
          }
        } else {
          if (label.isBoxLabel) {
            //外箱大标
            labelsView.add(outBoxLabel(label, state.isMaterialLabel.value));
          } else {
            if (label.isMixMaterial) {
              //小标
              labelsView.add(inBoxLabel(label));
            } else {
              //尺码物料标
              labelsView.add(materialStandardLabel(label));
            }
          }
        }
        index++;
      }
      loadingDismiss();
      print.call(labelsView);
    } catch (e) {
      loadingDismiss();
      errorDialog(content:'第<${index+1}>张标签<${labels[index].pieceID}>数据异常!');
    }
  }

  isSelectedAll() =>
      state.labelList.isNotEmpty &&
      state.labelList.every((v) => v.isSelected.value);


  cleanLabels() {
    askDialog(content: '确定要清空标签吗？', confirm: () => state.labelList.clear());
  }

  selectAll(bool isSelect) {
    for (var v in state.labelList) {
      v.isSelected.value = isSelect;
    }
  }
}
