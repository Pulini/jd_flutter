import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_dispatch_label_manage_info.dart';
import 'package:jd_flutter/fun/warehouse/manage/part_dispatch_label_manage/part_dispatch_order_list/part_dispatch_order_create_label_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_dispatch_order_list_state.dart';

class PartDispatchLabelManageLogic extends GetxController {
  final PartDispatchLabelManageState state = PartDispatchLabelManageState();

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  void queryInstruction({
    String? code,
    String? productName,
    String? startTime,
    String? endTime,
    required Function(List<PartDispatchOrderBatchGroupInfo>) show,
  }) {
    success(List<PartDispatchInstructionInfo> list) {
      var group = <PartDispatchOrderBatchGroupInfo>[];
      groupBy(list, (v) => v.batchNo ?? '').forEach((k1, v1) {
        var intList = groupBy((v1), (v2) => v2.seOrderNo ?? '')
            .values
            .map((v3) =>
            PartDispatchOrderInstructionGroupInfo(
              totalQty: v3
                  .map((v) => v.workCardQty ?? 0)
                  .reduce((a, b) => a.add(b)),
              dataList: v3,
            ))
            .toList();
        group.add(
          PartDispatchOrderBatchGroupInfo(
            typeBody: v1.first.productName ?? '',
            batchNo: k1,
            totalQty:
            v1.map((v) => v.workCardQty ?? 0).reduce((a, b) => a.add(b)),
            insList: intList,
          ),
        );
      });
      show.call(group);
    }
    // success(List<PartDispatchInstructionInfo> list) => show.call(
    //     groupBy(list, (v) => '${v.seOrderNo} - ${v.batchNo}').values.toList());

    error(String msg) => errorDialog(content: msg);

    if (code.isNullOrEmpty()) {
      if (productName.isNullOrEmpty()) {
        errorDialog(content: '请输入完整型体');
        return;
      }
      state.getInstructions(
        productName: productName,
        startTime: startTime,
        endTime: endTime,
        success: success,
        error: error,
      );
    } else {
      state.getInstructions(
        barCode: code,
        success: success,
        error: error,
      );
    }
  }

  void queryOrderDetail(List<int> list, bool isSingleInstruction) {
    state.getPartOrderDetails(
      list: list,
      isSingleInstruction: isSingleInstruction,
      error: (msg) => errorDialog(content: msg),
    );
  }

  void toCreateLabel() {
    var selectList = state.partList.where((v) => v.isSelected.value);
    if (selectList
        .map((v) => v.packTypeID)
        .toSet()
        .length > 1) {
      errorDialog(content: '装箱方式不同，禁止同时操作！');
      return;
    }
    state.createSizeList.clear();
    state.getDispatchOrdersSizeDetail(
      orders: selectList.expand((v) => v.workCardEntryIdList!).toList(),
      success: (list) {
        state.createSizeList.addAll(
          groupBy(list, (v) => v.size!)
              .values
              .map((v) => CreateLabelInfo(v))
              .toList(),
        );
        state.isSingleSize = selectList.first.packTypeID == 479;
        state.hasLastLabel = false;
        Get.to(() => PartDispatchOrderCreateLabelPage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void refreshCreateLabel() {
    state.createSizeList.clear();
    state.getDispatchOrdersSizeDetail(
      orders: state.partList
          .where((v) => v.isSelected.value)
          .expand((v) => v.workCardEntryIdList!)
          .toList(),
      success: (list) {
        state.createSizeList.addAll(
          groupBy(list, (v) => v.size!)
              .values
              .map((v) => CreateLabelInfo(v))
              .toList(),
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///获取缓存的批量设置Item装箱数
  int getSaveBatchSetItemPackQty() {
    int savePackQty = spGet('${Get.currentRoute}/BatchSetPackQty') ?? 0;
    return savePackQty == 0 ? 100 : savePackQty;
  }

  ///获取缓存的批量设置Item标签数
  int getSaveBatchSetItemLabelCount() {
    int saveLabelCount = spGet('${Get.currentRoute}/BatchSetLabelCount') ?? 0;
    return saveLabelCount == 0 ? 1 : saveLabelCount;
  }

  bool isCanSet() =>
      state.createSizeList.isNotEmpty &&
          state.createSizeList.any((v) => v.isSelected.value);

  void setLabelCountListener(TextEditingController controller) {
    var select = state.createSizeList.where((v) => v.isSelected.value);
    if (select.isEmpty) return;
    var labelCount = controller.text.toIntTry();
    var max =
    select.map((v) => v.maxLabelCount()).reduce((a, b) => a < b ? a : b);
    if (labelCount > max) {
      controller.text = max.toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  void refreshMixLabelCount(TextEditingController controller) {
    if (!state.isSingleSize) {
      var select = state.createSizeList.where((v) => v.isSelected.value);
      if (select.isEmpty) return;
      controller.text = select
          .map((v) => v.maxLabelCount())
          .reduce((a, b) => a < b ? a : b)
          .toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  ///表头批量设置装箱数
  void batchSetItemPackQty(int qty) {
    hidKeyboard();
    state.createSizeList.where((v) => v.isSelected.value).forEach((v) {
      v.packageQty.value = qty > v.maxPackageQty() ? v.maxPackageQty() : qty;
    });
    spSave('${Get.currentRoute}/BatchSetPackQty', qty);
    state.createSizeList.refresh();
  }

  ///表头批量设置装箱数
  void batchSetItemMaxPackQty() {
    hidKeyboard();
    state.createSizeList.where((v) => v.isSelected.value).forEach((v) {
      v.packageQty.value = v.maxPackageQty();
    });
    state.createSizeList.refresh();
  }

  ///设置装箱数量输入框监听
  void setItemPackQtyListener({
    required TextEditingController controller,
    required CreateLabelInfo data,
  }) {
    var qtyString = controller.text;
    if (!qtyString.endsWith('.') && !qtyString.hasTrailingZero()) {
      var qty = qtyString.toIntTry();
      var setQty = qty;
      var max = data.remainingQty();
      if (double.tryParse(qtyString) != null && qty > max) {
        setQty = max;
      }
      data.packageQty.value = setQty;
      controller.text = setQty.toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  void batchSetItemLabelCount(int count) {
    hidKeyboard();
    state.createSizeList.where((v) => v.isSelected.value).forEach((v) {
      v.labelCount.value =
      count > v.maxLabelCount() ? v.maxLabelCount() : count;
    });
    spSave('${Get.currentRoute}/BatchSetLabelCount', count);
    state.createSizeList.refresh();
  }

  void batchSetItemMaxLabelCount() {
    hidKeyboard();
    state.createSizeList.where((v) => v.isSelected.value).forEach((v) {
      v.labelCount.value = v.maxLabelCount();
    });
    state.createSizeList.refresh();
  }

  ///设置标签数量输入框监听
  void setItemLabelCountListener({
    required TextEditingController controller,
    required CreateLabelInfo data,
  }) {
    var qty = controller.text.toIntTry();
    var max = data.maxLabelCount();
    data.labelCount.value = qty > max ? max : qty;
    if (qty > max) {
      controller.text = max.toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  bool canCreateLabel() =>
      state.isSingleSize
          ? state.createSizeList.isNotEmpty &&
          state.createSizeList.any(
                (v) =>
            v.isSelected.value &&
                v.packageQty.value > 0 &&
                v.labelCount.value > 0,
          )
          : state.createSizeList.isNotEmpty &&
          state.createSizeList.any(
                (v) => v.isSelected.value && v.packageQty.value > 0,
          );

}
