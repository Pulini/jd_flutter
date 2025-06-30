import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/part_report_ticket_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_cancel/part_report_cancel_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartReportCancelLogic extends GetxController {
  final PartReportCancelState state = PartReportCancelState();

  //获取工票详情
  getReportSummary(String code) {
    if (code.isEmpty) {
      showSnackBar(message: 'part_report_cancel_ticket_is_empty'.tr);
    } else {
      httpGet(
        loading: 'carton_label_scan_querying_outside_label_detail'.tr,
        method: webApiGetCanReportSummary,
        params: {
          'workCardBarCode': code,
          'DeptID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          state.workTicket = code;
          state.ticketInfo = PartReportTicketInfo.fromJson(response.data);
          state.factory.value = state.ticketInfo.factoryType ?? '';
          state.part.value = state.ticketInfo.partName ?? '';
          state.processName.value = state.ticketInfo.processName ?? '';
          state.qty.value = state.ticketInfo.qty.toShowString();
          state.empID = state.ticketInfo.empID ?? '';
          state.dataList.value = state.ticketInfo.ticketItem ?? [];
        } else {
          errorDialog(content: response.message ?? 'query_default_error'.tr);
          cleanData();
        }
      });
    }
  }

  //清除数据
  cleanData() {
    state.factory.value = '';
    state.part.value = '';
    state.processName.value = '';
    state.qty.value = '';
    state.empID = '';
    state.dataList.value = [];
  }

  //是否登录人提交
  checkPeople() {
    if (userInfo?.empID.toString() == state.empID) {
      return true;
    } else {
      return false;
    }
  }

  //取消报工
  cancelPart({
    required Function(String msg) success,
  }) {
    if (state.part.isEmpty) {
      showSnackBar(message: 'part_report_cancel_ticket_is_empty'.tr);
    } else {
      httpPost(
        method: webApiUnReportByWorkCard,
        loading: 'part_report_cancel_cancelling'.tr,
        params: {
          'WorkCardBarCode': state.workTicket,
          'UserID': userInfo?.number,
          'DeptID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(response.message?? 'part_report_cancel_success_cancel'.tr);
        } else {
          errorDialog(
              content: response.message ?? 'part_report_cancel_fail_cancel'.tr);
        }
      });
    }
  }
  //提交报工
  submitPart({
    required Function(String msg) success,
  }) {
    if (state.part.isEmpty) {
      showSnackBar(message: 'part_report_cancel_ticket_is_empty'.tr);
    } else {
      httpPost(
        method: webApiSubmitBarCode,
        loading: 'part_report_cancel_reporting'.tr,
        body: {
          'WorkCardBarcode': state.workTicket,
          'EmpID': userInfo?.empID,
          'UserID': userInfo?.number,
          'DeptID': userInfo?.departmentID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(response.message?? 'part_report_cancel_report_success'.tr);
        } else {
          errorDialog(
              content: response.message ?? 'part_report_cancel_report_fail'.tr);
        }
      });
    }
  }
}
