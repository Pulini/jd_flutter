import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/bean/http/response/manufacture_instructions_info.dart';
import 'package:jd_flutter/bean/http/response/order_color_info.dart';
import 'package:jd_flutter/bean/http/response/prd_route_info.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_detail_info.dart';
import 'package:jd_flutter/bean/http/response/production_dispatch_order_info.dart';
import 'package:jd_flutter/bean/http/response/work_plan_material_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ProductionDispatchState {
  var isShowOrderProgress=false.obs;

  var etInstruction = '';
  var isSelectedOutsourcing =
      spGet('${Get.currentRoute}/isSelectedOutsourcing') ?? false;
  var isSelectedClosed = spGet('${Get.currentRoute}/isSelectedClosed') ?? false;
  var isSelectedMany = spGet('${Get.currentRoute}/isSelectedMany') ?? false;
  var isSelectedMergeOrder =
      spGet('${Get.currentRoute}/isSelectedMergeOrder') ?? false;
  var orderList = <ProductionDispatchOrderInfo>[].obs;
  var orderGroupList = <String, List<ProductionDispatchOrderInfo>>{}.obs;

  var orderProgressList = <OrderProgressItemInfo>[].obs;

  var cbIsEnabledMaterialList = false.obs;
  var cbIsEnabledInstruction = false.obs;
  var cbIsEnabledColorMatching = false.obs;
  var cbIsEnabledProcessInstruction = false.obs;
  var cbIsEnabledProcessOpen = false.obs;
  var cbNameProcess = ''.obs;
  var cbIsEnabledDeleteDownstream = false.obs;
  var cbIsEnabledDeleteLastReport = false.obs;
  var cbIsEnabledLabelMaintenance = false.obs;
  var cbIsEnabledUpdateSap = false.obs;
  var cbIsEnabledPrintMaterialHead = false.obs;
  var cbIsEnabledReportSap = false.obs;
  var cbIsEnabledPush = false.obs;

  var workCardTitle = WorkCardTitle().obs;
  var workProcedure = <WorkCardList>[].obs;
  var batchWorkProcedure = <WorkCardList>[];
  var dispatchInfo = <DispatchInfo>[].obs;
  var workProcedureSelect = 0.obs;
  var workerList = <WorkerInfo>[];
  var isCheckedDivideEqually = true;
  var isCheckedAutoCount = true;
  var isCheckedRounding = true;
  var isCheckedAddAllDispatch = false;
  var isEnabledAddAllDispatch = true;
  var isCheckedSelectAllDispatch = false;
  var isEnabledSelectAllDispatch = false;
  var isOpenedAllWorkProcedure = true.obs;

  var isEnabledBatchDispatch = false.obs;
  var isEnabledNextWorkProcedure = true.obs;
  var isEnabledAddOne = true.obs;

  //获取组员列表数据
  detailViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList = list,
      error: (msg) => errorDialog(content: msg),
    );
  }

  // ProductionDispatchState() {}
  getSelectOne(Function(ProductionDispatchOrderInfo) callback) {
    List<ProductionDispatchOrderInfo> select =
        orderList.where((v) => v.select).toList();
    if (select.isNotEmpty) {
      callback.call(select[0]);
    }
  }

  remake() {
    workCardTitle.value = WorkCardTitle();
    workProcedure.value = [];
    batchWorkProcedure = [];
    dispatchInfo.value = [];
    workProcedureSelect.value = -1;
    workerList = [];
    isOpenedAllWorkProcedure.value = true;
    isCheckedDivideEqually = true;
    isCheckedAutoCount = true;
    isCheckedRounding = true;
    isCheckedAddAllDispatch = false;
    isEnabledAddAllDispatch = true;
    isCheckedSelectAllDispatch = false;
    isEnabledSelectAllDispatch = false;
    isEnabledAddOne.value = false;
    isEnabledBatchDispatch.value = false;
  }

  query({
    required String startTime,
    required String endTime,
    required Function(String msg) error,
  }) {
    isShowOrderProgress.value=false;
    httpGet(
      method: webApiGetWorkCardCombinedSizeList,
      loading: 'production_dispatch_querying_order'.tr,
      params: {
        'startTime': startTime,
        'endTime': endTime,
        'moNo': etInstruction,
        'isClose': isSelectedClosed,
        'isOutsourcing': isSelectedOutsourcing,
        'deptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderList.value = [
          for (var json in response.data)
            ProductionDispatchOrderInfo.fromJson(json)
        ];
        orderGroupList.value = groupBy(
          orderList,
          (ProductionDispatchOrderInfo e) =>
              e.sapOrderBill.ifEmpty(e.orderBill ?? ''),
        );
      } else {
        orderList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  //指令表
  instructionList({
    required Function(String url) success,
    required Function(String msg) error,
  }) {
    getSelectOne(
      (v) => httpGet(
        method: webApiGetProductionOrderPDF,
        loading: 'production_dispatch_querying_instruction_list'.tr,
        params: {'orderBill': v.orderBill},
      ).then(
        (response) {
          if (response.resultCode == resultSuccess) {
            success.call(response.data);
          } else {
            error.call(response.message ?? '');
          }
        },
      ),
    );
  }

  //工艺书
  getManufactureInstructions({
    required int routeID,
    required Function(List<ManufactureInstructionsInfo> data) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetManufactureInstructions,
      loading: 'production_dispatch_querying_process_manual'.tr,
      params: {'RouteID': routeID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            ManufactureInstructionsInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //配色单列表
  colorMatching({
    required Function(List<OrderColorList> data, String planBill) success,
    required Function(String msg) error,
  }) {
    getSelectOne(
      (v) => httpGet(
        method: webApiGetMatchColors,
        loading: 'production_dispatch_getting_color_info'.tr,
        params: {'planBill': v.planBill},
      ).then(
        (response) {
          if (response.resultCode == resultSuccess) {
            success.call(
              [for (var json in response.data) OrderColorList.fromJson(json)],
              v.planBill ?? '',
            );
          } else {
            error.call(response.message ?? '');
          }
        },
      ),
    );
  }

  getColorPdf({
    required String code,
    required String id,
    required Function(String uri) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetMatchColorsPDF,
      loading: 'production_dispatch_getting_color_file'.tr,
      params: {
        'planBill': id,
        'materialCode': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  //打开/关闭工序
  offOnProcess({
    required Function() success,
    required Function(String msg) error,
  }) {
    getSelectOne((v) {
      bool closeStatus = v.state?.contains('未关闭') ?? false;
      httpPost(
        method: webApiChangeWorkCardStatus,
        loading: closeStatus
            ? 'production_dispatch_closing_process'.tr
            : 'production_dispatch_opening_process'.tr,
        params: {
          'Number': v.orderBill,
          'CloseStatus': closeStatus,
          'UserID': userInfo?.userID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          error.call(response.message ?? '');
        }
      });
    });
  }

  //删除下游工序
  deleteDownstream({
    required Function() success,
    required Function(String msg) error,
  }) {
    getSelectOne((v) {
      httpPost(
        method: webApiDeleteScProcessWorkCard,
        loading: 'production_dispatch_delete_downstream'.tr,
        params: {'WorkCardID': v.interID},
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          error.call(response.message ?? '');
        }
      });
    });
  }

  //删除上一次报工
  deleteLastReport({
    required Function() success,
    required Function(String msg) error,
  }) {
    getSelectOne((v) {
      httpPost(
        method: webApiDeleteLastReport,
        loading: 'production_dispatch_delete_last_report'.tr,
        params: {
          'WorkCardInterID': v.interID,
          'UserID': userInfo?.userID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          error.call(response.message ?? '');
        }
      });
    });
  }

  //更新领料配套数
  updateSap({
    required Function() success,
    required Function(String msg) error,
  }) {
    getSelectOne((v) {
      httpPost(
        method: webApiUpdateSAPPickingSupportingQty,
        loading: 'production_dispatch_upgrade_picking'.tr,
        params: {'InterID': v.interID},
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          error.call(response.message ?? '');
        }
      });
    });
  }

  getSurplusMaterial(Function(List<Map>) callback) {
    getSelectOne((v) {
      callback.call([
        if (v.stubBar1?.isNotEmpty == true &&
            v.stubBarName1?.isNotEmpty == true)
          {
            'StubBar': v.stubBar1,
            'StubBarName': v.stubBarName1,
          },
        if (v.stubBar2?.isNotEmpty == true &&
            v.stubBarName2?.isNotEmpty == true)
          {
            'StubBar': v.stubBar2,
            'StubBarName': v.stubBarName2,
          },
        if (v.stubBar2?.isNotEmpty == true &&
            v.stubBarName3?.isNotEmpty == true)
          {
            'StubBar': v.stubBar2,
            'StubBarName': v.stubBarName2,
          },
      ]);
    });
  }

  //报工SAP
  reportToSap({
    required double qty,
    required Function() success,
    required Function(String msg) error,
  }) {
    getSelectOne((v) {
      httpPost(
        method: webApiReportSAPByWorkCardInterID,
        loading: 'production_dispatch_report_to_sap'.tr,
        params: {
          'InterID': v.interID,
          'Qty': qty,
          'UserID': userInfo?.userID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call();
        } else {
          error.call(response.message ?? '');
        }
      });
    });
  }

  orderPush({
    required ProductionDispatchOrderInfo order,
    required Function(ProductionDispatchOrderDetailInfo detailInfo) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiPushProductionOrder,
      loading: 'production_dispatch_pushing'.tr,
      params: {
        'interID': order.interID,
        'entryID': order.entryID,
        'organizeID': userInfo?.organizeID,
        'userID': userInfo?.userID,
        'departmentID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(ProductionDispatchOrderDetailInfo.fromJson(
          response.data,
        ));
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  ordersPush({
    required List<ProductionDispatchOrderInfo> orders,
    required Function(ProductionDispatchOrderDetailInfo data) success,
    required Function(String msg) error,
  }) {
    var body = <Map>[];
    groupBy(orders, (v) => v.interID).forEach((key, value) {
      body.add({
        'OrganizeID': userInfo?.organizeID,
        'UserID': userInfo?.userID,
        'DepartmentID': userInfo?.departmentID,
        'WorkCardItems': [
          for (var v in value)
            {
              'InterID': key,
              'EntryID': v.entryID,
            }
        ]
      });
    });

    httpPost(
      method: webApiBatchPushProductionOrder,
      loading: 'production_dispatch_pushing'.tr,
      body: body,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(ProductionDispatchOrderDetailInfo.fromJson(
          response.data,
        ));
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getWorkPlanMaterial({
    required Function(List<WorkPlanMaterialInfo> data) success,
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetWorkPlanMaterial,
      loading: 'production_dispatch_querying_material_list'.tr,
      params: {'InterID': orderList.firstWhere((v) => v.select).interID},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) WorkPlanMaterialInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getPrdRouteInfo({
    required Function(List<PrdRouteInfo> data) success,
    required Function(String msg) error,
  }) {
    Future<BaseData> http;
    if (batchWorkProcedure.isEmpty) {
      http = httpGet(
        method: webApiGetPrdRouteInfo,
        loading: 'production_dispatch_querying_manual'.tr,
        params: {
          'BillNo': orderList.firstWhere((v) => v.select).routeBillNumber
        },
      );
    } else {
      var list = <String>[
        for (var data in orderList.where((v) => v.select))
          data.routeBillNumber ?? ''
      ];
      http = httpPost(
        method: webApiGetBatchPrdRouteInfo,
        loading: 'production_dispatch_querying_manual'.tr,
        body: list.toSet().toList(),
      );
    }
    http.then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data) PrdRouteInfo.fromJson(json),
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  sendDispatchToWechat({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var msg = 'production_dispatch_wechat_dispatch_error1'.trArgs([
      orderList.firstWhere((v) => v.select).planBill ?? '',
      workCardTitle.value.plantBody ?? ''
    ]);
    var submitData = <Map>[];
    for (var wp in workProcedure.where((v) => v.isOpen == 1)) {
      //如果批量数据不为空，则说明当前是多工单同时派工，需要对员工进行工单分配
      if (batchWorkProcedure.isNotEmpty) {
        for (var bwp in batchWorkProcedure.where(
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

    httpPost(
      method: webApiSendDispatchToWechat,
      loading: 'production_dispatch_wechat_dispatching'.tr,
      body: submitData,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  productionDispatch({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    var submitData = <Map>[];

    for (var wp in workProcedure.where((v) => v.isOpen == 1)) {
      //如果批量数据不为空，则说明当前是多工单同时派工，需要对员工进行工单分配
      if (batchWorkProcedure.isNotEmpty) {
        for (var bwp in batchWorkProcedure.where(
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
      }
    }
    httpPost(
      method: webApiProductionDispatch,
      loading: 'production_dispatch_dispatching'.tr,
      body: {'UserID': userInfo?.userID, 'List': submitData},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  queryProgress({
    required String startTime,
    required String endTime,
    required Function(String msg) error,
  }) {
    isShowOrderProgress.value=true;
    httpGet(
      method: webApiGetWorkCardDetailList,
      loading: 'production_dispatch_querying_order'.tr,
      params: {
        'startTime': startTime,
        'endTime': endTime,
        'moNo': etInstruction,
        'isClose': isSelectedClosed,
        'isOutsourcing': isSelectedOutsourcing,
        'deptID': userInfo?.departmentID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        orderProgressList.value = [
          for (var json in response.data) OrderProgressItemInfo.fromJson(json)
        ];
      } else {
        orderProgressList.value = [];
        error.call(response.message ?? '');
      }
    });
  }
}
