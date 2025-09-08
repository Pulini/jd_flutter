import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/smart_delivery_info.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'smart_delivery_material_view.dart';
import 'smart_delivery_state.dart';

class SmartDeliveryLogic extends GetxController {
  final SmartDeliveryState state = SmartDeliveryState();

  refreshOrder({
    required bool isQuery,
    required String instructions,
    required String startDate,
    required String endDate,
    required String group,
    required void Function() refresh,
  }) {
    if (!isQuery && group.isEmpty) {
      refresh.call();
      return;
    }
    state.pageIndex.value = 1;
    state.querySmartDeliveryOrder(
      showLoading: isQuery,
      instructions: instructions,
      startTime: startDate,
      endTime: endDate,
      deptIDs: group,
      success: (length) => refresh.call(),
      error: (msg) => errorDialog(content: msg, back: refresh),
    );
  }

  loadMoreOrder({
    required String instructions,
    required String startDate,
    required String endDate,
    required String group,
    required Function(bool) success,
    required Function() error,
  }) {
    state.pageIndex.value++;
    state.querySmartDeliveryOrder(
      showLoading: false,
      instructions: instructions,
      startTime: startDate,
      endTime: endDate,
      deptIDs: group,
      success: (length) => success.call(state.maxPageSize > length),
      error: (msg) {
        state.pageIndex.value--;
        errorDialog(content: msg, back: error);
      },
    );
  }

