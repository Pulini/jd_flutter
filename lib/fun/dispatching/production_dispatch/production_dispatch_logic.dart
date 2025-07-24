import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/manufacture_instructions_info.dart';
import 'package:jd_flutter/bean/http/response/order_color_info.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_info.dart';
import 'package:jd_flutter/bean/http/response/work_plan_material_info.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_detail_view.dart';
import 'package:jd_flutter/fun/dispatching/production_dispatch/production_dispatch_progress_view.dart';
import 'package:jd_flutter/fun/other/maintain_label/maintain_label_view.dart';
import 'package:jd_flutter/fun/report/production_materials_report/production_materials_report_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
import 'package:jd_flutter/widget/preview_label_widget.dart';
import 'package:jd_flutter/widget/tsc_label_template.dart';
import 'production_dispatch_state.dart';

class ProductionDispatchLogic extends GetxController {
  final ProductionDispatchState state = ProductionDispatchState();

  //日期选择器的控制器
  var dpcStartDate = DatePickerController(
    PickerType.startDate,
    saveKey:
        '${RouteConfig.workerProductionReport.name}${PickerType.startDate}',
  )..firstDate = DateTime(
      DateTime.now().year - 5, DateTime.now().month, DateTime.now().day);

  //日期选择器的控制器
  var dpcEndDate = DatePickerController(
    PickerType.endDate,
    saveKey: '${RouteConfig.workerProductionReport.name}${PickerType.endDate}',
  );

