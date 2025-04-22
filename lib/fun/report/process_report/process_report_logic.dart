import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/dispatch_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/fun/report/process_report/process_report_state.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class ProcessReportLogic extends GetxController {
  final ProcessReportState state = ProcessReportState();

  var textSearch = TextEditingController();

  //获取工序派工信息
  getDispatchInfo(String code) {
    httpGet(
      loading: 'process_report_get_information'.tr,
      method: webApiGetDispatchInfo,
      params: {
        'BarCodeNumber': code,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        screenData(DispatchInfo.fromJson(response.data));
      } else {
        errorDialog(content: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //整理展示数据
  screenData(DispatchInfo data) {
    state.dataList.add(data);
    countQty();
    state.dataList.refresh();
  }

  //计算总数
  countQty() {
    if (state.dataList.isEmpty) {
      state.allQty.value = 0.0;
    } else {
      var allQty = 0.0;
      for (var c in state.dataList) {
        allQty = allQty.add(c.qty.toString().toDoubleTry());
      }
      state.allQty.value = allQty;
    }
  }

  //删除
  removeItem(int position) {
    state.dataList.removeAt(position);
    countQty();
    state.dataList.refresh();
  }

  //设置人员信息  刷新界面
  setPeople(WorkerInfo wi, int position) {
    state.dataList[position].empID = wi.empID;
    state.dataList[position].empNumber = wi.empCode;
    state.dataList[position].empName = wi.empName;
    state.dataList.refresh();
  }

  //提交条码信息
  submitProcess({
    required Function(String msg) success,
}) {
    if (state.dataList
        .where((data) =>
            data.empID == 0 || data.empName!.isEmpty || data.empNumber!.isEmpty)
        .isNotEmpty) {
      httpPost(
        method: webApiSubmitProcessBarCode2CollectBill,
        loading: 'process_report_to_submit_data'.tr,
        body: {
          'BarCodeList': [
            for (var c in state.dataList) {
            'BarCode':c.cardNo,
            'EmpID':c.empID,
            'Qty':c.qty,
          }],
          'UserID': getUserInfo()!.userID,
          'EmpID': getUserInfo()!.empID,
          'OrganizeID': getUserInfo()!.organizeID,
        },
      ).then((response) {
        if (response.resultCode == resultSuccess) {
          success.call(response.message ?? 'process_report_success_submit'.tr);
        } else {
          errorDialog(content: response.message ?? 'process_report_error_submit'.tr);
        }
      });
    } else {
      showSnackBar(message: 'process_report_click_item'.tr);
    }
  }

  //刷新显示界面
  cleanData(){
    state.dataList.clear();
    state.dataList.refresh();
    countQty();
  }
}