  getOrderMaterialList(
    int workCardInterID,
    String typeBody,
    int departmentID,
  ) {
    state.getOrderMaterialList(
      workCardInterID: workCardInterID,
      success: () => Get.to(
        () => const SmartDeliveryMaterialListPage(),
        arguments: {
          'typeBody': typeBody,
          'departmentID': departmentID,
        },
      ),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getDeliveryDetail(
    SmartDeliveryMaterialInfo data,
    int departmentID,
    Function() success,
  ) {
    state.getDeliveryDetail(
      sdmi: data,
      departmentID: departmentID,
      success: success,
      error: (msg) => errorDialog(content: msg),
    );
  }

  setTableLineData() {
    state.deliveryQty = 0;
    if (state.deliveryDetail == null) return;

    //每轮尺码列表预排
    var tableList = <WorkData>[];

    if (state.deliveryDetail!.workData.isNullOrEmpty()) {
      //轮数 小数位退位取整，15.1和15.9都等于15
      int round = state.deliveryDetail!.getMaxRound().truncate();
      //每轮尺码列表预排
      for (int i = 0; i < round; i++) {
        var roundList = <SizeInfo>[];
        state.deliveryDetail!.partsSizeList?.forEachIndexed((index, ps) {
          //添加分配数据给表格
          roundList.add(
            SizeInfo(size: ps.size, qty: ((ps.qty ?? 0) / round).truncate()),
          );
        });
        tableList.add(WorkData(
            round: (i + 1).toString(),
            sendType: 0,
            taskID: '',
            sendSizeList: roundList));
      }

      state.deliveryDetail!.partsSizeList?.forEachIndexed((index, ps) {
        var pageQty = 0;
        for (var i = 0; i < (ps.qty ?? 0) % round; ++i) {
          if (i == tableList.length) {
            pageQty += tableList.length;
          }
          tableList[i - pageQty].sendSizeList![index].qty =
              (tableList[i].sendSizeList![index].qty ?? 0) + 1;
        }
      });
    } else {
      for (var data in state.deliveryDetail!.workData!) {
        tableList.add(data);
      }
    }
    state.deliveryList = tableList;

    var saveDelivery = spGet('MergeDelivery').toString();
    if (saveDelivery.isNotEmpty && saveDelivery != 'null') {
      state.saveDeliveryDetail =
          DeliveryDetailInfo.fromJson(jsonDecode(saveDelivery));
      if (state.saveDeliveryDetail!.newWorkCardInterID ==
              state.deliveryDetail!.newWorkCardInterID &&
          state.saveDeliveryDetail!.partsID == state.deliveryDetail!.partsID) {
        for (var v1 in state.saveDeliveryDetail!.workData!) {
          state.deliveryList.removeWhere((v2) => v2.round == v1.round);
        }
      }
    }
  }

  saveDelivery({
    required String date,
    required Function refresh,
  }) {
    state.addPartsStock(
      date: date,
      success: (msg) {
        refresh.call();
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  resetDeliveryOrder({
    required Function refresh,
  }) {
    state.deletePartsStock(
      success: (msg) {
        cancelMergeDelivery();
        refresh.call();
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  mergeDeliveryRound(Function success) {
    if (!state.deliveryList.any((v) => v.isSelected)) {
      errorDialog(content: 'smart_delivery_check_rounds_merged'.tr);
      return;
    }
    askDialog(
      content: 'smart_delivery_save_temporary_iteration_and_use_later_tips'.tr,
      confirm: () {
        var copy = state.copyOrder();
        state.deliveryList = [
          ...state.deliveryList.where((v) => !v.isSelected)
        ];
        for (var v in copy.workData!) {
          v.isSelected = false;
        }
        spSave('MergeDelivery', jsonEncode(copy.toJson()));
        state.saveDeliveryDetail = copy;
        success.call();
      },
    );
  }

  cancelMergeDelivery() {
    spSave('MergeDelivery', '');
    if (state.saveDeliveryDetail != null) {
      if (state.saveDeliveryDetail!.newWorkCardInterID ==
              state.deliveryDetail!.newWorkCardInterID &&
          state.saveDeliveryDetail!.partsID == state.deliveryDetail!.partsID) {
        for (var v1 in state.saveDeliveryDetail!.workData!) {
          state.deliveryList.add(v1);
        }
        state.deliveryList
            .sort((a, b) => a.round.toIntTry().compareTo(b.round.toIntTry()));
      }
      state.saveDeliveryDetail = null;
    }
  }

  refreshCreated(String taskId, String agvNumber) {
    state.deliveryQty = 0;
    state.deliveryList.where((v) => v.isSelected).forEach((v) {
      v.sendType = 1;
      v.taskID = taskId;
      v.agvNumber = agvNumber;
      v.isSelected = false;
    });
    state.deliveryList.where((v) => v.sendType == 1).forEach((v) {
      state.deliveryQty += (v.sendSizeList ?? [])
          .map((v2) => v2.qty ?? 0)
          .reduce((a, b) => a + b);
    });
    if (state.saveDeliveryDetail != null) {
      state.saveDeliveryDetail!.workData!
          .where((v) => v.isSelected)
          .forEach((v) {
        v.sendType = 1;
        v.taskID = taskId;
        v.agvNumber = agvNumber;
        v.isSelected = false;
      });
      spSave('MergeDelivery', jsonEncode(state.saveDeliveryDetail!.toJson()));
    }
  }

  callbackRefresh(SmartDeliveryMaterialInfo data) {
    if (state.deliveryQty > 0) {
      data.sendQty = state.deliveryQty.toDouble();
    }
    if (state.saveDeliveryDetail != null) {
      var total = 0;
      state.deliveryList.where((v) => v.sendType == 1).forEach((v) {
        total += (v.sendSizeList ?? [])
            .map((v2) => v2.qty ?? 0)
            .reduce((a, b) => a + b);
      });
      state.materialShowList
          .firstWhere(
            (v) => v.partsID.toString() == state.saveDeliveryDetail!.partsID,
          )
          .sendQty = total.toDouble();
      var list = state.saveDeliveryDetail!.workData!
          .where((v) => v.sendType == 0 || v.sendType == 2)
          .toList();
      if (list.isEmpty) {
        spSave('MergeDelivery', '');
      } else {
        state.saveDeliveryDetail!.workData = list;
        spSave('MergeDelivery', jsonEncode(state.saveDeliveryDetail!.toJson()));
      }
      state.saveDeliveryDetail = null;
    }
    state.materialShowList.refresh();
  }

  cacheDelivery(Function refresh) {
    askDialog(
      content: isCanCache()
          ? 'smart_delivery_save_temporary_iteration_tips'.tr
          : 'smart_delivery_cancel_temporary_iteration_tips'.tr,
      confirm: () => state.cacheDelivery(
        success: (msg) {
          refresh.call();
          successDialog(content: msg);
        },
        error: (msg) => errorDialog(content: msg),
        isCache: isCanCache(),
      ),
    );
  }

  bool isCanCache() {
    var select = state.deliveryList.where((v) => v.isSelected);
    var cacheList = select.where((v) => v.sendType == 2);
    if (cacheList.isNotEmpty) {
      return select.length != cacheList.length;
    } else {
      return true;
    }
  }
}
