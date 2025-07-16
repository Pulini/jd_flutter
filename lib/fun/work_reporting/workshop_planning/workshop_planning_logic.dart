import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_add_worker.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_report_list_view.dart';
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

  calculateSalary() {
    double qty = state.planInfo!.sizeLists?.isNotEmpty == true
        ? (state.planInfo!.sizeLists ?? [])
            .map((v) => v.qty ?? 0)
            .reduce((a, b) => a.add(b))
        : 0;
    state.reportQuantity.value = qty;
    if (qty > 0) {
      state.price = qty.mul(state.planInfo!.price ?? 0);
    }
    if (state.reportWorkerList.isNotEmpty) {
      var efficiency = state.reportWorkerList
          .map((v) => v.efficiency())
          .reduce((a, b) => a.add(b));
      for (var worker in state.reportWorkerList) {
        debugPrint('base: ${worker.base}');
        if ((worker.base ?? 0) <= 0.0) {
          worker.money.value = 0;
        } else {
          worker.money.value =
              state.price.mul(worker.efficiency().div(efficiency)).toFixed(3);
        }
      }
    }
  }

  getGroupData({required String date}) {
    state.getDepartmentWorkerInfo(
      processFlowID: state.planInfo!.flowProcessID ?? '',
      date: date,
      refresh: () => calculateSalary(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  addWorker() {
    state.getWorkTypeListByProcess(
      success: () => Get.to(
        () => const WorkshopPlanningAddWorkerPage(),
      )?.then((_) {
        state.worker = null;
        calculateSalary();
      }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getWorkerInfo({
    required String number,
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    if (number.length >= 6) {
      state.getEmpBaseByNumber(
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

  modifyWorker(WorkshopPlanningWorkerInfo worker) {
    state.getWorkTypeListByProcess(
      success: () {
        state.worker = worker.deepCopy();
        Get.to(
          () => const WorkshopPlanningAddWorkerPage(),
        )?.then((_) {
          state.worker = null;
          calculateSalary();
        });
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

  deleteReportWorker(WorkshopPlanningWorkerInfo data) {
    state.reportWorkerList.remove(data);
  }

  getGroupPayList() {
    state.reportList.value = [
      WorkshopPlanningReportInfo(
        date: '2025-01-10',
        finishQty: 99.9,
        groupPayInterID: 1,
        materialName: 'materialName1',
        number: 'number1',
        outputInterID: 11,
        planTrackingNumber: 'planTrackingNumber1',
        processName: 'processName1',
      ),
      WorkshopPlanningReportInfo(
        date: '2025-01-10',
        finishQty: 99.9,
        groupPayInterID: 2,
        materialName: 'materialName2',
        number: 'number2',
        outputInterID: 22,
        planTrackingNumber: 'planTrackingNumber2',
        processName: 'processName2',
      ),
      WorkshopPlanningReportInfo(
        date: '2025-01-10',
        finishQty: 99.9,
        groupPayInterID: 3,
        materialName: 'materialName3',
        number: 'number3',
        outputInterID: 33,
        planTrackingNumber: 'planTrackingNumber3',
        processName: 'processName3',
      ),
    ];

    state.getGroupPayList(
      success: () {
        state.reportDetailInfo = null;
        state.hasDelete = false;
        state.groupPayInterID = -1;
        Get.to(() => const WorkshopPlanningReportListPage())?.then((_) {
          if (state.reportDetailInfo != null) {
            state.planInfo!.sizeLists = state.reportDetailInfo!.sizeLists;
            state.isDayShift.value = state.reportDetailInfo!.workShift == 0;
            state.reportWorkerList.value =
                state.reportDetailInfo!.empInfoReqList ?? [];
            state.submitButtonName.value = '修改报工';
          } else if (state.hasDelete) {
            Get.back();
          }
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getReportDetailInfo(int groupPayInterID) {
    state.getGroupPayDetail(
      groupPayInterID: groupPayInterID,
      success: () => Get.back(),
      error: (msg) => errorDialog(content: msg),
    );
  }

  deleteReportInfo(int id) {
    state.deleteGroupPay(
      groupPayInterID: id,
      success: (msg) {
        successDialog(
          content: msg,
          back: () => state.getGroupPayList(
            error: (msg) => errorDialog(content: msg),
          ),
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  submitWorkersReport() {
    if (state.reportQuantity.value <= 0) {
      errorDialog(content: '报工数不能为0');
      return;
    }
    if (state.reportWorkerList.isEmpty) {
      errorDialog(content: '请添加报工人员');
      return;
    }
    WorkshopPlanningWorkersCache(
      group:state.departmentID,
      day:getDateYMD(),
      data:jsonEncode(state.reportWorkerList.map((v) => v.toJson()).toList()),
    ).save();
    // state.submitGroupPay(
    //   success: (msg) => Get.back(result: true),
    //   error: (msg) => errorDialog(content: msg),
    // );
  }
  getWorkshopPlanningWorkersCache(){
    // WorkshopPlanningWorkersCache
  }
}
