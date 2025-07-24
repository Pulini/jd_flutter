import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/workshop_planning_info.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_add_worker.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_last_process_modify_report_view.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_last_process_report_list_view.dart';
import 'package:jd_flutter/fun/work_reporting/workshop_planning/workshop_planning_report_list_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import 'workshop_planning_state.dart';

class WorkshopPlanningLogic extends GetxController {
  final WorkshopPlanningState state = WorkshopPlanningState();

  queryProcessPlan({
    required String productionOrderNo,
    required String processName,
  }) {
    if (productionOrderNo.isEmpty && processName.isEmpty) {
      errorDialog(content: '请输入工单号或物料名称');
    } else {
      state.getProcessPlanInfo(
        productionOrderNo: productionOrderNo,
        processName: processName,
        success: () => Get.back(),
        error: (msg) => errorDialog(content: msg),
      );
    }
  }

  setWorkerMoney() {
    if (state.reportWorkerList.isNotEmpty) {
      var efficiency = state.reportWorkerList
          .map((v) => v.efficiency())
          .reduce((a, b) => a.add(b));
      for (var worker in state.reportWorkerList) {
        if ((worker.base ?? 0) <= 0.0) {
          worker.money.value = 0;
        } else {
          worker.money.value = state.price.value
              .mul(worker.efficiency().div(efficiency))
              .toFixed(3);
        }
      }
    }
  }

  getGroupData({required String date}) {
    state.getGroupInfo(
      processFlowID: state.planInfo!.flowProcessID ?? '',
      date: date,
      success: (list) {
        state.reportDate = date;
        state.workerList.value = list;
      },
      error: (msg) {
        state.workerList.value = [];
        errorDialog(content: msg);
      },
      finish: () {
        state.reportWorkerList.value = state.workerList;
        double qty = state.planInfo!.sizeLists?.isNotEmpty == true
            ? (state.planInfo!.sizeLists ?? [])
                .map((v) => v.qty ?? 0)
                .reduce((a, b) => a.add(b))
            : 0;
        state.reportQuantity.value = qty;
        if (qty > 0) {
          state.price.value = qty.mul(state.planInfo!.price ?? 0);
        }
        setWorkerMoney();
      },
    );
  }

