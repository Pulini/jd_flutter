import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_detail_view.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch_d/part_production_dispatch_label_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/printer/tsc_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_production_dispatch_state.dart';

class PartProductionDispatchLogic extends GetxController {
  final PartProductionDispatchState state = PartProductionDispatchState();

  ///查询派工单列表
  void queryOrders({
    required String startTime,
    required String endTime,
    required String instruction,
  }) {
    state.getPartProductionDispatchOrderList(
      startTime: startTime,
      endTime: endTime,
      instruction: instruction,
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///是否显示关闭状态变更
  void changeClosedStatus(bool isSelect) {
    state.isSelectedClosed.value = isSelect;
    spSave('${Get.currentRoute}/isSelectedClosed', isSelect);
  }

  ///获取派工单详情并跳转标签生成页面
  void toDetail(Function() refresh) {
    refreshOrderDetail(() {
      state.created.value = false;
      state.worker = null;
      state.createCount.value = 0;
      state.errorMsg.value = '';
      state.workerName.value = '';
      Get.to(() => PartProductionDispatchDetailPage())?.then((_) {
        if (state.created.value) refresh.call();
      });
    });
  }

  ///获取缓存的批量设置Item装箱数
  double getSaveBatchSetItemPackQty() {
    double savePackQty = spGet('${Get.currentRoute}/BatchSetPackQty') ?? 0.0;
    return savePackQty == 0 ? 100 : savePackQty;
  }

  ///获取缓存的批量设置Item标签数
  int getSaveBatchSetItemLabelCount() {
    int saveLabelCount = spGet('${Get.currentRoute}/BatchSetLabelCount') ?? 0;
    return saveLabelCount == 0 ? 1 : saveLabelCount;
  }

  ///切换指令
  void changeInstruction(int index) {
    state.instructionSelect.value = index;
    for (var v2 in state.sizeList) {
      v2.isShow.value = v2.instruction() == state.instructionList[index];
    }
  }

  ///设置装箱数量输入框监听
  void setItemPackQtyListener({
    required TextEditingController controller,
    required CreateLabelInfo data,
  }) {
    var qtyString = controller.text;
    if (!qtyString.endsWith('.') && !qtyString.hasTrailingZero()) {
      var qty = qtyString.toDoubleTry();
      var setQty = qty;
      var max = data.remainingQty();
      if (double.tryParse(qtyString) != null && qty > max) {
        setQty = max;
      }
      data.qty.value = setQty;
      controller.text = setQty.toShowString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    refreshCountMax();
  }

  ///设置标签数量输入框监听
  void setItemLabelCountListener({
    required TextEditingController controller,
    required CreateLabelInfo data,
  }) {
    var qty = controller.text.toIntTry();
    var max = data.canCreateCount();
    data.createCount.value = qty > max ? max : qty;
    if (qty > max) {
      controller.text = max.toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

 int getInstructionSizeItemMaxCount() {
  var itemMax= state.sizeList
       .where((v) => v.isShow.value && v.isSelected.value)
       .map((v) => v.canCreateCount())
       .reduce((a, b) => a > b ? a : b);
  debugPrint('ItemMaxCount: $itemMax');
  return itemMax;
 }

  ///表头批量设置装箱数输入框监听
  void batchSetPackQtyListener(TextEditingController controller) {
    var strQty = controller.text;
    //去除多余小数点
    if (strQty.split('.').length > 2) {
      controller.text = strQty.substring(0, strQty.lastIndexOf('.'));
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
    //输入值
    var qty = strQty.toDoubleTry();
    //最大值唯当前指令下所有尺码中的最大剩余数
    var max = state.sizeList
        .where((v) => v.isShow.value && v.isSelected.value)
        .map((v) => v.remainingQty())
        .reduce((a, b) => a > b ? a : b);
    //防止输入值溢出
    if (qty > max) {
      controller.text = max.toShowString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  ///表头批量设置装箱数
  void batchSetItemPackQty(TextEditingController controller) {
    hidKeyboard();
    var qty = controller.text.toDoubleTry();
    state.sizeList
        .where((v) => v.isShow.value && v.isSelected.value)
        .forEach((v) {
      v.qty.value = qty > v.remainingQty() ? v.remainingQty() : qty;
    });
    spSave('${Get.currentRoute}/BatchSetPackQty', qty);
    controller.text = qty.toShowString();
    refreshCountMax();
  }

  ///表头批量设置标签数输入框监听
  void batchSetLabelCountListener(TextEditingController controller) {
    var max = getInstructionSizeItemMaxCount();
    if (controller.text.toIntTry() > max) {
      controller.text = max.toString();
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    }
  }

  ///表头批量设置标签数
  void batchSetItemLabelCountQty(String qtyString) {
    var qty = qtyString.toIntTry();
    state.sizeList
        .where((v) => v.isShow.value && v.isSelected.value)
        .forEach((v) {
      var max = v.canCreateCount();
      v.createCount.value = qty > max ? max : qty;
    });
    spSave('${Get.currentRoute}/BatchSetLabelCount', qty);
  }

  ///刷新派工单详情
  void refreshOrderDetail(Function() callBack) {
    state.getPartProductionDispatchOrdersDetail(
      orders: state.orderList
          .where((v) => v.isSelected.value && v.workCardID != null)
          .map((v) => v.workCardID!)
          .toList(),
      success: () {
        state.instructionList.value = [];
        state.instructionSelect.value = 0;
        state.detailInfo!.instruction?.split(',').forEach((data) {
          if (data.isNotEmpty) {
            state.instructionList.add(data);
          }
        });
        var cList = <CreateLabelInfo>[];
        groupBy(state.detailInfo!.sizeList!, (v) => v.instruction ?? '')
            .forEach((k, v) {
          groupBy(v, (v2) => v2.size ?? '').forEach((k2, v2) {
            cList.add(CreateLabelInfo()
              ..partList = v2
              ..isShow.value = k == state.instructionList[0]);
          });
        });
        state.sizeList.value = cList;
        callBack.call();
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///检查员工
  void checkWorker(String number) {
    if (number.length >= 6) {
      getWorkerInfo(
        number: number,
        workers: (wList) {
          state.worker = wList.first;
          state.errorMsg.value = '';
          state.workerName.value = state.worker!.empName ?? '';
        },
        error: (msg) {
          state.worker = null;
          state.errorMsg.value = '没有找到该员工';
          state.workerName.value = '';
        },
      );
    } else {
      state.errorMsg.value = '';
      state.workerName.value = '';
    }
  }

  ///单指令单码标 可生成标签数上限校验
  int _singleInstructionAndSingleSize(List<CreateLabelInfo> select) {
    if (select.isEmpty) return 0;
    //上限为所有所选的指令中的每个所选码的可生成标签数的最大公倍数
    return select
        .map((v) => v.canCreateCount())
        .reduce((a, b) => a > b ? a : b);
  }

  ///单指令混码标 可生成标签数上限校验
  int _singleInstructionAndMoreSize(List<CreateLabelInfo> select) {
    if (select.isEmpty) return 0;

    if (state.checkSizeQty.value) {
      //上限为所选的每个指令中的每个所选码的可生成标签数的最小公倍数的总和
      return groupBy(select, (v) => v.instruction())
          .values
          .map((v) => v
              .map((v2) => v2.canCreateCount())
              .reduce((a, b) => a < b ? a : b))
          .reduce((a, b) => a + b);
    } else {
      //如果需要创建尾标，则混装剩余码段合计生成一个标，上限为混装标+尾标
      if (state.createLastLabel.value) {
        return groupBy(select, (v) => v.instruction())
            .values
            .map((v) =>
                (v.every(
                        (v2) => v2.canCreateCount() == v.first.canCreateCount())
                    ? v.first.canCreateCount()
                    : v
                        .map((v2) => v2.canCreateCount())
                        .reduce((a, b) => a < b ? a : b)) +
                1)
            .reduce((a, b) => a + b);
      } else {
        //如无需创建尾标，则上限为单码最大可创建标签数的总和
        return groupBy(select, (v) => v.instruction())
            .values
            .map((v) => v
                .map((v2) => v2.canCreateCount())
                .reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a + b);
      }
    }
  }

  ///多指令单码标 可生成标数上限校验
  int _moreInstructionAndSingleSize(List<CreateLabelInfo> select) {
    if (state.checkSizeQty.value) {
      //上限为所有所选指令的所选相同码的可生成标签数的最小公倍数的总和
      return groupBy(select, (v) => v.size())
          .values
          .map((v) => v
              .map((v2) => v2.canCreateCount())
              .reduce((a, b) => a < b ? a : b))
          .reduce((a, b) => a + b);
    } else {
      if (state.createLastLabel.value) {
        return groupBy(select, (v) => v.size())
            .values
            .map((v) =>
                (v.every(
                        (v2) => v2.canCreateCount() == v.first.canCreateCount())
                    ? v.first.canCreateCount()
                    : v
                        .map((v2) => v2.canCreateCount())
                        .reduce((a, b) => a < b ? a : b)) +
                1)
            .reduce((a, b) => a + b);
      } else {
        return groupBy(select, (v) => v.size())
            .values
            .map((v) => v
                .map((v2) => v2.canCreateCount())
                .reduce((a, b) => a > b ? a : b))
            .reduce((a, b) => a + b);
      }
    }
  }

  ///多指令多码标 可生成标签数上限校验
  int _moreInstructionAndMoreSize(List<CreateLabelInfo> select) {
    if (select.isEmpty) return 0;

    if (state.checkSizeQty.value) {
      //上限为所有所选指令的所有所选码的可生成标签数的最小公倍数
      return select
          .map((v2) => v2.canCreateCount())
          .reduce((a, b) => a < b ? a : b);
    } else {
      if (state.createLastLabel.value) {
        return select.every(
                (v) => v.canCreateCount() == select.first.canCreateCount())
            ? select.first.canCreateCount()
            : select
                    .map((v2) => v2.canCreateCount())
                    .reduce((a, b) => a < b ? a : b) +
                1;
      } else {
        return select
            .map((v2) => v2.canCreateCount())
            .reduce((a, b) => a > b ? a : b);
      }
    }
  }

  ///刷新可生成标签数上限
  int refreshCountMax() {
    //操作数据为所有指令所有所选条目
    var select = state.sizeList
        .where((v) => v.isSelected.value && v.qty.value > 0)
        .toList();
    if (select.isEmpty) return 0;
    var max = 0;
    if (state.isSingleInstruction.value) {
      if (state.isSingleSize.value) {
        //单指令单码装
        max = _singleInstructionAndSingleSize(select);
      } else {
        //单指令混码装
        max = _singleInstructionAndMoreSize(select);
      }
    } else {
      if (state.isSingleSize.value) {
        //多指令单码装
        max = _moreInstructionAndSingleSize(select);
      } else {
        //多指令混码装
        max = _moreInstructionAndMoreSize(select);
      }
    }
    state.createCountMax.value = max;
    state.createCount.value = max;
    return max;
  }

  ///创建按钮是否可用
  bool createButtonEnable() {
    if (state.isSingleSize.value) {
      return state.workerName.isNotEmpty &&
          state.sizeList
              .any((v) => v.isSelected.value && v.createCount.value > 0);
    } else {
      return state.workerName.isNotEmpty &&
          state.sizeList.any((v) => v.isSelected.value && v.qty.value > 0) &&
          state.createCount.value > 0;
    }
  }

  ///创建标签
  void createLabel() {
    var list = state.sizeList.where((v) =>
        v.isSelected.value && state.isSingleSize.value
            ? (v.qty.value > 0 && v.createCount.value > 0)
            : v.qty.value > 0);
    state.createLabel(
      count: state.isSingleSize.value
          ? list.map((v) => v.createCount.value).reduce((a, b) => a + b)
          : state.createCount.value,
      sizeMapList: [
        for (var v in list)
          ...v.partList.map((v2) => {
                'WorkCardEntryFID': v2.workCardEntryFID,
                'Size': v2.size,
                'PackingQty': v.qty.value,
                'DispatchedQty': v2.dispatchedQty,
                'CreateCount':
                    state.isSingleSize.value ? v.createCount.value : -1,
                'RemainingQty': v2.remainingQty,
              })
      ],
      success: (msg) => successDialog(
        content: msg,
        back: () => refreshOrderDetail(() {}),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///查询标签列表
  void queryLabelList(Function() refresh) {
    state.getPartProductionDispatchLabelList(
      orders: state.orderList
          .where((v) => v.isSelected.value && v.workCardID != null)
          .map((v) => v.workCardID!)
          .toList(),
      success: () {
        state.deleted.value = false;
        Get.to(() => PartProductionDispatchLabelPage())?.then((_) {
          if (state.deleted.value) refresh.call();
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///创建标签数据任务列表
  Future<List<Uint8List>> _createLabelData(
    PartProductionDispatchLabelInfo label,
  ) async =>
      await labelMultipurposeDynamic(
        qrCode: label.barCode ?? '',
        title: label.getPartList(),
        subTitle:
            '每部件${label.getTotalQty().toShowString()}${label.unitName}  共${label.partList?.length}个部件',
        tableTitle: label.deptName ?? '',
        tableSubTitle: label.typeBody ?? '',
        tableFirstLineTitle: '尺码',
        tableLastLineTitle: '合计',
        tableData: {
          for (var v
              in groupBy(label.instructionList, (v) => v.instruction ?? '')
                  .entries)
            v.key: [
              for (var v2 in v.value.first.sizeList!)
                [v2.size ?? '', v2.qty.toShowString()]
            ]
        },
        bottomLeftText1: '序号：${label.orderNo}',
        bottomRightText1: '交期：${label.fetchDate}',
      );

  ///获取标签列表数据
  Future<List<List<Uint8List>>> getLabelListData() async => [
        ...await Future.wait(
          state.labelList
              .where((v) => v.isSelected.value)
              .map((label) => _createLabelData(label))
              .toList(),
        )
      ];

  ///删除标签
  void deleteLabels() {
    state.deleteLabelList(
      labelList: state.labelList
          .where((v) => v.isSelected.value)
          .map((v) => v.barCode!)
          .toList(),
      success: (msg) => successDialog(
        content: msg,
        back: () => state.getPartProductionDispatchLabelList(
          orders: state.orderList
              .where((v) => v.isSelected.value)
              .map((v) => v.workCardID!)
              .toList(),
          success: () {},
          error: (msg) => showSnackBar(message: msg),
        ),
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
