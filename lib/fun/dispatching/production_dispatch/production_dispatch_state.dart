import 'package:get/get.dart';
import '../../../bean/production_dispatch.dart';
import '../../../bean/http/response/production_dispatch_order_detail_info.dart';
import '../../../bean/http/response/production_dispatch_order_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../utils.dart';

class ProductionDispatchState {
  var etInstruction='';
  var isSelectedOutsourcing =  spGet('${Get.currentRoute}/isSelectedOutsourcing') ??false;
  var isSelectedClosed =  spGet('${Get.currentRoute}/isSelectedClosed') ??false;
  var isSelectedMany =  spGet('${Get.currentRoute}/isSelectedMany') ??false;
  var isSelectedMergeOrder =  spGet('${Get.currentRoute}/isSelectedMergeOrder') ??false;
  var orderList = <ProductionDispatchOrderInfo>[].obs;
  var orderGroupList = <String, List<ProductionDispatchOrderInfo>>{}.obs;

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



  ///获取组员列表数据
  detailViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList = list,
    );
  }

  // ProductionDispatchState() {}

  remake() {
    workCardTitle.value = WorkCardTitle();
    workProcedure.value = [];
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


}
