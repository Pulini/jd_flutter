import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/pack_order_list_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/confirm_packing_method/confirm_packing_method_view.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_templates/dynamic_label_75w.dart';

import 'part_label_manage_state.dart';

class PartLabelManageLogic extends GetxController {
  final PartLabelManageState state = PartLabelManageState();

  /// 已选中 + 符合打印状态筛选的标签列表
  List<PartLabelInfo> get _selectedFilteredList => state.labelList
      .where((v) => v.isSelected.value && _matchPrintFilter(v))
      .toList();

  /// 符合打印状态筛选（不含 isSelected）
  List<PartLabelInfo> get filteredByPrintState =>
      state.labelList.where((v) => _matchPrintFilter(v) && _matchSearchFilter(v)).toList();

  bool _matchPrintFilter(PartLabelInfo v) =>
      state.isPrinted.value ? v.printCount! > 0 : v.printCount == 0;

  bool _matchSearchFilter(PartLabelInfo v) {
    var keyword = state.searchText.value;
    if (keyword.isEmpty) return true;
    return [
      v.productName,
      v.billNo,
      v.packageType,
      ...v.partList,
      ...v.instructionList.map((e) => e.instruction),
      ...v.sizeList.map((v)=>v.size),
      ...v.sizeList.map((v)=>v.auxQty.toString()),
    ].any((s) => s?.contains(keyword) == true);
  }

  void query({required String barCode}) {
    state.getLabelList(
      barCode: barCode,
      noPackingMethod: () => toConfirmPackingMethod(barCode),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void toConfirmPackingMethod(String barCode) {
    Get.to(
      const ConfirmPackingMethodPage(),
      arguments: {'BarCode': barCode},
    )?.then((v) {
      if (v != null && v == true) {
        query(barCode: barCode);
      }
    });
  }

  bool buttonEnable() => _selectedFilteredList.isNotEmpty;

  void deleteLabel() {
    var selectedList = _selectedFilteredList;

    if (!checkUserPermission('601080103')) {
      errorDialog(content: 'part_dispatch_label_no_delete_permission'.tr);
      return;
    }

    state.deleteLabelList(
      labelList: selectedList.map((v) => v.largeCardNo ?? '').toList(),
      success: (msg) => successDialog(
        content: msg,
        back: () => query(barCode: state.barCode),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///创建标签数据任务列表
  Future<List<Uint8List>> _createLabelData(PartLabelInfo label) async =>
      await labelMultipurposeDynamic2(
        qrCode: label.largeCardNo ?? '',
        qrCodeTips: '${label.materialList!.first.totalQty()} Pr/pc',
        title: label.productName ?? '',
        subTitleList: label.partList,
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
        bottomLeftText: 'part_dispatch_label_print_piece_no'.trArgs(
          [label.pieceNo.toString()],
        ),
        bottomRightText: 'part_dispatch_label_print_fetch_date'.trArgs(
          [label.fetchDate ?? ''],
        ),
      );

  void upDateLabelState(List<int> successList) {
    var list = _selectedFilteredList.map((v) => v.largeCardNo ?? '').toList();
    logger.d(list);
    var needUpdateList = <String>[];
    for (var v in successList) {
      needUpdateList.add(list[v]);
    }
    state.updateLabelPrintState(
      labelList: needUpdateList,
      success: () => query(barCode: state.barCode),
      error: (msg) => errorDialog(content: msg),
    );
  }

  void printLabel(Function(List<List<Uint8List>>) labels) {
    getLabelListData().then((l) {
      if (l.isNotEmpty) {
        askDialog(
          content: 'part_dispatch_label_print_sure_print'.tr,
          confirm: () => labels.call(l),
        );
      } else {
        errorDialog(
          content: 'part_dispatch_label_print_no_unprinted_labels'.tr,
        );
      }
    });
  }

  ///获取标签列表数据
  Future<List<List<Uint8List>>> getLabelListData() async => [
        ...await Future.wait(
          _selectedFilteredList
              .map((label) => _createLabelData(label))
              .toList(),
        )
      ];

  void selectAllItem({required bool isSelect}) {
    state.selectAll.value = isSelect;
    for (var v in state.labelList) {
      v.isSelected.value = isSelect;
    }
  }

  void viewLabel({required PartLabelInfo label}) {
    Get.to(() => PreviewLabel(
          labelWidget: partDynamicLabel(
            qrCode: label.largeCardNo ?? '',
            qrCodeTips: '${label.materialList!.first.totalQty()} Pr/pc',
            title: label.productName ?? '',
            subTitleList: label.partList,
            tableFirstLineTitle: 'part_dispatch_label_print_size'.tr,
            tableLastLineTitle: 'part_dispatch_label_print_total'.tr,
            map: {
              for (var v
                  in groupBy(label.instructionList, (v) => v.instruction ?? '')
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
          ),
          isDynamic: true,
        ));
  }
}
