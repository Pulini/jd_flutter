import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../http/response/production_day_report_info.dart';
import '../../../http/web_api.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import '../../../widget/picker/picker_view.dart';
import 'production_day_report_state.dart';

class ProductionDayReportLogic extends GetxController {
  final ProductionDayReportState state = ProductionDayReportState();

  ///日期选择器的控制器
  late DatePickerController pickerControllerDate;

  ///下拉选择器的控制器
  late SpinnerController spinnerControllerWorkShop;
  late DatePickerController reasonDateController;
  var reasonTitle = <Widget>[];
  var reasonTextStyle = const TextStyle(color: Colors.white);
  late DateTime today;
  late DateTime lastWeek;
  late DateTime yesterday;

  @override
  void onInit() {
    today = DateTime.now();
    lastWeek = DateTime(today.year, today.month, today.day - 7);
    yesterday = DateTime(today.year, today.month, today.day - 1);
    pickerControllerDate = DatePickerController(
      PickerType.date,
      saveKey: '${RouteConfig.productionDayReport}${PickerType.date}',
      firstDate: lastWeek,
      lastDate: today,
      onChanged: (index) => query(),
    );
    spinnerControllerWorkShop = SpinnerController(
      saveKey: RouteConfig.productionDayReport,
      dataList: ['裁断车间', '针车车间', '成型车间', '印业车间', '其他'],
      onChanged: (index) => query(),
    );
    reasonDateController = DatePickerController(
      PickerType.date,
      firstDate: yesterday,
      lastDate: today,
    );
    reasonTitle = [
      getText('组别', userController.user.value?.departmentName ?? ''),
      getText('工号', userController.user.value?.number ?? ''),
      getText('姓名', userController.user.value?.name ?? ''),
      getText('职位', userController.user.value?.position ?? ''),
      DatePicker(pickerController: reasonDateController),
    ];
    super.onInit();
  }

  Widget getText(String hint, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            hint,
            style: reasonTextStyle,
          ),
          Text(
            text,
            style: reasonTextStyle,
          )
        ],
      ),
    );
  }

  ///获取产量汇总表接口
  query() {
    httpGet(
      loading: '正在查询产量实时汇总报表...',
      method: webApiGetPrdDayReport,
      query: {
        'Date': pickerControllerDate.getDateFormatYMD(),
        'WorkShopID': spinnerControllerWorkShop.selectIndex + 1,
        'OrganizeID': userController.user.value!.organizeID ?? 0,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        try {
          state.tableData.clear();
          var list = <DataRow>[];
          var index = 0;
          for (var item in jsonDecode(response.data)) {
            var data = ProductionDayReportInfo.fromJson(item);
            state.tableData.add(data);
            list.add(
              state.createDataRow(
                data,
                index.isEven ? Colors.transparent : Colors.grey.shade100,
                () => showReasonDialog(),
              ),
            );
            index++;
          }
          state.tableDataRows.value = list;
          Get.back(closeOverlays: true);
        } on Error catch (e) {
          logger.e(e);
          errorDialog(content: 'json_format_error'.tr);
        }
      } else {
        errorDialog(content: response.message ?? '查询失败');
      }
    });
  }

  bool checkDate() {
    var now = DateTime.now();
    if (pickerControllerDate.pickDate.value.year == now.year &&
        pickerControllerDate.pickDate.value.month == now.month) {
      if (pickerControllerDate.pickDate.value.day == now.day) {
        return true;
      }
      if (pickerControllerDate.pickDate.value.day + 1 == now.day &&
          now.hour < 9) {
        return true;
      }
    }
    return false;
  }

  showReasonDialog() {
    if (checkDate()) {
      reasonDateController.pickDate.value = DateTime.now();
      reasonInputPopup(
        title: reasonTitle,
        confirm: (reason) {
          submitReason(
            reasonDateController.getDateFormatYMD(),
            reason,
          );
        },
      );
    } else {
      errorDialog(content: '每天数据次日9点之后不能修改');
    }
  }

  submitReason(String date, String reason) {
    httpPost(
      loading: '正在保存...',
      method: webApiSubmitDayReportReason,
      query: {
        'Date': date,
        'Value': reason,
        'DeptID': userController.user.value!.departmentID ?? 0,
        'Number': userController.user.value!.number ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        successDialog(content: response.message, back: () => query());
      } else {
        errorDialog(content: response.message ?? '保存失败');
      }
    });
  }
}
