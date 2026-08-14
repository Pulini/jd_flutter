import 'package:flutter/widgets.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/bean/http/response/people_message_info.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/label_for_work_card_info.dart';
import 'package:jd_flutter/fun/dispatching/team_leader_assigns_task/team_leader_assigns_task_logic.dart';

class TeamLeaderAssignsTaskState {
  var personalList = <EmployeeList>[].obs;
  var materialDetailList = <ComponentList>[].obs;
  var sizeAllocationList = <SizeList>[].obs;
  var selectedRowIndexes = <int>[].obs; // 多选：当前选中的尺码行索引集合（空=未选中）
  var factoryName = ''.obs;
  var workLine = ''.obs;
  var productNumber = ''.obs;
  var orderDate = ''.obs;
  var orderNo = ''.obs;
  var batchNo = ''.obs;
  var orderAllQty = ''.obs;
  var packMessage = ''.obs;
  var workCardInfo = LabelForWorkCardInfo();
  var scanOrder = '';
  late TeamLeaderAssignsTaskLogic logic; // 反向引用 logic，供 state 内调用 logic 方法（如默认选中单个部件）
  var showButton = true.obs;
  var showSizeAllocation = false.obs; // 尺码人员分配明细面板是否展开（点击部件「分配」后展开）
  var currentComponent = Rxn<ComponentList>(); // 当前展开分配明细的部件（按钮高亮/收起判断用）


  void _disposeAllocationControllers() {
    for (var comp in workCardInfo.componentList ?? []) {
      for (var item in comp.sizeList ?? []) {
        item.operatorController.dispose();
        item.qtyController.dispose();
      }
    }
  }

  void clearAll() {
    sizeAllocationList.value = [];
    showSizeAllocation.value = false;
    currentComponent.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _disposeAllocationControllers();
      workCardInfo = LabelForWorkCardInfo();
      personalList.value = [];
      materialDetailList.value = [];
      selectedRowIndexes.value = [];
      factoryName.value = '';
      workLine.value = '';
      productNumber.value = '';
      orderDate.value = '';
      orderNo.value = '';
      packMessage.value = '';
      orderAllQty.value = '';
    });
    scanOrder = '';
  }

  //获取包装清单贴标总数量
  void getProcessWorkCardInfo(String order, {void Function()? success}) {
    httpGet(
      method: webApiGetProcessWorkCardInfo,
      loading: 'maintain_label_getting_label_info'.tr,
      params: {
        'processNo': order,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        sizeAllocationList.value = [];
        showSizeAllocation.value = false;
        currentComponent.value = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _disposeAllocationControllers();
          workCardInfo = LabelForWorkCardInfo.fromJson(response.data);
          workCardInfo.processWorkCardInfo?.reportStatus == 0
              ? showButton.value = true
              : showButton.value = false;
          personalList.value = workCardInfo.employeeList ?? [];
          materialDetailList.value = workCardInfo.componentList ?? [];
          // 只有一个部件时，默认选中它（展开其尺码分配明细面板）
          if (materialDetailList.length == 1) {
            logic.loadSizeAllocation(materialDetailList.first);
          }
          factoryName.value = workCardInfo.processWorkCardInfo?.factoryName ?? '';
          workLine.value = workCardInfo.processWorkCardInfo?.departName ?? '';
          productNumber.value =
              workCardInfo.processWorkCardInfo?.productNumber ?? '';
          orderDate.value = workCardInfo.processWorkCardInfo?.fDate ?? '';
          orderNo.value = workCardInfo.processWorkCardInfo?.fCardNo ?? '';
          batchNo.value = workCardInfo.processWorkCardInfo?.fBatchNo ?? '';
          packMessage.value = workCardInfo.processWorkCardInfo?.packag ?? '';
          orderAllQty.value = workCardInfo.processWorkCardInfo?.totalQty.toString() ?? '';
          success?.call();
        });
      } else {
        sizeAllocationList.value = [];
        showSizeAllocation.value = false;
        currentComponent.value = null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _disposeAllocationControllers();
          workCardInfo = LabelForWorkCardInfo();
          personalList.value = [];
          materialDetailList.value = [];
          factoryName.value = '';
          workLine.value = '';
          productNumber.value = '';
          orderDate.value = '';
          orderNo.value = '';
          batchNo.value = '';
          packMessage.value = '';
          orderAllQty.value = '';
          errorDialog(content: response.message);
        });
      }
    });
  }

  void saveProcessWorkCardInfo({
    required void Function(String) success,
  }) {
    httpPost(
      method: webApiSaveProcessWorkCardInfo,
      loading: 'team_leader_issue_work_order'.tr,
      body: {
        'FInterID': workCardInfo.processWorkCardInfo!.interID,
        'FCardNo': workCardInfo.processWorkCardInfo!.fCardNo,
        'SizeList': [
          for (var comp in workCardInfo.componentList ?? [])
            for (var data in comp.sizeList ?? [])
              {
                'Size': data.size,
                'EmpID': data.empID,
                'AllocatedQty': data.currentQty.value,
                'FItemID': data.fItemID,
                'FRouteEntryFID': data.fRouteEntryFID,
                'FMtono': data.fMtono,
              }
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        errorDialog(content: response.message ?? '');
      }
    });
  }

  //根据组织(工作中心)id 获取对应人员，刷新人员选择列表
  void getWorkerInfo({
    String? department,
  }) {
    httpGet(method: webApiGetWorkerInfo, params: {
      'EmpNumber': '',
      'DeptmentID': department,
    }).then((response) {
      if (response.resultCode == resultSuccess) {
        personalList.clear();
        personalList.value = [
          for (var i = 0; i < response.data.length; ++i)
            EmployeeList(
              fItemID: response.data[i]['EmpID'],
              fNumber: response.data[i]['EmpCode'],
              fName: response.data[i]['EmpName'],
              avatarPath: response.data[i]['PicUrl'],
            )
        ];
        personalList.refresh();
      } else {
        personalList.clear();
        personalList.refresh();
        errorDialog(content: response.message ?? '');
      }
    });
  }

  // 根据工号获取人员信息（右侧花名册匹配不到时调用），返回查到的人员，失败返回 null
  Future<PeopleMessageInfo?> searchPeople(String number) async {
    if (number.isNotEmpty && number.length == 6) {
      var response = await httpGet(
        method: webApiGetEmpAndLiableByEmpCode,
        loading: 'device_maintenance_personnel_information'.tr,
        params: {
          'EmpCode': number,
        },
      );
      if (response.resultCode == resultSuccess) {
        return PeopleMessageInfo.fromJson(response.data);
      } else {
        errorDialog(content: response.message);
      }
    }
    return null;
  }
}
