import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_production_dispatch_info.dart';
import 'package:jd_flutter/fun/dispatching/part_production_dispatch/part_production_dispatch_detail_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'part_production_dispatch_state.dart';

class PartProductionDispatchLogic extends GetxController {
  final PartProductionDispatchState state = PartProductionDispatchState();

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

  void toDetail() {
    state.getPartProductionDispatchOrdersDetail(
      orders: state.orderList
          .where((v) => v.isSelected.value && v.workCardID != null)
          .map((v) => v.workCardID!)
          .toList(),
      success: () {
        state.instructionList = [];
        state.detailInfo!.instruction?.split(',').forEach((data) {
          if (data.isNotEmpty) {
            state.instructionList.add([data, true.obs]);
          }
        });
        state.sizeList.value = state.detailInfo!.sizeList!;
        Get.to(() => PartProductionDispatchDetailPage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  void changeClosedStatus(bool isSelect) {
    state.isSelectedClosed.value = isSelect;
    spSave('${Get.currentRoute}/isSelectedClosed', isSelect);
  }

  void refreshSizeList() {
    for (var v in state.instructionList) {
      for (var v2 in state.sizeList) {
        if (v2.instruction == v.first.toString()) {
          v2.isShow.value = (v.last as RxBool).value;
        }
      }
    }
  }

  void setItemQty({
    required List<PartProductionDispatchOrderDetailSizeInfo> dataList,
    required String qtyString,
    required Function(String) refresh,
  }) {
    var max =
        dataList.map((v) => v.remainingQty ?? 0).reduce((a, b) => a.add(b));
    double setQty = 0.0;
    if (!qtyString.endsWith('.') && !qtyString.hasTrailingZero()) {
      var qty = qtyString.toDoubleTry();
      if (double.tryParse(qtyString) != null && qty > max) {
        setQty = max;
      } else {
        setQty = qty;
      }
      refresh.call(setQty.toShowString());
      for (var v in dataList) {
        if (setQty > (v.remainingQty ?? 0)) {
          v.qty.value = v.remainingQty ?? 0;
          setQty = setQty.sub(v.remainingQty ?? 0);
        } else {
          v.qty.value = setQty;
          setQty = 0;
        }
      }
    }
  }

  String batchSetItemQty(String qtyString) {
    var qty = qtyString.toDoubleTry();
    groupBy(state.sizeList.where((v) => v.isShow.value), (v) => v.size)
        .forEach((k, v) {
      var setQty = qty;
      for (var v2 in v) {
        if (setQty > (v2.remainingQty ?? 0)) {
          v2.qty.value = v2.remainingQty ?? 0;
          setQty = setQty.sub(v2.remainingQty ?? 0);
        } else {
          v2.qty.value = setQty;
          setQty = 0;
        }
      }
    });
    spSave('${Get.currentRoute}/BatchSetQty', qty);

    return qty.toShowString();
  }

  List<Map> getCreateLabelMap() {
    var list=<Map>[];
    state.sizeList
        .where((v) => v.isSelected.value && v.qty.value > 0)
        .forEach((v) {
      list.add({
        'WorkCardEntryFID': v.workCardEntryFID,
        'Size': v.size,
        'Capacity': v.qty.value,
        'DispatchedQty':v.dispatchedQty,
      });
    });
    return list;
  }
}
