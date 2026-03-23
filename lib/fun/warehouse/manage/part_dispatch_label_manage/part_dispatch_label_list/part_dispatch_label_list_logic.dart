import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_dispatch_label_list_state.dart';

class PartDispatchLabelListLogic extends GetxController {
  final PartDispatchLabelListState state = PartDispatchLabelListState();

  void getLabelList({
    required String? partIds,
    required int? packOrderId,
    Function()? success,
  }) {
    state.getLabelList(
      partIds: partIds,
      packOrderId: packOrderId,
      success: () => success?.call(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool buttonEnable() =>
      state.labelList.isNotEmpty &&
      state.labelList.any((v) => v.isSelected.value);

  void deleteLabel({required Function() refresh}) {
    var selectedUnPrintList = state.labelList
        .where((v) => v.isSelected.value && !v.isPrint!)
        .toList();

    var selectedPrintedList =
        state.labelList.where((v) => v.isSelected.value && v.isPrint!).toList();

    if (selectedUnPrintList.isNotEmpty && selectedPrintedList.isNotEmpty) {
      errorDialog(content: '取消选择已打印的贴标后或解锁已打印的贴标后再删除！');
      return;
    }

    if (!checkUserPermission('601080103')) {
      errorDialog(content: '没有删除权限！');
      return;
    }

    state.deleteLabelList(
      labelList: selectedUnPrintList.map((v) => v.largeCardNo ?? '').toList(),
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void printLockOrUnlock({
    required bool isPrint,
    required bool isLock,
    required Function() refresh,
  }) {
    var selectedPrintedList =
        state.labelList.where((v) => v.isSelected.value && v.isPrint!).toList();

    var selectedUnPrintList = state.labelList
        .where((v) => v.isSelected.value && !v.isPrint!)
        .toList();

    if (isLock && selectedUnPrintList.isEmpty) {
      // errorDialog(content: '所选标签已上锁！');
      return;
    }
    if (!isLock && selectedPrintedList.isEmpty) {
      // errorDialog(content: '所选标签已解锁！');
      return;
    }
    if (!isPrint && !checkUserPermission('601080112')) {
      errorDialog(content: '没有修改锁权限！');
      return;
    }
    state.lockOrUnLockLabelList(
      isLock: isLock,
      labelList: isLock
          ? selectedUnPrintList.map((v) => v.largeCardNo ?? '').toList()
          : selectedPrintedList.map((v) => v.largeCardNo ?? '').toList(),
      success: (msg) => successDialog(content: msg, back: refresh),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void selectAllPrintedItem() {
    for (var v in state.labelList) {
      v.isSelected.value = v.isPrint == true;
    }
  }

  //40016125

  void selectAllNotPrintItem() {
    for (var v in state.labelList) {
      v.isSelected.value = v.isPrint == false;
    }
  }

  void unSelectAllItem() {
    for (var v in state.labelList) {
      v.isSelected.value = false;
    }
  }

  ///创建标签数据任务列表
  Future<List<Uint8List>> _createLabelData(
    PartLabelInfo label,
  ) async =>
      await labelMultipurposeDynamic(
        qrCode: label.largeCardNo ?? '',
        title: label.getPartsName(),
        subTitle:
            '每部件${label.materialList!.first.totalQty()}${label.materialList!.first.unitName}  共${label.partList.length}个部件',
        tableTitle: label.deptName ?? '',
        tableSubTitle: label.productName ?? '',
        tableFirstLineTitle: '尺码',
        tableLastLineTitle: '合计',
        tableData: {
          for (var v
              in groupBy(label.instructionList, (v) => v.instruction ?? '')
                  .entries)
            v.key: [
              for (var v2 in v.value.first.sizeList!)
                [v2.size ?? '', v2.auxQty.toString()]
            ]
        },
        bottomLeftText1: '序号：${label.pieceNo}',
        bottomRightText1: '交期：${label.fetchDate}',
      );

  void printLabel(Function(List<List<Uint8List>>) labels) {
    getLabelListData().then((l) {
      if (l.isNotEmpty) {
        askDialog(content: '确定要打印吗？', confirm: () => labels.call(l));
      } else {
        errorDialog(content: '没有未打印标签');
      }
    });
  }

  ///获取标签列表数据
  Future<List<List<Uint8List>>> getLabelListData() async => [
        ...await Future.wait(
          state.labelList
              .where((v) => v.isSelected.value && !v.isPrint!)
              .toList()
              .map((label) => _createLabelData(label))
              .toList(),
        )
      ];
}