  //工单列表非合并item点击事件
  item1click(int index) {
    if (state.isSelectedMany) {
      if (state.orderList[index].select) {
        state.orderList[index].select = false;
      } else {
        var selected = state.orderList.where((v) => v.select);
        if (selected.isNotEmpty &&
            selected
                .none((v) => v.plantBody == state.orderList[index].plantBody)) {
          showSnackBar(
            title: 'production_dispatch_select_error'.tr,
            message: 'production_dispatch_different_type_body'.tr,
            isWarning: true,
          );
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

  refreshBottomButtons() {
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

  //工单查询
  query() {
    state.query(
      startTime: dpcStartDate.getDateFormatYMD(),
      endTime: dpcEndDate.getDateFormatYMD(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //生产订单用料表
  orderMaterialList() {
    state.getSelectOne(
      (v) => Get.to(
        () => const ProductionMaterialsReportPage(),
        arguments: {'interID': v.interID},
      ),
    );
  }

  //指令表
  instructionList(Function(String url) callback) {
    state.instructionList(
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
  }

  //工艺指导书
  processSpecification(Function(List<ManufactureInstructionsInfo>) callback) {
    state.getSelectOne(
      (v) => state.getManufactureInstructions(
        routeID: v.routingID.toIntTry(),
        success: callback,
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }

  //配色单列表
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

  //打开/关闭工序
  offOnProcess() {
    state.offOnProcess(
      success: () => query(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //删除下游工序
  deleteDownstream() {
    state.deleteDownstream(
      success: () => query(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //删除上一次报工
  deleteLastReport() {
    state.deleteLastReport(
      success: () => query(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //贴标维护
  labelMaintenance() {
    if (checkUserPermission('1051106')) {
      state.getSelectOne((v) {
        Get.to(() => const MaintainLabelPage(), arguments: {
          'materialCode': v.materialCode,
          'interID': v.interID,
          'isMaterialLabel': false,
        });
      });
    } else {
      showSnackBar(
        message: 'production_dispatch_no_label_print_permission'.tr,
        isWarning: true,
      );
    }
  }

  //物料贴标维护
  materialLabelMaintenance(ProductionDispatchOrderInfo data) {
    if (checkUserPermission('1051106')) {
      Get.to(() => const MaintainLabelPage(), arguments: {
        'materialCode': data.materialCode,
        'interID': data.interID,
        'isMaterialLabel': true,
      });
    } else {
      showSnackBar(
        message: 'production_dispatch_no_label_print_permission'.tr,
        isWarning: true,
      );
    }
  }

  //更新领料配套数
  updateSap() {
    state.updateSap(
      success: () => query(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getSurplusMaterial({required Function(List<Map>) print}) {
    state.getSurplusMaterial((list) {
      if (list.isNotEmpty) {
        print.call(list);
      } else {
        showSnackBar(
          message: 'production_dispatch_no_material_header'.tr,
          isWarning: true,
        );
      }
    });
  }

  //料头打印
  printSurplusMaterial(Map data) {
    var stubBar = data['StubBar'];
    var stubBarName = data['StubBarName'];
    state.getSelectOne((v) {
      Get.to(() => PreviewLabel(
            labelWidget: surplusMaterialLabelTemplate(
              qrCode: jsonEncode({
                'DispatchNumber': v.sapOrderBill,
                'StubBar': stubBar,
                'Factory': v.factory,
                'Date': v.orderDate,
                'NowTime': DateTime.now().millisecondsSinceEpoch,
              }),
              machine: v.machine ?? '',
              shift: v.shift ?? '',
              startDate: v.planStartTime ?? '',
              typeBody: v.plantBody ?? '',
              materialName: stubBarName,
              materialCode: stubBar,
            ),
          ));
    });
  }

  double getReportMax() {
    var max = 0.0;
    state.getSelectOne(
      (v) => max = v.workNumberTotal.add(v.reportedUnentered ?? 0),
    );
    return max;
  }

  //报工SAP
  reportToSap(double qty) {
    state.reportToSap(
      qty: qty,
      success: () => query(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  //工单下推检查
  pushCheck(
    Function(ProductionDispatchOrderInfo) orderPush,
    Function(List<ProductionDispatchOrderInfo>) ordersPush,
  ) {
    if (checkUserPermission('1051102')) {
      var selectList = state.orderList.where((v) => v.select).toList();
      if (selectList.length > 1) {
        if (selectList.any((v) => v.isClosed!)) {
          errorDialog(
              content: 'production_dispatch_selected_has_close_order'.tr);
          return;
        }
        if (selectList.any((v) => v.pastDay!)) {
          errorDialog(
              content: 'production_dispatch_selected_has_timeout_order'.tr);
          return;
        }
        msgDialog(
          content: 'production_dispatch_push_tips'.trArgs([
            selectList.length.toString(),
          ]),
          back: () => ordersPush.call(selectList),
        );
      } else {
        if (selectList[0].isClosed!) {
          errorDialog(content: 'production_dispatch_select_order_closed'.tr);
        } else {
          orderPush.call(selectList[0]);
        }
      }
    } else {
      errorDialog(content: 'production_dispatch_no_push_permission'.tr);
    }
  }

  //工单下推
  push() {
    pushCheck(
      (order) => state.orderPush(
        order: order,
        success: (data) {
          if (data.workCardList == null || data.workCardList?.isEmpty == true) {
            errorDialog(content: 'production_dispatch_no_process_list'.tr);
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
            errorDialog(content: 'production_dispatch_no_process_list'.tr);
          } else {
            state.workCardTitle.value = data.workCardTitle ?? WorkCardTitle();
            state.batchWorkProcedure = data.workCardList!;
            var workProcedure = <WorkCardList>[];
            groupBy(data.workCardList!, (v) => v.processNumber).forEach((k, v) {
              var qty = 0.0;
              var finishQty = 0.0;
              var mustQty = 0.0;
              for (var v2 in v) {
                qty = qty.add(v2.qty ?? 0);
                finishQty = finishQty.add(v2.finishQty ?? 0);
                mustQty = mustQty.add(v2.mustQty ?? 0);
              }
              workProcedure.add(WorkCardList(
                mustQty: mustQty,
                qty: qty,
                finishQty: finishQty,
                processNumber: v[0].processNumber,
                processName: v[0].processName,
                isOpen: v.any((v3) => v3.isOpen == 1) ? 1 : 0,
                routingID: v[0].routingID,
              ));
            });
            state.workProcedure.value = workProcedure;
            Get.to(() => const ProductionDispatchDetailPage());
          }
        },
        error: (msg) => errorDialog(content: msg),
      ),
    );
  }

  //获取以选中的员工列表
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

  //选中本工序中的所有派工人员数据
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

  //跳转到下一道工序
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

  //派工数据item点击，修改派工
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

  //批量修改派工数据
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

  //批量修改派工数据
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

  //添加派工人员或删除已派工人员
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

  //派工剩余组员或删除所有派工
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

  //打开或关闭该工序
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

  //打开或关闭全部工序
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

  //工序列表点击，选中工序进行派工
  detailViewWorkProcedureClick(int index) {
    if (state.workProcedure[index].isOpen == 0) {
      showSnackBar(
        title: 'production_dispatch_tips'.tr,
        message: 'production_dispatch_cant_select_closed_process'.tr,
        isWarning: true,
      );
    } else {
      if (index == state.workProcedureSelect.value) {
        state.workProcedureSelect.value = -1;
      } else {
        state.workProcedureSelect.value = index;
      }
    }
    refreshSelectState();
  }

  //根据选中状态刷新界面UI
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

  //删除派工人员数据
  detailViewDispatchItemDeleteClick(DispatchInfo dispatchInfo) {
    var wp = state.workProcedure[state.workProcedureSelect.value];
    wp.dispatch.remove(dispatchInfo);
    var ids = <int>[];
    for (var dis in wp.dispatch) {
      ids.add(dis.empID!);
    }
    detailViewModifyDispatch(works: ids);
  }

  //从汇总列表跳转到指定工序并打开指定员工到派工数据
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

  //暂存该派工单的派工数据
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
    ).save((v) => showSnackBar(
        title: 'production_dispatch_database'.tr,
        message: 'production_dispatch_save_dispatch_success'.tr));
  }

  //应用暂存派工单的派工数据
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

  //保存该类形体的派工数据
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

  //工艺书
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
          successDialog(content: 'production_dispatch_process_correct'.tr);
        } else {
          var msg = <String>[];
          for (var v in list) {
            msg.add('production_dispatch_process_miss'.trArgs([
              v.processNumber ?? '',
              v.processName ?? '',
            ]));
          }
          errorDialog(content: msg.join('\r\n'));
        }
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  sendDispatchToWechat() {
    var msg = 'production_dispatch_wechat_dispatch_error1'.trArgs([
      state.orderList.firstWhere((v) => v.select).planBill ?? '',
      state.workCardTitle.value.plantBody ?? ''
    ]);
    var submitData = <Map>[];
    for (var wp in state.workProcedure.where((v) => v.isOpen == 1)) {
      //如果批量数据不为空，则说明当前是多工单同时派工，需要对员工进行工单分配
      if (state.batchWorkProcedure.isNotEmpty) {
        for (var bwp in state.batchWorkProcedure.where(
              (v) => v.processNumber == wp.processNumber,
        )) {
          //指令已分配数量
          var disQty = 0.0;

          for (var worker in wp.dispatch) {
            //人员的剩余可分配数量大于0 说明人员的数量上一个指令分配满后还有剩余  可以继续下一个指令分配
            if (worker.remainder() > 0) {
              //指令剩余可分配数量
              var surplus = bwp.mustQty.sub(disQty);

              //指令剩余数量大于0 说明指令的数量上一个员工分配满后还有剩余  可以继续下一个员工分配
              if (surplus > 0) {
                //可分配数=如果剩余数大于人员可分配数则分配人员可分配数 否则分配剩余数
                var qty =
                surplus > worker.remainder() ? worker.remainder() : surplus;

                //分配人员数据到指令
                submitData.add({
                  'EmpID': worker.empID,
                  'WorkOrderType': '$msg${wp.processName}',
                  'WorkOrderContent':
                  'production_dispatch_wechat_dispatch_error2'.trArgs([
                    qty.toShowString(),
                  ]),
                });

                //累加人员数据的分配数量
                worker.dispatchQty = worker.dispatchQty.add(qty);

                //累加指令的分配数量
                disQty = disQty.add(qty);
              }
            }
          }
        }
      } else {
        for (var d in wp.dispatch) {
          submitData.add({
            'EmpID': d.empID,
            'WorkOrderType': '$msg${d.processName}',
            'WorkOrderContent':
            'production_dispatch_wechat_dispatch_error2'.trArgs([
              d.qty.toShowString(),
            ]),
          });
        }
      }
    }
    state.sendDispatchToWechat(
        submitData:submitData,
      success: (msg) => successDialog(content: msg),
      error: (msg) => errorDialog(content: msg),
    );
  }

  checkDispatch(Function callback) {
    //委外工单计工数可以少于上限但不能高于上限，非委外工单计工数必须等于上限。
    var msg = <String>[];
    state.workProcedure.where((v) => v.isOpen == 1).forEach((wp) {
      if (wp.dispatch.isEmpty) {
        msg.add('production_dispatch_process_no_dispatch'.trArgs([
          wp.processNumber ?? '',
          wp.processName ?? '',
        ]));
      } else {
        var total = 0.0;
        for (var d in wp.dispatch) {
          if (d.qty == 0) {
            msg.add('production_dispatch_process_worker_dispatch_zero'.trArgs([
              wp.processNumber ?? '',
              wp.processName ?? '',
              d.name ?? '',
            ]));
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
            msg.add('production_dispatch_process_less_report'.trArgs([
              wp.processNumber ?? '',
              wp.processName ?? '',
              max.sub(total).toShowString(),
            ]));
          }
        }
        if (total > max) {
          msg.add('production_dispatch_process_more_report'.trArgs([
            wp.processNumber ?? '',
            wp.processName ?? '',
            total.sub(max).toShowString(),
          ]));
        }
      }
    });
    if (msg.isEmpty) {
      callback.call();
    } else {
      errorDialog(content: msg.join('\r\n'));
    }
  }

  productionDispatch() {

      var submitData = <Map>[];
      for (var wp in state.workProcedure.where((v) => v.isOpen == 1)) {
        //如果批量数据不为空，则说明当前是多工单同时派工，需要对员工进行工单分配
        if (state.batchWorkProcedure.isNotEmpty) {
          for (var bwp in state.batchWorkProcedure.where(
                (v) => v.processNumber == wp.processNumber,
          )) {
            //指令已分配数量
            var disQty = 0.0;

            for (var worker in wp.dispatch) {
              //人员的剩余可分配数量大于0 说明人员的数量上一个指令分配满后还有剩余  可以继续下一个指令分配
              if (worker.remainder() > 0) {
                //指令剩余可分配数量
                var surplus = bwp.mustQty.sub(disQty);

                //指令剩余数量大于0 说明指令的数量上一个员工分配满后还有剩余  可以继续下一个员工分配
                if (surplus > 0) {
                  //可分配数=如果剩余数大于人员可分配数则分配人员可分配数 否则分配剩余数
                  var qty =
                  surplus > worker.remainder() ? worker.remainder() : surplus;

                  //分配人员数据到指令
                  submitData.add({
                    'ID': bwp.id,
                    'InterID': bwp.interID,
                    'EntryID': bwp.entryID,
                    'OperPlanningEntryFID': bwp.operPlanningEntryFID,
                    'EmpID': worker.empID,
                    'WorkerCode': worker.number,
                    'WorkerName': worker.name,
                    'SourceQty': bwp.sourceQty,
                    'MustQty': bwp.mustQty,
                    'PreSchedulingQty': bwp.preSchedulingQty,
                    'Qty': qty,
                    'FinishQty': bwp.finishQty,
                    'SourceEntryID': bwp.sourceEntryID,
                    'SourceInterID': bwp.sourceInterID,
                    'SourceEntryFID': bwp.sourceEntryFID,
                    'ProcessNumber': bwp.processNumber,
                    'ProcessName': bwp.processName,
                    'IsOpen': bwp.isOpen,
                    'RoutingID': bwp.routingID,
                  });

                  //累加人员数据的分配数量
                  worker.dispatchQty = worker.dispatchQty.add(qty);

                  //累加指令的分配数量
                  disQty = disQty.add(qty);
                }
              }
            }
          }
          state.mergeOrderProductionDispatch(
            submitData: submitData,
            success: (msg) {
              SaveDispatch.delete(
                processBillNumber: '${state.workCardTitle.value.processBillNumber}',
              );
              successDialog(content: msg);
            },
            error: (msg) => errorDialog(content: msg),
          );
        } else {
          for (var d in wp.dispatch) {
            submitData.add({
              'ID': wp.id,
              'InterID': wp.interID,
              'EntryID': wp.entryID,
              'OperPlanningEntryFID': wp.operPlanningEntryFID,
              'EmpID': d.empID,
              'WorkerCode': d.number,
              'WorkerName': d.name,
              'SourceQty': wp.sourceQty,
              'MustQty': wp.mustQty,
              'PreSchedulingQty': wp.preSchedulingQty,
              'Qty': d.qty,
              'FinishQty': wp.finishQty,
              'SourceEntryID': wp.sourceEntryID,
              'SourceInterID': wp.sourceInterID,
              'SourceEntryFID': wp.sourceEntryFID,
              'ProcessNumber': wp.processNumber,
              'ProcessName': wp.processName,
              'IsOpen': wp.isOpen,
              'RoutingID': wp.routingID,
            });
          }
          state.productionDispatch(
            submitData: submitData,
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
  }

  queryProgress() {
    state.queryProgress(
      startTime: dpcStartDate.getDateFormatYMD(),
      endTime: dpcEndDate.getDateFormatYMD(),
      success: (list) {
        state.orderProgressList.value = formatProgress(list);
        state.orderProgressTableWeight.value =
            calculateTableWidth(state.orderProgressList[0].sizeMax);
        Get.to(() => const ProductionDispatchProgressPage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  List<OrderProgressShowInfo> formatProgress(List<OrderProgressInfo> list) {
    var progressList = <OrderProgressShowInfo>[];
    for (var order in list) {
      var maxSizeList = order.getMaxSizeList();

      //添加物料头
      progressList.add(
        OrderProgressShowInfo()
          ..itemType = 1
          ..sizeMax = maxSizeList.length
          ..material = '物料：${order.materialName}(${order.materialCode})'
          ..factoryType = '型体：${order.factoryType}'
          ..factory = '工厂：${order.factory}',
      );

      //添加表格头
      progressList.add(
        OrderProgressShowInfo()
          ..itemType = 2
          ..sizeMax = maxSizeList.length
          ..mtoNo = '指令号'
          ..unit = '单位'
          ..qty = '数量'
          ..inStockQty = '入库数量'
          ..reportedQty = '已汇报数'
          ..priority = '优先级'
          ..sizeData = maxSizeList,
      );

      //补全码段
      order.mtoNoItems?.forEach((item) {
        var newSizeList = <OrderProgressItemSizeInfo>[];
        for (var size in maxSizeList) {
          var sizeItem =
              item.sizeItems?.firstWhereOrNull((v) => v.size == size);
          newSizeList.add(
            OrderProgressItemSizeInfo()
              ..size = sizeItem == null ? size : sizeItem.size
              ..qty = sizeItem == null ? 0 : sizeItem.qty,
          );
        }
        item.sizeItems = newSizeList;
      });

      //生成码段合计
      var newSizeListTotal = <String>[];
      maxSizeList.forEachIndexed((i, v) {
        newSizeListTotal.add((order.mtoNoItems
            ?.map((v) => v.sizeItems![i].qty ?? 0)
            .reduce((a, b) => a.add(b))).toShowString());
      });

      //添加表体数据
      double qtyTotal = 0;
      order.mtoNoItems?.forEach((v) {
        //合计表体中的《数量》数
        qtyTotal = qtyTotal.add(v.qty ?? 0);
        progressList.add(
          OrderProgressShowInfo()
            ..itemType = 3
            ..sizeMax = maxSizeList.length
            ..mtoNo = v.mtoNo ?? ''
            ..unit = v.unit ?? ''
            ..qty = v.qty.toShowString()
            ..inStockQty = v.inStockQty.toShowString()
            ..reportedQty = v.reportedQty.toShowString()
            ..priority = v.priority.toString()
            ..sizeData = [for (var i in v.sizeItems!) i.qty.toShowString()],
        );
      });

      //添加合计行
      progressList.add(
        OrderProgressShowInfo()
          ..itemType = 4
          ..sizeMax = maxSizeList.length
          ..preCompensation =
              order.preCompensation != 1 && order.preCompensation != 2
          ..qty = qtyTotal.toShowString()
          ..sizeData = newSizeListTotal,
      );

      //预补
      if (order.preCompensation == 1) {
        //先合计后预补 按照总数的1%进行四舍五入取整
        var preCompensationList = <String>[];
        for (var v in newSizeListTotal) {
          preCompensationList.add(
            v.toDoubleTry().div(100).round().toString(),
          );
        }
        progressList.add(
          OrderProgressShowInfo()
            ..itemType = 5
            ..sizeMax = maxSizeList.length
            ..preCompensation = true
            ..qty = preCompensationList
                .map((v) => v)
                .reduce((a, b) => a + b)
                .toString()
            ..sizeData = preCompensationList,
        );
      }

      if (order.preCompensation == 2) {
        //先预补后合计 按照尺码的1%进行向上取证后合计所有尺码
        var preCompensationList = <String>[];
        for (var size in maxSizeList) {
          int pcTotal = 0;
          order.mtoNoItems?.forEach((v) {
            var find = v.sizeItems?.firstWhereOrNull((s) => s.size == size);
            if (find != null && (find.qty ?? 0) > 0) {
              pcTotal += find.qty.div(100).ceil();
            }
          });
          preCompensationList.add(pcTotal.toString());
        }
        progressList.add(
          OrderProgressShowInfo()
            ..itemType = 5
            ..sizeMax = maxSizeList.length
            ..preCompensation = true
            ..qty = preCompensationList
                .map((v) => v)
                .reduce((a, b) => a + b)
                .toString()
            ..sizeData = preCompensationList,
        );
      }
    }
    return progressList;
  }

  double calculateTableWidth(int sizeMax) {
    var motNoWidth = 140;
    var unitWidth = 60;
    var qty = 80;
    var sizeItemWidth = 60;
    var inStockQty = 80;
    var reportedQty = 80;
    var priority = 80;
    return (motNoWidth +
            unitWidth +
            qty +
            sizeItemWidth * sizeMax +
            inStockQty +
            reportedQty +
            priority)
        .toDouble();
  }
}
