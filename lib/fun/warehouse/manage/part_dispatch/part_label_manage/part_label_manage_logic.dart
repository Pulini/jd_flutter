import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_list_widget.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_75w.dart';

import 'part_label_manage_state.dart';

class PartLabelManageLogic extends GetxController {
  final PartLabelManageState state = PartLabelManageState();

  void queryLabels(String barCode) {
    if(state.labelList.any((v)=>v.largeCardNo==barCode)){
      errorDialog(content: 'part_label_manage_label_already_exists'.tr);
      return;
    }
    state.getLabelList(
      barCode: barCode,
      error: (msg) => errorDialog(content: msg),
    );
  }

  bool printIsEnabled() =>
      state.labelList.isNotEmpty &&
      state.labelList.any((v) => v.isSelected.value);

  bool splitIsEnabled() =>
      state.labelList.isNotEmpty &&
      state.labelList.where((v) => v.isSelected.value).length == 1;

  bool mergeIsEnabled() =>
      state.labelList.isNotEmpty &&
      state.labelList.where((v) => v.isSelected.value).length > 1;

  void printLabel() {
    var labelView = state.labelList
        .where((v) => v.isSelected.value)
        .map((v) => createPartLabel(v))
        .toList();
    Get.to(() => labelView.length > 1
        ? PreviewLabelList(labelWidgets: labelView, isDynamic: true)
        : PreviewLabel(labelWidget: labelView[0], isDynamic: true));
  }

  void splitLabel(PartLabelInfo label, int qty) {
    state.splitOrMergeLabel(
      labels: [label.largeCardNo ?? ''],
      splitQty: qty,
      success: (label, msg) => successDialog(
        content: msg,
        back: () {
          state.labelList.clear();
          state.getLabelList(
            barCode: label,
            error: (msg) => errorDialog(content: msg),
          );
        },
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void mergeLabel() {
    state.splitOrMergeLabel(
      labels: state.labelList
          .where((v) => v.isSelected.value)
          .map((v) => v.largeCardNo ?? '')
          .toList(),
      splitQty: 0,
      success: (label, msg) => successDialog(
        content: msg,
        back: () {
          state.labelList.clear();
          state.getLabelList(
            barCode: label,
            error: (msg) => errorDialog(content: msg),
          );
        },
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}

Widget createPartLabel(PartLabelInfo label) => partDynamicLabel(
      qrCode: label.largeCardNo ?? '',
      qrCodeTips: '${label.materialList!.first.totalQty()} Pr/pc',
      title: label.productName ?? '',
      subTitleList: label.partList,
      tableFirstLineTitle: 'part_dispatch_label_print_size'.tr,
      tableLastLineTitle: 'part_dispatch_label_print_total'.tr,
      map: {
        for (var v in groupBy(label.instructionList, (v) => v.instruction ?? '')
            .entries)
          v.key: [
            for (var v2 in v.value.first.sizeList!)
              [v2.size ?? '', v2.auxQty.toString()]
          ]
      },
      pageNumber: 'part_dispatch_label_print_piece_no'.trArgs(
        [label.pieceNo.toString()],
      ),
      deliveryDate: 'part_dispatch_label_print_fetch_date'.trArgs(
        [label.fetchDate ?? ''],
      ),
    );
