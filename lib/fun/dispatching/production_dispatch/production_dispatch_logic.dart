import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import '../../../bean/http/response/order_color_info.dart';
import '../../../bean/http/response/manufacture_instructions_info.dart';
import '../../../bean/http/response/production_dispatch_order_detail_info.dart';
import '../../../bean/http/response/production_dispatch_order_info.dart';
import '../../../bean/http/response/work_plan_material_info.dart';
import '../../../route.dart';
import '../../../widget/custom_widget.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../other/maintain_label/maintain_label_view.dart';
import '../../report/production_materials_report/production_materials_report_view.dart';
import 'production_dispatch_state.dart';

class ProductionDispatchLogic extends GetxController {
  final ProductionDispatchState state = ProductionDispatchState();

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

  ///工单列表非合并item点击事件
  item1click(int index) {
    if (state.isSelectedMany) {
      if (state.orderList[index].select) {
        state.orderList[index].select = false;
      } else {
        var selected = state.orderList.where((v) => v.select);
        if (selected.isNotEmpty &&
            selected
                .none((v) => v.plantBody == state.orderList[index].plantBody)) {
          showSnackBar(title: '选择错误', message: '不属于同一型体的订单', isWarning: true);
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
    refreshBottomButtons();
  }
  refreshBottomButtons(){
    var hasSelect = state.orderList.any((e) => e.select);
    state.cbIsEnabledMaterialList.value = hasSelect;
    state.cbIsEnabledInstruction.value = hasSelect;
    state.cbIsEnabledColorMatching.value = hasSelect;
    state.cbIsEnabledProcessInstruction.value = hasSelect;
    if (hasSelect) {
      var select = state.orderList.firstWhere((v) => v.select);
      if (select.state?.contains('未关闭') == true) {
        state.cbNameProcess.value = 'production_dispatch_bt_process_close'.tr;
      } else {
        state.cbNameProcess.value = 'production_dispatch_bt_process_open'.tr;
      }
    }
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
  query({bool isRefresh = false}) {
    state.query(
      startTime: dpcStartDate.getDateFormatYMD(),
      endTime: dpcEndDate.getDateFormatYMD(),
      success: (isNotEmpty) {
        if (isNotEmpty && !isRefresh) Get.back();
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///生产订单用料表
  orderMaterialList() {
    state.getSelectOne(
      (v) => Get.to(
        () => const ProductionMaterialsReportPage(),
        arguments: {'interID': v.interID},
      ),
    );
  }

  ///指令表
  instructionList(Function(String url) callback) {
    state.instructionList(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///工艺指导书
  processSpecification(Function(List<ManufactureInstructionsInfo>) callback) {
    state.getSelectOne(
      (v) => state.getManufactureInstructions(
        routeID: v.routingID.toIntTry(),
        success: callback,
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }

  ///配色单列表
  colorMatching(Function(List<OrderColorList>, String) callback) {
    state.colorMatching(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getColorPdf(String code, String id, Function(String) callback) {
    state.getColorPdf(
      code: code,
      id: id,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///打开/关闭工序
  offOnProcess() {
    state.offOnProcess(
      success: () => query(isRefresh: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///删除下游工序
  deleteDownstream() {
    state.deleteDownstream(
      success: () => query(isRefresh: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///删除上一次报工
  deleteLastReport() {
    state.deleteLastReport(
      success: () => query(isRefresh: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///贴标维护
  labelMaintenance() {
    if (checkUserPermission('1051106')) {
      state.getSelectOne((v) {
        Get.to(
          const MaintainLabelPage(),
          arguments: {
            'materialCode': v.materialCode,
            'interID': v.interID,
            'isMaterialLabel': false,
          },
        );
      });
    } else {
      showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '您没有标签打印权限', isWarning: true);
    }
  }

  ///更新领料配套数
  updateSap() {
    state.updateSap(
      success: () => query(isRefresh: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getSurplusMaterial(Function(List<Map>) callback) {
    state.getSurplusMaterial((list) {
      if (list.isNotEmpty) {
        callback.call(list);
      } else {
        showSnackBar(title: 'snack_bar_default_wrong'.tr, message: '无物料头信息', isWarning: true);
      }
    });
  }

  ///料头打印
  printSurplusMaterial(List<Map> list) {}

  double getReportMax() {
    var max = 0.0;
    state.getSelectOne(
      (v) => max = v.workNumberTotal.add(v.reportedUnentered ?? 0),
    );
    return max;
  }

  ///报工SAP
  reportToSap(double qty) {
    state.reportToSap(
      qty: qty,
      success: () => query(isRefresh: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  ///工单下推检查
  pushCheck(
    Function(ProductionDispatchOrderInfo) orderPush,
    Function(List<ProductionDispatchOrderInfo>) ordersPush,
  ) {
    if (checkUserPermission('1051102')) {
      var selectList = state.orderList.where((v) => v.select).toList();
      if (selectList.length > 1) {
        if (selectList.any((v) => v.isClosed!)) {
          errorDialog(content: '所选工单包含已关闭工单');
          return;
        }
        if (selectList.any((v) => v.pastDay!)) {
          errorDialog(content: '所选工单包含已超时工单');
          return;
        }
        informationDialog(
            content: '确定要选择${selectList.length}张派工单进行下推吗？',
            back: () {
              ordersPush.call(selectList);
            });
      } else {
        if (selectList[0].isClosed!) {
          errorDialog(content: '所选工单已关闭');
        } else {
          orderPush.call(selectList[0]);
        }
      }
    } else {
      errorDialog(content: '没有下推权限');
    }
  }

  ///工单下推
  push() {
    pushCheck(
      (order) => state.orderPush(
        order: order,
        success: (data) {
          if (data.workCardList?.isEmpty == true) {
            errorDialog(content: '暂无工序列表');
          } else {
            state.workCardTitle.value = data.workCardTitle ?? WorkCardTitle();
            state.workProcedure.value = data.workCardList!;
            Get.to(() => const ProductionDispatchDetailPage());
          }
        },
        error: (msg) => errorDialog(content: msg),
      ),
      (orders) => state.ordersPush(
        orders: orders,
        success: (data) {
          if (data.workCardList?.isEmpty == true) {
            errorDialog(content: '暂无工序列表');
          } else {
            state.workCardTitle.value = data.workCardTitle ?? WorkCardTitle();
            state.batchWorkProcedure = data.workCardList!;
            var workProcedure=<WorkCardList>[];
            groupBy(data.workCardList!, (v) => v.processNumber).forEach((k, v) {
              var qty=0.0;
              var finishQty=0.0;
              var mustQty=0.0;
              for (var v2 in v) {
                qty=qty.add(v2.qty??0);
                finishQty=finishQty.add(v2.finishQty??0);
                mustQty=mustQty.add(v2.mustQty??0);
              }
              workProcedure.add(WorkCardList(
                  mustQty:mustQty,
                  qty:qty,
                  finishQty:finishQty,
                  processNumber:v[0].processNumber,
                  processName:v[0].processName,
                  isOpen:v.any((v3)=>v3.isOpen==1)?1:0,
                  routingID:v[0].routingID,
              ));
            });
            state.workProcedure.value=workProcedure;
            Get.to(() => const ProductionDispatchDetailPage());
          }
        },
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }

  ///获取以选中的员工列表
  List<int> detailViewGetSelectedWorkerList() {
    var select = <int>[];
    if (state.workProcedureSelect.value >= 0) {
      for (var dis
          in state.workProcedure[state.workProcedureSelect.value].dispatch) {
        select.add(
            state.workerList.firstWhere((v) => v.empID == dis.empID).empID ??
                0);
      }
    }
    return select;
  }

  checkAutoCount(bool isChecked) {
    state.isCheckedAutoCount = isChecked;
    state.isCheckedDivideEqually = isChecked;
    state.isCheckedRounding = isChecked;
  }

  checkDivideEqually(bool isChecked) {
    state.isCheckedDivideEqually = isChecked;
    if (isChecked) {
      state.isCheckedAutoCount = isChecked;
    } else {
      if (state.isCheckedRounding == isChecked) {
        state.isCheckedAutoCount = isChecked;
      }
    }
  }

  checkRounding(bool isChecked) {
    state.isCheckedRounding = isChecked;
    if (isChecked) {
      state.isCheckedAutoCount = isChecked;
    } else {
      if (state.isCheckedDivideEqually == isChecked) {
        state.isCheckedAutoCount = isChecked;
      }
    }
  }

  ///选中本工序中的所有派工人员数据
  checkSelectAllDispatch(bool isChecked) {
    if (state.dispatchInfo.where((v) => v.select!).length ==
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
        state.dispatchInfo.where((v) => v.select!).length > 1;
    state.isCheckedSelectAllDispatch = isChecked;
    state.dispatchInfo.refresh();
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
        .fold(0.0, (total, di) => total.add(di.qty!));
    callback.call((wp.mustQty ?? 0.0).sub(other));
  }

  ///批量修改派工数据
  detailViewBatchModifyDispatchClick(
    Function(List<DispatchInfo> selectLis, double surplus) callback,
  ) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    var select = wp.dispatch.where((v) => v.select!).toList();
    var other = state.dispatchInfo
        .where((v) => !v.select!)
        .fold(0.0, (total, di) => total.add(di.qty!));
    callback.call(
      select,
      (wp.mustQty ?? 0.0).sub(other),
    );
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
  WorkCardList _modifyDispatch(WorkCardList wp, List<int> ids) {
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
            sum = sum.add(v.qty!);
          }
          if (workerList.where((v) => v.qty == 0).length == 1) {
            var qty = wp.mustQty! - (sum - workerList.last.qty!);
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
    return wp;
  }

  detailViewModifyDispatch({
    WorkCardList? wcl,
    required List<int> works,
  }) {
    if (wcl == null) {
      var wp = state.workProcedure[state.workProcedureSelect.value];
      state.dispatchInfo.value = _modifyDispatch(wp, works).dispatch;
      state.isEnabledSelectAllDispatch = state.dispatchInfo.isNotEmpty;
      state.workProcedure.refresh();
    } else {
      _modifyDispatch(wcl, works);
    }
  }

  ///派工剩余组员或删除所有派工
  detailViewAddAllWorker(Function() clean) {
    var exist = <int>[];
    var workers = <int>[];
    var wp = state.workProcedure[state.workProcedureSelect.value];
    for (var v in wp.dispatch) {
      exist.add(v.empID!);
    }
    for (var v in state.workerList) {
      workers.add(v.empID!);
    }
    if (workers.equals(exist)) {
      clean.call();
    } else {
      detailViewModifyDispatch(works: workers);
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
      showSnackBar(title: '温馨提示', message: '无法选中已关闭的工序', isWarning: true);
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
          !state.dispatchInfo.any((v) => !v.select!) &&
              state.dispatchInfo.isNotEmpty;
      state.isEnabledBatchDispatch.value =
          state.dispatchInfo.where((v) => v.select!).length > 1;
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
      ids.add(dis.empID!);
    }
    detailViewModifyDispatch(works: ids);
  }

  ///从汇总列表跳转到指定工序并打开指定员工到派工数据
  detailViewJumpToDispatchOnWorkProcedure(
    int i1,
    int i2,
    Function(dynamic data, dynamic surplus) modify,
  ) {
    if (state.workProcedureSelect.value != i1) {
      detailViewWorkProcedureClick(i1);
    }
    modify.call(
      state.dispatchInfo[i2],
      (state.workProcedure[state.workProcedureSelect.value].mustQty ?? 0.0).sub(
          state.dispatchInfo
              .where((v) => v.empID != state.dispatchInfo[i2].empID)
              .fold(0.0, (total, di) => total.add(di.qty!))),
    );
  }

  ///暂存该派工单的派工数据
  saveDispatch() {
    var cacheList = <CacheJson>[];
    for (var wp in state.workProcedure.where((v) => v.isOpen == 1)) {
      cacheList.add(CacheJson(
          processName: wp.processName ?? '',
          processNumber: wp.processNumber ?? '',
          dispatch: wp.dispatch));
    }
    SaveDispatch(
      processBillNumber: state.workCardTitle.value.processBillNumber ?? '',
      cacheJson: jsonEncode(cacheList.map((v) => v.toJson()).toList()),
    ).save((v) => showSnackBar(title: '数据库', message: '暂存派工成功'));
  }

  ///应用暂存派工单的派工数据
  applySaveDispatch(SaveDispatch sd) {
    var json = jsonDecode(sd.cacheJson!);
    for (var i = 0; i < json.length; ++i) {
      var cache = CacheJson.fromJson(json[i]);
      state.workProcedure
          .firstWhere((v) => v.processNumber == cache.processNumber)
          .dispatch = cache.dispatch!;
    }
    state.workProcedure.refresh();
  }

  ///保存该类形体的派工数据
  SaveWorkProcedure saveWorkProcedure() {
    var cacheList = <CacheJson>[];
    for (var wp in state.workProcedure.where((v) => v.isOpen == 1)) {
      cacheList.add(CacheJson(
          processName: wp.processName ?? '',
          processNumber: wp.processNumber ?? '',
          dispatch: wp.dispatch));
    }

    return SaveWorkProcedure(
      plantBody: state.workCardTitle.value.plantBody ?? '',
      saveTime: getDateYMD(),
      dispatchJson: jsonEncode(cacheList.map((v) => v.toJson()).toList()),
    )..save((v) {});
  }

  applySaveWorkProcedure(SaveWorkProcedure swp) {
    var json = jsonDecode(swp.dispatchJson!);
    state.workProcedureSelect.value = -1;
    state.dispatchInfo.value = [];
    for (var i = 0; i < json.length; ++i) {
      var cache = CacheJson.fromJson(json[i]);
      var workers = <int>[];
      for (var wp in state.workProcedure) {
        if (wp.processNumber == cache.processNumber) {
          cache.dispatch?.forEach((d) {
            if (state.workerList.any((w) => w.empID == d.empID)) {
              workers.add(d.empID!);
            }
          });
          detailViewModifyDispatch(wcl: wp, works: workers);
          break;
        }
      }
    }
    state.workProcedure.refresh();
  }

  void cleanDispatchFromWorkProcedure() {
    state.workProcedure[state.workProcedureSelect.value].dispatch = [];
    state.dispatchInfo.value = [];
    state.isEnabledSelectAllDispatch = state.dispatchInfo.isNotEmpty;
    state.workProcedure.refresh();
    state.isCheckedAddAllDispatch = false;
    state.isCheckedSelectAllDispatch = false;
  }

  ///工艺书
  detailViewGetManufactureInstructions(
    Function(List<ManufactureInstructionsInfo>) callback,
  ) {
    state.getManufactureInstructions(
      routeID: state.workProcedure[0].routingID ?? 0,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getWorkPlanMaterial(
    Function(List<WorkPlanMaterialInfo>) callback,
  ) {
    state.getWorkPlanMaterial(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getPrdRouteInfo() {
    state.getPrdRouteInfo(
      success: (list) {
        for (var wp in state.workProcedure) {
          list.removeWhere((v) => v.processNumber == wp.processNumber);
        }
        if (list.isEmpty) {
          successDialog(content: '工序正确！');
        } else {
          var msg = '';
          for (var v in list) {
            msg = '$msg工序<${v.processNumber}_${v.processName}>缺失！\r\n';
          }
          errorDialog(content: msg);
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  sendDispatchToWechat() {
    state.sendDispatchToWechat(
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkDispatch(Function callback) {
    //委外工单计工数可以少于上限但不能高于上限，非委外工单计工数必须等于上限。
    var msg = '';
    state.workProcedure.where((v) => v.isOpen == 1).forEach((wp) {
      if (wp.dispatch.isEmpty) {
        msg = '$msg工序<${wp.processNumber}_${wp.processName}>没有派工\r\n';
      } else {
        var total = 0.0;
        for (var d in wp.dispatch) {
          if (d.qty == 0) {
            msg =
                '$msg工序<${wp.processNumber}_${wp.processName}>员工 ${d.name} 计工数为0\r\n';
          } else {
            total = total.add(d.qty!);
          }
        }

        var max = state.workCardTitle.value.cardNoReportStatus == 1
            ? wp.mustQty ?? 0.0
            : state.workCardTitle.value.qtyPass
                .sub(state.workCardTitle.value.qtyProcessPass!);
        //委外工单上限为剩余派工数，非委外工单上限为 已汇报数 减去 累计计工数。
        if (state.workCardTitle.value.cardNoReportStatus != 1) {
          if (total < max) {
            msg =
                '$msg工序<${wp.processNumber}_${wp.processName}>少于汇报数 ${max.sub(total)}\r\n';
          }
        }
        if (total > max) {
          msg =
              '$msg工序<${wp.processNumber}_${wp.processName}>超过汇报数 ${total.sub(max)}\r\n';
        }
      }
    });
    if (msg.isEmpty) {
      callback.call();
    } else {
      errorDialog(content: msg);
    }
  }

  productionDispatch() {
    state.productionDispatch(
      success: (msg) {
        SaveDispatch.delete(
          processBillNumber: '${state.workCardTitle.value.processBillNumber}',
        );
        successDialog(content: msg);
      },
      error: (msg) => errorDialog(content: msg),
    );
  }
}
