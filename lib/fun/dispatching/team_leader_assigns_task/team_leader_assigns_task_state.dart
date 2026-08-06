import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';

import '../../../bean/http/response/label_for_work_card_info.dart';

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
  var orderAllQty = ''.obs;
  var packMessage = ''.obs;
  var workCardInfo = LabelForWorkCardInfo();
  var scanOrder = '';
  var showButton = true.obs;

  //获取包装清单贴标总数量
  void getProcessWorkCardInfo() {
    httpGet(
      method: webApiGetProcessWorkCardInfo,
      loading: 'maintain_label_getting_label_info'.tr,
      params: {
        'processNo': 'GXPG250103315/1',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        scanOrder = '';
        workCardInfo = LabelForWorkCardInfo.fromJson(response.data);
        workCardInfo.processWorkCardInfo?.reportStatus == 0
            ? showButton.value = true
            : showButton.value = false;
        personalList.value = workCardInfo.employeeList!;
        materialDetailList.value = workCardInfo.componentList!;
        sizeAllocationList.value = workCardInfo.sizeList!;
        // 根据工单分配状态标记每行「是否已分配过」，决定本次可分配上限口径
        final isAllocated =
            workCardInfo.processWorkCardInfo?.allocationStatus == 1;
        for (var item in sizeAllocationList) {
          item.isAllocated = isAllocated;
          // 接口给的是员工内码 empID，转成工号字符串回显（UI 以工号展示）
          for (var e in personalList) {
            if (e.fItemID == item.empID) {
              item.assignedOperator.value = e.fNumber ?? '';
              item.isMatched.value = true;
              item.operatorController.text = e.fNumber ?? '';
              break;
            }
          }
          // 默认本次分配量 = 上限（已分配→allocatedQty，未分配→totalQty）
          item.fillQtyByTotal();
        }
        factoryName.value = workCardInfo.processWorkCardInfo?.factoryName ?? '';
        workLine.value = workCardInfo.processWorkCardInfo?.departName ?? '';
        productNumber.value = workCardInfo.processWorkCardInfo?.productNumber ?? '';
        orderDate.value = workCardInfo.processWorkCardInfo?.fDate ?? '';
        orderNo.value = workCardInfo.processWorkCardInfo?.fCardNo ?? '';
        packMessage.value = workCardInfo.processWorkCardInfo?.packag ?? '';
        orderAllQty.value = workCardInfo.processWorkCardInfo?.totalQty.toString() ?? '';
      } else {
        scanOrder = '';
        workCardInfo = LabelForWorkCardInfo();
        personalList.value = [];
        materialDetailList.value = [];
        sizeAllocationList.value = [];
        factoryName.value = '';
        workLine.value = '';
        productNumber.value = '';
        orderDate.value = '';
        orderNo.value = '';
        packMessage.value = '';
        orderAllQty.value = '';
        errorDialog(content: response.message);
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
        'SizeList': [
          for (var data in sizeAllocationList)
            {
              'Size': data.size,
              'EmpID': data.empID,
              'AllocatedQty': data.currentQty.value,
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
}
