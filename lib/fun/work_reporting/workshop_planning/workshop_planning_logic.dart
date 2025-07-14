import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_add_worker.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'workshop_planning_state.dart';

class WorkshopPlanningLogic extends GetxController {
  final WorkshopPlanningState state = WorkshopPlanningState();

  queryProcessPlan({
    required String productionOrderNo,
    required String processName,
    required Function() callback,
  }) {
    state.getProcessPlanInfo(
      productionOrderNo: productionOrderNo,
      processName: processName,
      success: callback,
      error: (msg) => errorDialog(content: msg),
    );
    // if(productionOrderNo.isEmpty && processName.isEmpty){
    //   errorDialog(content: '请输入工单号或物料名称');
    // }else{
    //   state.getProcessPlanInfo(
    //     productionOrderNo: productionOrderNo,
    //     processName: processName,
    //     error:(msg)=>errorDialog(content: msg),
    //   );
    // }
  }

  setReportQuantity(int index) {
    var data = state.planList[index];
    double qty = data.sizeLists?.isNotEmpty == true
        ? (state.planList[index].sizeLists ?? [])
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
        : 0;
    state.reportQuantity.value = qty;
    if (qty > 0) {
      state.price.value = qty.mul(state.planList[index].price ?? 0);
    }
  }

  calculateSalary() {
    if (state.reportWorkerList.isNotEmpty) {
      var efficiency = state.reportWorkerList
          .map((v) => v.efficiency())
          .reduce((a, b) => a.add(b));
      for (var worker in state.reportWorkerList) {
        if ((worker.base ?? 0) <= 0.0) {
          worker.money.value = 0;
        } else {
          worker.money.value =
              state.price.value.mul(worker.efficiency().div(efficiency));
        }
      }
    }
    state.worker = null;
    // state.reportWorkerList.refresh();
  }

  getGroupData({required int index, required String date}) {
    state.getDepartmentWorkerInfo(
      processFlowID: state.planList[index].flowProcessID ?? '',
      departmentID: state.departmentID,
      date: date,
      error: (msg) => errorDialog(content: msg),
    );
  }

  addWorker(String processFlowID) {
    state.getWorkTypeListByProcess(
      processFlowID: processFlowID,
      success: () => Get.to(
        () => const WorkshopPlanningAddWorkerPage(),
        arguments: {'flowProcessID': processFlowID},
      )?.then((_) => calculateSalary()),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getWorkerInfo({
    required String processFlowID,
    required String number,
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    if (number.length >= 6) {
      state.getEmpBaseByNumber(
        processFlowID: processFlowID,
        number: number,
        success: (worker) => selectWorker(
          worker: worker,
          workerType: workerType,
          workerNumber: workerNumber,
          manHours: manHours,
          coefficient: coefficient,
        ),
        error: (msg) {
          selectWorker(
            workerType: workerType,
            workerNumber: workerNumber,
            manHours: manHours,
            coefficient: coefficient,
          );
          errorDialog(content: msg);
        },
      );
    } else {
      state.minCoefficient.value = 0;
      state.maxCoefficient.value = 0;
      workerType.jumpToItem(0);
      manHours.text = '';
      coefficient.text = '';
    }
  }

  selectWorker({
    WorkshopPlanningWorkerInfo? worker,
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    if (worker != null) {
      state.worker = worker.deepCopy();
      workerNumber.text = state.worker!.number ?? '';
      int type = state.workTypeList.indexWhere(
        (v) => v.typeOfWork == state.worker!.typeOfWork,
      );
      if (type == -1) type = 0;

      workerType.jumpToItem(type >= 0 ? type : 0);
      manHours.text = state.worker!.dayWorkTime.toShowString();
      state.minCoefficient.value = state.workTypeList[type].minBase ?? 0;
      state.maxCoefficient.value = state.workTypeList[type].maxBase ?? 0;
      coefficient.text = state.workTypeList[type].base.toShowString();
      state.workerListSelectedIndex.value = state.workerList.indexWhere(
          (v) => v.name == worker.name && v.number == worker.number);
      debugPrint(
          'workerListSelectedIndex=${state.workerListSelectedIndex.value}');
    } else {
      state.worker = null;
      state.minCoefficient.value = 0;
      state.maxCoefficient.value = 0;
      workerType.jumpToItem(0);
      workerNumber.text = '';
      manHours.text = '';
      coefficient.text = '';
      state.workerListSelectedIndex.value = -1;
    }
  }

  changeWorkerType({
    required TextEditingController coefficient,
    required int index,
  }) {
    if (state.worker != null) {
      state.minCoefficient.value = state.workTypeList[index].minBase ?? 0;
      state.maxCoefficient.value = state.workTypeList[index].maxBase ?? 0;
      coefficient.text = state.workTypeList[index].base.toShowString();
    }
  }

  addOrModifyWorkerData({
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    if (state.worker == null) {
      errorDialog(content: '请填写工号或选择组员');
      return;
    }
    if (manHours.text.toDoubleTry() <= 0) {
      errorDialog(content: '请填写正确的工时');
      return;
    }
    if (coefficient.text.toDoubleTry() <= 0) {
      errorDialog(content: '请填写正确的基数');
      return;
    }
    state.worker!.dayWorkTime = manHours.text.toDoubleTry();
    state.worker!.base = coefficient.text.toDoubleTry();
    state.worker!.typeOfWork =
        state.workTypeList[workerType.selectedItem].typeOfWork;
    var index = state.reportWorkerList.indexWhere((v) =>
        v.name == state.worker!.name && v.number == state.worker!.number);
    if (index >= 0) {
      state.reportWorkerList[index] = state.worker!.deepCopy();
    } else {
      state.reportWorkerList.add(state.worker!);
    }
    Get.back();
  }

  modifyWorker(String processFlowID, WorkshopPlanningWorkerInfo worker) {
    state.getWorkTypeListByProcess(
      processFlowID: processFlowID,
      success: () {
        state.worker = worker.deepCopy();
        Get.to(
          () => const WorkshopPlanningAddWorkerPage(),
          arguments: {'flowProcessID': processFlowID},
        )?.then((_) => calculateSalary());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  initAddWorker({
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    selectWorker(
      worker: state.worker,
      workerType: workerType,
      workerNumber: workerNumber,
      manHours: manHours,
      coefficient: coefficient,
    );
  }
}
