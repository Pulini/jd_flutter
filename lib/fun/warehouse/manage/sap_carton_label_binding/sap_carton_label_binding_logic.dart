import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/sap_carton_label_binding_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'sap_carton_label_binding_state.dart';

class SapCartonLabelBindingLogic extends GetxController {
  final SapCartonLabelBindingState state = SapCartonLabelBindingState();

  @override
  onReady() {
    getOperationType();
    super.onReady();
  }

  getOperationType() {
    ever(state.labelList, (v) {
      var list = _getBoxLabelListAndLabelList();
      List<List<SapLabelBindingInfo>> boxLabelList = list[0];
      List<SapLabelBindingInfo> labelList = list[1];
      //无大标 有小标 = 小标绑定到系统生成的大标
      //单个大标 无小标 = 大标解绑
      //单个大标 有小标 = 小标绑定到大标
      //多个大标 无小标 = 前面扫大标转移到最后一个大标
      //多个大标 有小标 = 前面扫大标和小标转移到最后一个大标

      //无大标并且无小标 = 初始状态
      if (boxLabelList.isEmpty && labelList.isEmpty) {
        state.operationType = ScanLabelOperationType.unKnown;
        state.operationTypeText.value = ScanLabelOperationType.unKnown.text;
      }

      //无大标 有小标 = 小标绑定到系统生成的大标
      if (boxLabelList.isEmpty && labelList.isNotEmpty) {
        state.operationType = ScanLabelOperationType.create;
        state.operationTypeText.value = ScanLabelOperationType.create.text;
      }

      //单个大标 无小标 = 大标解绑
      if (boxLabelList.length == 1 && labelList.isEmpty) {
        state.operationType = ScanLabelOperationType.unbind;
        state.operationTypeText.value = ScanLabelOperationType.unbind.text;
      }

      //单个大标 有小标 = 小标绑定到大标
      if (boxLabelList.length == 1 && labelList.isNotEmpty) {
        state.operationType = ScanLabelOperationType.binding;
        state.operationTypeText.value = ScanLabelOperationType.binding.text;
      }

      //多个大标 无小标 = 前面扫大标转移到最后一个大标
      //多个大标 有小标 = 前面扫大标和小标转移到最后一个大标
      if (boxLabelList.length > 1) {
        state.operationType = ScanLabelOperationType.transfer;
        state.operationTypeText.value = ScanLabelOperationType.transfer.text;
      }
      debugPrint('operationType=${state.operationType}');
    });
  }

  scanLabel(String code) {
    if (state.labelList.any((v) => v.labelID == code || v.boxLabelID == code)) {
      errorDialog(content: '标签已存在');
    } else {
      state.getLabelInfo(
        labelCode: code,
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  List _getBoxLabelListAndLabelList() {
    List<List<SapLabelBindingInfo>> boxLabelList = [];
    List<SapLabelBindingInfo> labelList = [];
    var list =
        groupBy(state.labelList, (v) => v.isBoxLabel ? v.labelID : v.boxLabelID)
            .values
            .toList();
    for (var item in list) {
      if (item.any((v) => v.isBoxLabel)) {
        boxLabelList.add(item);
      } else {
        labelList.addAll(item);
      }
    }
    debugPrint(
        'boxLabelList=${boxLabelList.length},labelList=${labelList.length}');
    return [boxLabelList, labelList];
  }

  List<List<SapLabelBindingInfo>> getLabelList() {
    var list = _getBoxLabelListAndLabelList();
    List<List<SapLabelBindingInfo>> boxLabelList = list[0];
    List<SapLabelBindingInfo> labelList = list[1];
    return [
      if (labelList.isNotEmpty) labelList,
      if (boxLabelList.isNotEmpty) ...boxLabelList
    ];
  }

  deleteLabel(SapLabelBindingInfo sub) {
    state.labelList.remove(sub);
  }

  SapLabelBindingInfo? getTargetBoxLabel() {
    if (state.operationType == ScanLabelOperationType.create) {
      return null;
    } else {
      return (_getBoxLabelListAndLabelList()[0]
              as List<List<SapLabelBindingInfo>>)
          .last
          .firstWhere((v) => v.isBoxLabel);
    }
  }

  operationSubmit({
    required double long,
    required double width,
    required double height,
    required double outWeight,
  }) {
    var list = _getBoxLabelListAndLabelList();
    List<List<SapLabelBindingInfo>> boxLabelList = list[0];
    List<SapLabelBindingInfo> labelList = list[1];
    SapLabelBindingInfo? targetBoxLabel;
    if (state.operationType != ScanLabelOperationType.create) {
      targetBoxLabel = boxLabelList.last.firstWhere((v) => v.isBoxLabel);
      for (var i = 0; i < boxLabelList.length - 1; ++i) {
        labelList.addAll(boxLabelList[i]);
      }
    }
    state.operationSubmit(
      long: long,
      width: width,
      height: height,
      outWeight: outWeight,
      targetBoxLabelID: targetBoxLabel?.labelID ?? '',
      supplierNumber: targetBoxLabel == null
          ? labelList[0].supplierNumber ?? ''
          : targetBoxLabel.supplierNumber ?? '',
      labelList: labelList,
      success: (msg) => successDialog(
        content: msg,
        back: () => askDialog(
          content: '要打印新外箱标吗？',
          confirm: () => printNewBoxLabel(),
        ),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  printNewBoxLabel() {
    state.getLabelPrintInfo(
      success: (labelsData) {
        askDialog(
          title: '打印标签',
          content: '请选择标签打印类型',
          confirmText: '物料标',
          confirmColor: Colors.blue,
          confirm: () => toPrintView(createOutBoxLabel(labelsData, true)),
          cancelText: '普通标',
          cancelColor: Colors.blue,
          cancel: () => toPrintView(createOutBoxLabel(labelsData, false)),
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  toPrintView(List<Widget> labelView) {
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }

  List<Widget> createOutBoxLabel(
    Map<SapPrintLabelInfo, List<SapPrintLabelSubInfo>> labelList,
    bool hasMaterialList,
  ) {
    var labelView = <Widget>[];
    labelList.forEach((label, materials) {
      var materialList = <List>[];
      if (hasMaterialList) {
        groupBy(materials, (v) => v.generalMaterialNumber).forEach((k, v) {
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
      labelView.add(dynamicOutBoxLabel110xN(
        productName: label.materialDeclarationName ?? '',
        companyOrderType: '${label.factoryNo}${label.supplementType}',
        customsDeclarationType: label.customsDeclarationType ?? '',
        materialList: materialList,
        pieceNo: label.pieceID ?? '',
        grossWeight: label.grossWeight.toShowString(),
        netWeight: label.netWeight.toShowString(),
        qrCode: label.labelID ?? '',
        pieceID: label.pieceID ?? '',
        specifications:label.getLWH(),
        volume: label.volume.toShowString(),
        supplier: label.supplierNumber ?? '',
        manufactureDate: label.manufactureDate ?? '',
        consignee: label.shipToParty ?? '',
      ));
    });
    return labelView;
  }


}
