import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/warehouse/smart_delivery/smart_delivery_material_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

import '../../../bean/http/response/smart_delivery_info.dart';
import '../../../route.dart';
import '../../../utils/web_api.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'smart_delivery_state.dart';

class SmartDeliveryLogic extends GetxController {
  final SmartDeliveryState state = SmartDeliveryState();

  ///日期选择器的控制器
  var pcStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.smartDeliveryPage.name}StartDate',
  );

  ///日期选择器的控制器
  var pcEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.smartDeliveryPage.name}EndDate',
  );

  ///组别选择器的控制器
  var pcGroup = OptionsPickerController(
    PickerType.mesGroup,
    saveKey: '${RouteConfig.smartDeliveryPage.name}${PickerType.mesGroup}',
  );

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

  refreshOrder({required void Function() refresh}) {
    state.pageIndex.value = 1;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
      success: (length) => refresh.call(),
      error: (msg) => errorDialog(content: msg, back: refresh),
    );
  }

  loadMoreOrder({
    required Function(bool) success,
    required Function() error,
  }) {
    state.pageIndex.value++;
    state.querySmartDeliveryOrder(
      showLoading: false,
      startTime: pcStartDate.getDateFormatYMD(),
      endTime: pcEndDate.getDateFormatYMD(),
      deptIDs: pcGroup.selectedId.value,
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

      //检查每一个尺码的轮数是否合理
      for (PartsSizeList o in state.deliveryDetail?.partsSizeList ?? []) {
        var roundSurplus = (o.qty ?? 0) % round;
        if (roundSurplus > o.reserveShoeTreeQty * round) {
          //如果预留楦头数量不够够余数分配，则轮数+1
          round += 1;
          break;
        }
      }

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
      errorDialog(content: '请勾选要合并的轮次！');
      return;
    }
    askDialog(
      content: '确定要保存选中轮次并在后续工单中合并配送吗？',
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

  refreshCreated(String taskId) {
    state.deliveryQty = 0;
    state.deliveryList.where((v) => v.isSelected).forEach((v) {
      v.isSelected = false;
      v.sendType = 1;
      v.taskID = taskId;
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
        v.isSelected = false;
        v.sendType = 1;
        v.taskID = taskId;
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
          .where((v) => v.sendType == 0)
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
}