  addWorker() {
    state.getWorkTypeListByProcess(
      processFlowID: state.planInfo!.flowProcessID ?? '',
      success: () => Get.to(
        () => const WorkshopPlanningAddWorkerPage(),
        arguments: {
          'flowProcessID': state.planInfo!.flowProcessID ?? '',
          'date': state.reportDate,
        },
      )?.then((_) {
        state.worker = null;
        setWorkerMoney();
      }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getWorkerInfo({
    required String flowProcessID,
    required String number,
    required String date,
    required FixedExtentScrollController workerType,
    required TextEditingController workerNumber,
    required TextEditingController manHours,
    required TextEditingController coefficient,
  }) {
    if (number.length >= 6) {
      state.getEmpBaseByNumber(
        flowProcessID: flowProcessID,
        number: number,
        date: date,
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
      processFlowID: state.planInfo!.flowProcessID ?? '',
      success: () {
        state.worker = worker.deepCopy();
        Get.to(
          () => const WorkshopPlanningAddWorkerPage(),
          arguments: {
            'flowProcessID': state.planInfo!.flowProcessID ?? '',
            'date': state.reportDate,
          },
        )?.then((_) {
          state.worker = null;
          setWorkerMoney();
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
        state.hasDelete = true;
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

    state.submitGroupPay(
      body: {
        'ID': state.planInfo!.id,
        'IsGroupWork': state.planInfo!.isGroupWork,
        'AllowEdit': state.planInfo!.allowEdit,
        'DepartmentID': state.departmentID,
        'WorkShift': state.isDayShift.value ? 0 : 1,
        'CreatorID': userInfo?.userID,
        'Date': state.reportDate,
        'GroupPayInterID': state.groupPayInterID,
        'SizeLists': [
          for (var item in state.planInfo!.sizeLists!)
            {
              'ID': '',
              'Size': item.size,
              'Qty': item.qty,
            }
        ],
        'EmpInfoReqList': [
          for (var item in state.reportWorkerList)
            {
              'Base': item.base,
              'DayWorkTime': item.dayWorkTime,
              'EmpID': item.empID,
              'Money': item.money.value,
              'Price': state.price.value,
              'TypeOfWork': item.typeOfWork,
            }
        ],
      },
      success: (msg) => WorkshopPlanningWorkersCache(
        departmentID: state.departmentID,
        day: getDateYMD(),
        data:
            jsonEncode(state.reportWorkerList.map((v) => v.toJson()).toList()),
      ).save(() => Get.back(result: true)),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getWorkshopPlanningWorkersCache() {
    WorkshopPlanningWorkersCache.getSave(
      departmentID: state.departmentID,
      callback: (list) => state.workersCache.value = list,
    );
  }

  useWorkersCache() {
    var cacheList = <WorkshopPlanningWorkerInfo>[
      for (var json in jsonDecode(state.workersCache.first.data ?? ''))
        WorkshopPlanningWorkerInfo.fromJson(json)
    ];
    var list = <WorkshopPlanningWorkerInfo>[];
    for (var cache in cacheList) {
      for (var worker in state.reportWorkerList) {
        if (worker.empID == cache.empID) {
          worker.base = cache.base;
          worker.dayWorkTime = cache.dayWorkTime;
          worker.typeOfWork = cache.typeOfWork;
          list.add(worker);
        }
      }
    }
    state.reportWorkerList.value = list;
  }

  scanCode(
    code,
    TextEditingController tecProductionOrderNo,
    TextEditingController tecProcessName,
  ) {
    if (code != null) {
      try {
        var json = jsonDecode(code);
        String? workCardInterID = json['WorkCardInterID'];
        String? routeEntryID = json['RouteEntryID'];
        String? processName = json['ProcessName'];
        if (workCardInterID?.isNotEmpty == true &&
            routeEntryID?.isNotEmpty == true &&
            processName?.isNotEmpty == true) {
          tecProductionOrderNo.text = '';
          tecProcessName.text = '';
          state.getProcessPlanInfo(
            workCardInterID: workCardInterID,
            routeEntryID: routeEntryID,
            success: () => Get.back(),
            error: (msg) => errorDialog(content: msg),
          );
        }
      } on Error catch (_) {
        errorDialog(content: '请扫描团件工单二维码');
      }
    }
  }

  refreshMaterialAndProcessDetails({
    required String date,
    required String processFlow,
  }) {
    state.getToDayItemInfo(
      date: date,
      success: () {
        var list = <WorkshopPlanningMaterialInfo>[];
        for (var m in state.lastProcessMaterialList) {
          for (var md in state.lastProcessMaterialsData) {
            if (m.itemID == md.itemID) {
              list.add(md);
            }
          }
        }
        state.lastProcessMaterialList.value = list;
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getLastProcessProduction({
    required String date,
    required String processFlow,
  }) {
    state.getEndingProcessInfo(
      date: date,
      processFlowID: processFlow,
      success: (pList) {
        state.lastProcessProductionList.value = pList;
        state.reportQuantity.value = pList.isEmpty
            ? 0.0
            : pList.map((v) => v.qty ?? 0).reduce((a, b) => a.add(b));
        state.price.value = pList.isEmpty
            ? 0.0
            : pList.map((v) => v.getMoney()).reduce((a, b) => a.add(b));
        state.getGroupInfo(
          processFlowID: processFlow,
          date: date,
          success: (list) {
            state.reportDate = date;
            state.workerList.value = list;
          },
          error: (msg) {
            state.workerList.value = [];
            errorDialog(content: msg);
          },
          finish: () {
            state.reportWorkerList.value = state.workerList;
            setWorkerMoney();
          },
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  lastProcessAddWorker(String processFlowID, String date) {
    state.getWorkTypeListByProcess(
      processFlowID: processFlowID,
      success: () => Get.to(
        () => const WorkshopPlanningAddWorkerPage(),
        arguments: {
          'flowProcessID': processFlowID,
          'date': date,
        },
      )?.then((_) {
        state.worker = null;
        setWorkerMoney();
      }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  lastProcessModifyWorker(
      WorkshopPlanningWorkerInfo worker, String processFlowID, String date) {
    state.getWorkTypeListByProcess(
      processFlowID: processFlowID,
      success: () {
        state.worker = worker.deepCopy();
        Get.to(
          () => const WorkshopPlanningAddWorkerPage(),
          arguments: {
            'flowProcessID': processFlowID,
            'date': date,
          },
        )?.then((_) {
          state.worker = null;
          setWorkerMoney();
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  getGroupPayEndingProcessList({
    required String date,
    required String processFlowID,
    required String processFlowName,
  }) {
    state.getGroupPayEndingProcessList(
      date: date,
      processFlowID: processFlowID,
      success: () {
        state.lastProcessDate = date;
        state.lastProcessFlowID = processFlowID;
        state.lastProcessFlowName = processFlowName;
        Get.to(() => const LastProcessReportListPage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  addMaterial(List<WorkshopPlanningMaterialInfo> list) {
    state.lastProcessMaterialList.addAll(list);
  }

  deleteMaterial(WorkshopPlanningMaterialInfo data) {
    state.lastProcessMaterialList.remove(data);
  }

  deleteLastProcessReportOrder({
    required int id,
  }) {
    state.deleteGroupPay(
      groupPayInterID: id,
      success: (msg) {
        state.hasDelete = true;
        successDialog(
          content: msg,
          back: () => state.getGroupPayEndingProcessList(
            date: state.lastProcessDate,
            processFlowID: state.lastProcessFlowID,
            error: (msg) => errorDialog(content: msg),
          ),
        );
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  clearData() {
    state.lastProcessMaterialsData.clear();
    state.lastProcessMaterialList.clear();
    state.lastProcessProductionList.clear();
    state.reportQuantity.value = 0.0;
    state.price.value = 0;
    state.reportDate = '';
    state.workerList.clear();
    state.reportWorkerList.clear();
  }

  submitLastProcessReport(String date) {
    if (state.reportQuantity.value == 0.0) {
      errorDialog(content: '报工数不能为0');
      return;
    }
    if (state.reportWorkerList.isEmpty) {
      errorDialog(content: '请添加报工人员');
      return;
    }
    state.submitGroupPay(
      body: {
        'ID': 0,
        'IsGroupWork': true,
        'AllowEdit': false,
        'DepartmentID': state.departmentID,
        'WorkShift': state.isDayShift.value ? 0 : 1,
        'CreatorID': userInfo?.userID,
        'Date': date,
        'GroupPayInterID': 0,
        'SizeLists': [
          for (var item in state.lastProcessProductionList)
            {
              'ID': item.id,
              'Size': item.size,
              'Qty': item.qty,
            }
        ],
        'EmpInfoReqList': [
          for (var item in state.reportWorkerList)
            {
              'Base': item.base,
              'DayWorkTime': item.dayWorkTime,
              'EmpID': item.empID,
              'Money': item.money.value,
              'Price': 0,
              'TypeOfWork': item.typeOfWork,
            }
        ],
      },
      success: (msg) => Get.back(result: true),
      error: (msg) => errorDialog(content: msg),
    );
  }

  getLastProcessDetails(int id) {
    state.getGroupPayEndingDetail(
      groupPayInterID: id,
      success: (detail) {
        state.lastProcessReportDetail = detail;
        if (!detail.materialInfoReqList.isNullOrEmpty()) {
          var material =
              detail.materialInfoReqList!.where((v) => v.used == true).toList();
          if (material.isNotEmpty) {
            state.modifyReportMaterialList.value = material;
          }
        }
        if (!detail.sizeList.isNullOrEmpty()) {
          state.modifyReportReportQuantity.value = detail.sizeList!
              .map((v) => v.qty ?? 0)
              .reduce((a, b) => a.add(b));
          state.modifyReportPrice.value = detail.sizeList!
              .map((v) => v.getMoney())
              .reduce((a, b) => a.add(b));
          state.modifyReportProductionList.value = detail.sizeList!;
        }
        if (!detail.empInfoReqList.isNullOrEmpty()) {
          state.modifyReportReportWorkerList.value = detail.empInfoReqList!;
          modifyReportSetWorkerMoney();
        }
        Get.off(() => const LastProcessModifyReportPage());
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyReportSetWorkerMoney() {
    if (state.modifyReportReportWorkerList.isNotEmpty) {
      var efficiency = state.modifyReportReportWorkerList
          .map((v) => v.efficiency())
          .reduce((a, b) => a.add(b));
      for (var worker in state.modifyReportReportWorkerList) {
        if ((worker.base ?? 0) <= 0.0) {
          worker.money.value = 0;
        } else {
          worker.money.value = state.modifyReportPrice.value
              .mul(worker.efficiency().div(efficiency))
              .toFixed(3);
        }
      }
    }
  }

  modifyReportAddWorker() {
    state.getWorkTypeListByProcess(
      processFlowID: state.lastProcessFlowID,
      success: () => Get.to(
        () => const WorkshopPlanningAddWorkerPage(),
        arguments: {
          'flowProcessID': state.lastProcessFlowID,
          'date': state.lastProcessReportDetail?.date ?? '',
        },
      )?.then((_) {
        state.worker = null;
        modifyReportSetWorkerMoney();
      }),
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyReportModifyWorker(WorkshopPlanningWorkerInfo worker) {
    state.getWorkTypeListByProcess(
      processFlowID: state.lastProcessFlowID,
      success: () {
        state.worker = worker.deepCopy();
        Get.to(
          () => const WorkshopPlanningAddWorkerPage(),
          arguments: {
            'flowProcessID': state.lastProcessFlowID,
            'date': state.lastProcessReportDetail?.date ?? '',
          },
        )?.then((_) {
          state.worker = null;
          modifyReportSetWorkerMoney();
        });
      },
      error: (msg) => errorDialog(content: msg),
    );
  }

  modifyReportDeleteReportWorker(WorkshopPlanningWorkerInfo data) {
    state.modifyReportReportWorkerList.remove(data);
  }

  modifyReportDeleteMaterial(LastProcessReportMaterialInfo data) {
    state.modifyReportMaterialList.remove(data);
  }

  modifyReportSubmit() {
    if (state.modifyReportReportQuantity.value == 0.0) {
      errorDialog(content: '报工数不能为0');
      return;
    }
    if (state.modifyReportReportWorkerList.isEmpty) {
      errorDialog(content: '请添加报工人员');
      return;
    }
    state.submitGroupPay(
      body: {
        'ID': state.lastProcessReportDetail!.id,
        'IsGroupWork': true,
        'AllowEdit': state.lastProcessReportDetail!.allowEdit,
        'DepartmentID': state.departmentID,
        'WorkShift': state.lastProcessReportDetail!.workShift,
        'CreatorID': userInfo?.userID,
        'Date': state.lastProcessReportDetail!.date,
        'GroupPayInterID': state.lastProcessReportDetail!.groupPayInterID,
        'SizeLists': [
          for (var item in state.modifyReportProductionList)
            {
              'ID': item.id,
              'Size': item.size,
              'Qty': item.qty,
            }
        ],
        'EmpInfoReqList': [
          for (var item in state.modifyReportReportWorkerList)
            {
              'Base': item.base,
              'DayWorkTime': item.dayWorkTime,
              'EmpID': item.empID,
              'Money': item.money.value,
              'Price': 0,
              'TypeOfWork': item.typeOfWork,
            }
        ],
      },
      success: (msg) => Get.back(result: true),
      error: (msg) => errorDialog(content: msg),
    );
  }
}
