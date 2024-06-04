import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'package:jd_flutter/http/web_api.dart';
import 'package:jd_flutter/utils.dart';

import '../../../bean/dispatch_info.dart';
import '../../../http/response/production_dispatch_order_detail_info.dart';
import '../../../http/response/production_dispatch_order_info.dart';
import '../../../route.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'production_dispatch_state.dart';

class ProductionDispatchLogic extends GetxController {
  final ProductionDispatchState state = ProductionDispatchState();
  var tecInstruction = TextEditingController();

  ///日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionReport.name}StartDate',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  ///日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.date,
    saveKey: '${RouteConfig.workerProductionReport.name}EndDate',
  );

  @override
  void onInit() {
    super.onInit();
  }

  ///工单列表非合并item点击事件
  item1click(int index) {
    if (state.isSelectedMany.value) {
      if (state.orderList[index].select) {
        state.orderList[index].select = false;
      } else {
        var selected = state.orderList.where((v) => v.select);
        if (selected.isNotEmpty &&
            selected
                .none((v) => v.plantBody == state.orderList[index].plantBody)) {
          showSnackBar(title: '选择错误', message: '不属于同一型体的订单');
          return;
        } else {
          state.orderList[index].select = true;
        }
      }
    } else {
      for (var i = 0; i < state.orderList.length; ++i) {
        if (i == index) {
          state.orderList[i].select = !state.orderList[i].select;
        } else {
          if (state.orderList[i].select) {
            state.orderList[i].select = false;
          }
        }
      }
    }
    state.orderList.refresh();
    var hasSelect = state.orderList.any((e) => e.select);
    state.cbIsEnabledMaterialList.value = hasSelect;
    state.cbIsEnabledInstruction.value = hasSelect;
    state.cbIsEnabledColorMatching.value = hasSelect;
    state.cbIsEnabledProcessInstruction.value = hasSelect;
    state.cbIsEnabledProcessOpen.value = hasSelect;
    state.cbIsEnabledDeleteDownstream.value = hasSelect;
    state.cbIsEnabledDeleteLastReport.value = hasSelect;
    state.cbIsEnabledLabelMaintenance.value = hasSelect;
    state.cbIsEnabledUpdateSap.value = hasSelect;
    state.cbIsEnabledPrintMaterialHead.value = hasSelect;
    state.cbIsEnabledReportSap.value = hasSelect;
    state.cbIsEnabledPush.value = hasSelect;
  }

  ///工单查询
  query() {
    httpGet(
      method: webApiGetWorkCardCombinedSizeList,
      loading: '正在查询工单',
      query: {
        'startTime': dpcStartDate.getDateFormatYMD(),
        'endTime': dpcEndDate.getDateFormatYMD(),
        'moNo': tecInstruction.text,
        'isClose': state.isSelectedClosed,
        'isOutsourcing': state.isSelectedOutsourcing,
        'deptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var jsonList = jsonDecode(response.data);
        var list = <ProductionDispatchOrderInfo>[];
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(ProductionDispatchOrderInfo.fromJson(jsonList[i]));
        }
        state.orderList.value = list;
        state.orderGroupList.value =
            groupBy(list, (ProductionDispatchOrderInfo e) {
          return e.sapOrderBill ?? e.orderBill ?? '';
        });
        if (list.isNotEmpty) Get.back();
      } else {
        state.orderList.value = [];
        errorDialog(content: response.message);
      }
    });
  }

  ///工单下推检查
  pushCheck(Function(ProductionDispatchOrderInfo) orderPush,
      Function(List<ProductionDispatchOrderInfo>) ordersPush) {
    if (checkUserPermission('1051102')) {
      var selectList = state.orderList.where((v) => v.select).toList();
      if (selectList.any((v) => v.isClosed!)) {
        errorDialog(content: selectList.length > 1 ? '所选工单包含已关闭工单' : '所选工单已关闭');
        return;
      }
      // if (selectList.any((v) => v.pastDay!)) {
      //   errorDialog(content: selectList.length > 1 ? '所选工单包含已超时工单' : '所选工单已超时');
      //   return;
      // }

      if (selectList.length > 1) {
        informationDialog(
            content: '确定要选择${selectList.length}张派工单进行下推吗？',
            back: () {
              ordersPush.call(selectList);
            });
      } else {
        orderPush.call(selectList[0]);
      }
    } else {
      errorDialog(content: '没有下推权限');
    }
  }

  ///工单下推
  push() {
    pushCheck((order) {
      httpPost(
        method: webApiPushProductionOrder,
        loading: '正在下推...',
        query: {
          'interID': order.interID,
          'entryID': order.entryID,
          'organizeID': userInfo?.organizeID,
          'userID': userInfo?.userID,
          'departmentID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          var data = ProductionDispatchOrderDetailInfo.fromJson(
            jsonDecode(response.data),
          );
          if (data.workCardList?.isEmpty == true) {
            errorDialog(content: '');
          } else {
            state.workCardTitle.value = data.workCardTitle ?? WorkCardTitle();
            state.workProcedure.value = data.workCardList ?? <WorkCardList>[];
            Get.to(() => const ProductionDispatchDetailPage());
          }
        } else {
          errorDialog(content: response.message);
        }
      });
    }, (orders) {});
  }

  ///获取组员列表数据
  detailViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) {
        state.workerList = list;
      },
    );
  }

  ///获取以选中的员工列表
  detailViewGetDispatchSelectedWorkerList(Function(List<int>) callback) {
    if (state.workProcedureSelect.value >= 0) {
      var select = <int>[].obs;
      for (var dis
          in state.workProcedure[state.workProcedureSelect.value].dispatch) {
        select.add(
            state.workerList.firstWhere((v) => v.empID == dis.empID).empID ??
                0);
      }
      callback.call(select);
    }
  }

  ///跳转到下一道工序
  detailViewNextWorkProcedure() {
    if (state.workProcedure.where((v) => v.isOpen == 1).length > 1) {
      var start = state.workProcedureSelect.value;
      var max = state.workProcedure.lastIndexWhere((v) => v.isOpen == 1);
      if (state.workProcedureSelect.value == max) {
        start = -1;
      }
      for (var i = start + 1; i < state.workProcedure.length; ++i) {
        if (state.workProcedure[i].isOpen == 1) {
          detailViewWorkProcedureClick(i);
          return;
        }
      }
    } else {
      var select = state.workProcedure.indexWhere((v) => v.isOpen == 1);
      if (select != state.workProcedureSelect.value) {
        detailViewWorkProcedureClick(select);
      }
    }
  }

  ///派工数据item点击，修改派工
  detailViewDispatchItemClick(
    DispatchInfo di,
    Function(double surplus) callback,
  ) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    var other = state.dispatchInfo
        .where((v) => v.empID != di.empID)
        .fold(0.0, (total, di) => total.add(di.qty));
    callback.call((wp.mustQty ?? 0.0).sub(other));
  }

  ///批量修改派工数据
  detailViewBatchModifyDispatchClick(
    Function(List<DispatchInfo> selectLis, double surplus) callback,
  ) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    var select = wp.dispatch.where((v) => v.select).toList();
    var other = state.dispatchInfo
        .where((v) => !v.select)
        .fold(0.0, (total, di) => total.add(di.qty));
    callback.call(
      select,
      (wp.mustQty ?? 0.0).sub(other),
    );
  }

  ///获取批量修改派工dialog提示文本
  String detailViewSetDispatchDialogText(
      List<DispatchInfo> selectList, double qty) {
    if (state.isCheckedDivideEqually) {
      if (state.isCheckedRounding) {
        var integer = qty ~/ selectList.length;
        var decimal = (qty % selectList.length).toInt();
        return '均分${qty.toShowString()}并取整，一共${selectList.length}人，每人$integer，剩余$decimal分配给第一个人。';
      } else {
        var average = qty.div(selectList.length.toDouble());
        return '均分${qty.toShowString()}，一共${selectList.length}人，每人${average.toShowString()}。';
      }
    } else {
      var total = qty.mul(selectList.length.toDouble());
      return '一共${selectList.length}人，每人派工${qty.toShowString()}。共计派工${total.toShowString()}';
    }
  }

  ///批量修改派工数据
  detailViewBatchModifyDispatch(List<DispatchInfo> selectList, double qty) {
    if (state.isCheckedDivideEqually) {
      if (state.isCheckedRounding) {
        var integer = qty ~/ selectList.length;
        var decimal = (qty % selectList.length).toInt();
        for (var di in selectList) {
          di.qty = integer.toDouble();
        }
        selectList[0].qty = selectList[0].qty.add(decimal.toDouble());
      } else {
        var average = qty.div(selectList.length.toDouble());
        for (var di in selectList) {
          di.qty = average;
        }
      }
    } else {
      for (var di in selectList) {
        di.qty = qty;
      }
    }
    state.dispatchInfo.refresh();
    state.workProcedure.refresh();
  }

  ///添加派工人员或删除已派工人员
  detailViewModifyDispatch(List<int> ids) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    var workerList = <DispatchInfo>[];
    if (ids.isNotEmpty) {
      for (var id in ids) {
        var worker = state.workerList.firstWhere((w) => w.empID == id);
        var exist = wp.dispatch
            .firstWhere((w) => w.empID == id, orElse: () => DispatchInfo());
        var dispatch = DispatchInfo(
          resigned: worker.empLeaveStatus == 0,
          processName: wp.processName ?? '',
          processNumber: wp.processNumber ?? '',
          number: worker.empCode ?? '',
          name: worker.empName ?? '',
          empID: id,
          qty: exist.qty,
          finishQty: exist.finishQty,
          dispatchQty: exist.dispatchQty,
        );
        workerList.add(dispatch);
      }
      var quotient = wp.mustQty! ~/ workerList.length;
      var remainder = wp.mustQty! % workerList.length;
      //自动分配
      if (state.isCheckedAutoCount) {
        //均分
        if (state.isCheckedDivideEqually) {
          //取整
          if (state.isCheckedRounding) {
            for (var v in workerList) {
              v.qty = quotient.toDouble();
            }
            workerList[0].qty = workerList[0].qty.add(remainder);
          } else {
            for (var v in workerList) {
              v.qty = wp.qty! / workerList.length;
            }
          }
        } else {
          var sum = 0.0;
          for (var v in workerList) {
            sum = sum.add(v.qty);
          }
          if (workerList.where((v) => v.qty == 0).length == 1) {
            var qty = wp.mustQty! - (sum - workerList.last.qty);
            if (state.isCheckedRounding) {
              workerList.last.qty = qty.toInt().toDouble();
            } else {
              workerList.last.qty = qty;
            }
          }
        }
      }
    }
    wp.dispatch = workerList;
    state.dispatchInfo.value = wp.dispatch;
    state.isEnabledSelectAllDispatch = state.dispatchInfo.isNotEmpty;
    state.workProcedure.refresh();
  }

  ///派工剩余组员或删除所有派工
  detailViewAddAllWorker(Function() clean) {
    var exist = <int>[];
    var workers = <int>[];
    var wp = state.workProcedure[state.workProcedureSelect.value];
    for (var v in wp.dispatch) {
      exist.add(v.empID);
    }
    for (var v in state.workerList) {
      workers.add(v.empID!);
    }
    if (workers.equals(exist)) {
      clean.call();
    } else {
      detailViewModifyDispatch(workers);
      state.isCheckedAddAllDispatch = true;
    }
  }

  ///打开或关闭该工序
  detailViewWorkProcedureLock(int index) {
    if (state.workProcedure[index].isOpen == 1) {
      state.workProcedure[index].isOpen = 0;
    } else {
      state.workProcedure[index].isOpen = 1;
      state.workProcedureSelect.value = index;
    }
    if (state.workProcedureSelect.value == index) {
      state.workProcedureSelect.value = -1;
    }
    state.isOpenedAllWorkProcedure.value =
        state.workProcedure.any((v) => v.isOpen == 1);
    refreshSelectState();
  }

  ///打开或关闭全部工序
  detailViewWorkProcedureLockAll() {
    var hasOpen = state.workProcedure.any((v) => v.isOpen == 1);
    for (var wp in state.workProcedure) {
      wp.isOpen = hasOpen ? 0 : 1;
    }
    state.isOpenedAllWorkProcedure.value = !hasOpen;
    state.workProcedure.refresh();
    if (state.workProcedureSelect.value >= 0 && hasOpen) {
      state.workProcedureSelect.value = -1;
    }
    refreshSelectState();
  }

  ///工序列表点击，选中工序进行派工
  detailViewWorkProcedureClick(int index) {
    if (state.workProcedure[index].isOpen == 0) {
      showSnackBar(title: '温馨提示', message: '无法选中已关闭的工序');
    } else {
      if (index == state.workProcedureSelect.value) {
        state.workProcedureSelect.value = -1;
      } else {
        state.workProcedureSelect.value = index;
      }
    }
    refreshSelectState();
  }

  ///根据选中状态刷新界面UI
  refreshSelectState() {
    if (state.workProcedureSelect.value == -1) {
      state.isEnabledAddOne.value = false;
      state.isEnabledAddAllDispatch = false;
      state.isEnabledSelectAllDispatch = false;
      state.isCheckedAddAllDispatch = false;
      state.isCheckedSelectAllDispatch = false;
      state.dispatchInfo.value = [];
      state.isEnabledBatchDispatch.value = false;
      state.isEnabledAddOne.value = false;
      state.isEnabledAddAllDispatch = false;
    } else {
      state.isEnabledAddOne.value = true;
      state.isEnabledAddAllDispatch = true;
      state.dispatchInfo.value =
          state.workProcedure[state.workProcedureSelect.value].dispatch;
      state.isEnabledSelectAllDispatch = state.dispatchInfo.isNotEmpty;
      state.isCheckedAddAllDispatch = state.dispatchInfo.isNotEmpty;
      state.isCheckedSelectAllDispatch =
          !state.dispatchInfo.any((v) => !v.select) &&
              state.dispatchInfo.isNotEmpty;
      state.isEnabledBatchDispatch.value =
          state.dispatchInfo.where((v) => v.select).length > 1;
    }
    state.workProcedure.refresh();
    state.isEnabledNextWorkProcedure.value =
        state.workProcedure.any((v) => v.isOpen == 1);
  }

  ///删除派工人员数据
  detailViewDispatchItemDeleteClick(DispatchInfo dispatchInfo) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    wp.dispatch.remove(dispatchInfo);
    var ids = <int>[];
    for (var dis in wp.dispatch) {
      ids.add(dis.empID);
    }
    detailViewModifyDispatch(ids);
  }

  ///选中本工序中的所有派工人员数据
  detailViewSelectAllDispatch(bool c) {
    if (state.dispatchInfo.where((v) => v.select).length ==
        state.dispatchInfo.length) {
      for (var di in state.dispatchInfo) {
        di.select = false;
      }
    } else {
      for (var di in state.dispatchInfo) {
        di.select = true;
      }
    }
    state.isEnabledBatchDispatch.value =
        state.dispatchInfo.where((v) => v.select).length > 1;
    state.dispatchInfo.refresh();
  }
}
