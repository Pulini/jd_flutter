import 'dart:typed_data';

import 'package:collection/collection.dart';
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
        .where((v) => v.isSelected.value && !(v.printCount!>0))
        .toList();

    var selectedPrintedList =
        state.labelList.where((v) => v.isSelected.value && (v.printCount!>0)).toList();

    if (selectedUnPrintList.isNotEmpty && selectedPrintedList.isNotEmpty) {
      errorDialog(content: 'part_dispatch_label_delete_error_tips'.tr);
      return;
    }

    if (!checkUserPermission('601080103')) {
      errorDialog(content: 'part_dispatch_label_no_delete_permission'.tr);
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
        state.labelList.where((v) => v.isSelected.value && (v.printCount!>0)).toList();

    var selectedUnPrintList = state.labelList
        .where((v) => v.isSelected.value && !(v.printCount!>0))
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
      errorDialog(content: 'part_dispatch_label_no_modify_lock_permission'.tr);
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
      v.isSelected.value = v.printCount! >0;
    }
  }


  void selectAllNotPrintItem() {
    for (var v in state.labelList) {
      v.isSelected.value = v.printCount ==0;
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
      await labelMultipurposeDynamic2(
        qrCode: label.largeCardNo ?? '',
        qrCodeTips:'${label.materialList!.first.totalQty()} Pr/pc',
        title: label.productName ?? '',
        subTitleList:label.partList,
        tableFirstLineTitle: 'part_dispatch_label_print_size'.tr,
        tableLastLineTitle: 'part_dispatch_label_print_total'.tr,
        tableData: {
          for (var v
              in groupBy(label.instructionList, (v) => v.instruction ?? '')
                  .entries)
            v.key: [
              for (var v2 in v.value.first.sizeList!)
                [v2.size ?? '', v2.auxQty.toString()]
            ]
        },
        bottomLeftText: 'part_dispatch_label_print_piece_no'.trArgs([label.pieceNo.toString()]),
        bottomRightText: 'part_dispatch_label_print_fetch_date'.trArgs([label.fetchDate??'']),
      );

  void printLabel(Function(List<List<Uint8List>>) labels) {
    getLabelListData().then((l) {
      if (l.isNotEmpty) {
        askDialog(content: 'part_dispatch_label_print_sure_print'.tr, confirm: () => labels.call(l));
      } else {
        errorDialog(content: 'part_dispatch_label_print_no_unprinted_labels'.tr);
      }
    });
  }

  ///获取标签列表数据
  Future<List<List<Uint8List>>> getLabelListData() async => [
        ...await Future.wait(
          state.labelList
              .where((v) => v.isSelected.value && !(v.printCount!>0))
              .toList()
              .map((label) => _createLabelData(label))
              .toList(),
        )
      ];
}
