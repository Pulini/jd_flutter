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
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool isMyanmarLabel() => state.labelList
      .where((v) => v.isSelected.value)
      .any((v) => v.factoryNo == '1098');

  printLabel({bool? hasNotes}) {
    var selected = state.labelList.where((v) => v.isSelected.value).toList();
    if (selected.any((v) => v.isBoxLabel)) {
      askDialog(
        title: '打印标签',
        content: '请选择外箱标打印类型',
        confirmText: '物料标',
        confirmColor: Colors.blue,
        confirm: () =>
            toPrintView(createLabels(labels: selected, isMaterialLabel: true)),
        cancelText: '普通标',
        cancelColor: Colors.blue,
        cancel: () =>
            toPrintView(createLabels(labels: selected, isMaterialLabel: false)),
      );
    } else {
      if (selected.any((v) => v.factoryNo == '1098')) {
        askDialog(
          title: '打印标签',
          content: '是否打印备注行？',
          confirmText: '是',
          confirmColor: Colors.blue,
          confirm: () => toPrintView(createLabels(
            labels: selected,
            hasNotes: true,
          )),
          cancelText: '否',
          cancelColor: Colors.blue,
          cancel: () => toPrintView(createLabels(
            labels: selected,
            hasNotes: false,
          )),
        );
      } else {
        toPrintView(createLabels(labels: selected));
      }
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
          v[0].unit,
        ]);
      });
    }
    return dynamicOutBoxLabel110xN(
      productName: label.materialDeclarationName ?? '',
      companyOrderType: '${label.factoryNo}${label.supplementType}',
      customsDeclarationType: label.customsDeclarationType ?? '',
      materialList: materialList,
      pieceNo: label.pieceID ?? '',
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
              m.unit
            ]
        ],
        pieceNo: label.pieceNo ?? '',
        qrCode: label.labelID ?? '',
        pieceID: '${label.pieceID}',
        manufactureDate: label.manufactureDate ?? '',
        supplier: label.supplierNumber ?? '',
      );

  Widget materialStandardLabel(SapPrintLabelInfo label) {
    var materials = <String, List>{};
    if (label.subLabel!.any((v) => v.size?.isNotEmpty == true)) {
      var sizeList = <String>[];
      for (var label in label.subLabel!) {
        if (!sizeList.contains(label.size)) {
          sizeList.add(label.size ?? '');
        }
      }
      sizeList.sort();
      materials['尺码/Size/ukuran'] = [...sizeList, '总计/total'];
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
    return dynamicMaterialStandardLabel110xN(
      labelID: label.labelID ?? '',
      productName: label.materialDeclarationName ?? '',
      supplementType: '${label.factoryNo}${label.supplementType}',
      typeBody: label.typeBody ?? '',
      trackNo: label.trackNo ?? '',
      instructionNo: label.instructionNo ?? '',
      generalMaterialNumber: label.subLabel![0].generalMaterialNumber ?? '',
      materialDescription: label.subLabel![0].materialDescription ?? '',
      materialList: materials,
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
  }

  List<Widget> createLabels({
    required List<SapPrintLabelInfo> labels,
    bool? isMaterialLabel,
    bool? hasNotes,
  }) {
    var labelsView = <Widget>[];
    for (var label in labels) {
      if (label.factoryNo == '1098') {
        //缅甸标
        labelsView.add(myanmarLabel(label, hasNotes ?? false));
      } else {
        if (label.isBoxLabel) {
          //外箱大标
          labelsView.add(outBoxLabel(label, isMaterialLabel!));
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
    }
    return labelsView;
  }
}
