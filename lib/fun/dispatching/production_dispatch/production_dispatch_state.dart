import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:jd_flutter/http/response/worker_info.dart';

import '../../../bean/dispatch_info.dart';
import '../../../http/response/production_dispatch_order_detail_info.dart';
import '../../../http/response/production_dispatch_order_info.dart';

class ProductionDispatchState {
  var isSelectedOutsourcing = false.obs;
  var isSelectedClosed = false.obs;
  var isSelectedMany = false.obs;
  var isSelectedMergeOrder = false.obs;
  var orderList = <ProductionDispatchOrderInfo>[].obs;
  var orderGroupList = <String, List<ProductionDispatchOrderInfo>>{}.obs;

  var cbIsEnabledMaterialList = false.obs;
  var cbIsEnabledInstruction = false.obs;
  var cbIsEnabledColorMatching = false.obs;
  var cbIsEnabledProcessInstruction = false.obs;
  var cbIsEnabledProcessOpen = false.obs;
  var cbIsEnabledDeleteDownstream = false.obs;
  var cbIsEnabledDeleteLastReport = false.obs;
  var cbIsEnabledLabelMaintenance = false.obs;
  var cbIsEnabledUpdateSap = false.obs;
  var cbIsEnabledPrintMaterialHead = false.obs;
  var cbIsEnabledReportSap = false.obs;
  var cbIsEnabledPush = false.obs;

  var workCardTitle = WorkCardTitle().obs;
  var workProcedure = <WorkCardList>[].obs;
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
  var isOpenedAllWorkProcedure=true.obs;

  var isEnabledBatchDispatch = false.obs;
  var isEnabledNextWorkProcedure = true.obs;
  var isEnabledAddOne = true.obs;

  remake() {
    workCardTitle.value = WorkCardTitle();
    workProcedure.value = [];
    dispatchInfo.value = [];
    workProcedureSelect.value = -1;
    workerList = [];
    isOpenedAllWorkProcedure.value=true;
    isCheckedDivideEqually = true;
    isCheckedAutoCount = true;
    isCheckedRounding = true;
    isCheckedAddAllDispatch = false;
    isEnabledAddAllDispatch = true;
    isCheckedSelectAllDispatch = false;
    isEnabledSelectAllDispatch = false;
    isEnabledAddOne.value=false;
    isEnabledBatchDispatch.value=false;
  }
}
