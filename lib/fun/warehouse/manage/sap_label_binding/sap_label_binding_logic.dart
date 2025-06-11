import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/sap_label_binding_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';

import 'sap_label_binding_state.dart';

class SapLabelBindingLogic extends GetxController {
  final SapLabelBindingState state = SapLabelBindingState();

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
      success: (labels) {

        // if (labels.length > 1) {
        //   Get.to(() => PreviewLabelList(labelWidgets: labels));
        // } else {
        //   Get.to(() => PreviewLabel(labelWidget: labels[0]));
        // }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  // Widget label1() {
  //   return dynamicLabelTemplate110xN(
  //     productName: 'productName',
  //     companyOrderType: 'companyOrderType',
  //     customsDeclarationType: 'orderType',
  //     pieceNo: 'pieceNo',
  //     grossWeight: 'grossWeight',
  //     netWeight: 'netWeight',
  //     qrCode: 'qrCode',
  //     code: 'code',
  //     specifications: 'specifications',
  //     volume: 'volume',
  //     supplier: 'supplier',
  //     manufactureDate: 'manufactureDate',
  //     consignee: 'consignee',
  //   );
  // }
}
