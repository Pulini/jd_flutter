import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'sap_inner_box_label_split_state.dart';

class SapInnerBoxLabelSplitLogic extends GetxController {
  final SapInnerBoxLabelSplitState state = SapInnerBoxLabelSplitState();

  scanCode({required String code, required Function() refresh}) {
    state.getLabelPrintInfo(
      code: code,
      error: (msg) => errorDialog(content: msg),
      refresh: refresh,
    );
  }

  preSplit() {
    hidKeyboard();
    var splitList =
        (state.originalLabel!.subLabel!).where((v) => v.splitQty.value > 0);
    state.splitLabelList.add([
      for (var v in splitList)
        SapLabelSplitInfo(
          materialNumber: v.materialNumber ?? '',
          materialName: v.materialName ?? '',
          qty: v.splitQty.value,
          unit: v.unit ?? '',
        )
    ]);
    for (var v in splitList) {
      v.canSplitQty.value = v.canSplitQty.value.sub(v.splitQty.value);
      v.splitQty.value = 0;
    }
  }

  deletePreSplit(List<SapLabelSplitInfo> newLabel) {
    for (var v in newLabel) {
      var originalMaterial = state.originalLabel!.subLabel!
          .firstWhere((v2) => v2.materialNumber == v.materialNumber);
      originalMaterial.canSplitQty.value =
          originalMaterial.canSplitQty.value.add(v.qty);
    }
    state.splitLabelList.remove(newLabel);
  }

  submitPreSplit() {
    state.submitPreSplitLabel(
      success: () {},
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool isMyanmarLabel() => state.newLabelList
      .where((v) => v.isSelected.value)
      .any((v) => v.factoryNo == '1098');

  printLabel({bool? hasNotes}) {
//1、缅甸工厂打专属标（只需判断工厂是否1098）
//2、先打大标
//    是否选择打印带物料标签 是 打印物料大标 否 打印大标
//3、打印小标
//    标签类型为非大标，且包装类型为混装
//     是 打印小标
//     否 判断是否有尺码
//            是 打印带尺码单一物料标
//            否 打印单一物料标
    var labelList = <Widget>[];
    state.newLabelList.where((v) => v.isSelected.value).forEach((label) {
      if (label.factoryNo == '1098') {
        labelList.add(dynamicMyanmarLabel110xN(
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
          customsDeclarationUnit:
              label.subLabel![0].customsDeclarationUnit ?? '',
          customsDeclarationType: label.customsDeclarationType ?? '',
          pieceNo: label.pieceNo ?? '',
          pieceID: label.pieceID ?? '',
          grossWeight: label.grossWeight.toShowString(),
          netWeight: label.netWeight.toShowString(),
          specifications: label.getLWH(),
          volume: label.volume.toShowString(),
          supplier: label.supplierNumber ?? '',
          manufactureDate: label.formatManufactureDate(),
          hasNotes: hasNotes ?? false,
        ));
      } else {
        if (!label.isBoxLabel && label.isMixMaterial) {
          labelList.add(dynamicInBoxLabel110xN(
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
          ));
        } else {
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
          labelList.add(dynamicMaterialStandardLabel110xN(
            labelID: label.labelID ?? '',
            productName: label.materialDeclarationName ?? '',
            supplementType: '${label.factoryNo}${label.supplementType}',
            typeBody: label.typeBody ?? '',
            trackNo: label.trackNo ?? '',
            instructionNo: label.instructionNo ?? '',
            generalMaterialNumber:
                label.subLabel![0].generalMaterialNumber ?? '',
            materialDescription: label.subLabel![0].materialDescription ?? '',
            materialList: materials,
            inBoxQty: label.subLabel!
                .map((v) => v.inBoxQty ?? 0)
                .reduce((a, b) => a.add(b))
                .toShowString(),
            customsDeclarationUnit:
                label.subLabel![0].customsDeclarationUnit ?? '',
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
          ));
        }
      }
    });
    toPrintView(labelList);
  }

  toPrintView(List<Widget> labelView) {
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }
}
