import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/component_code_info.dart';
import 'package:jd_flutter/bean/http/response/part_report_error_info.dart';
import 'package:jd_flutter/bean/http/response/report_details_info.dart';
import 'package:jd_flutter/fun/report/part_report_scan/part_report_scan_state.dart';
import 'package:jd_flutter/fun/report/part_report_scan/part_report_scan_summary_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartReportScanLogic extends GetxController {
  final PartReportScanState state = PartReportScanState();

  //扫码
  addCode(String newCode) {
    if (newCode.isNotEmpty) {
      if (state.buttonType.value) {
        //新增
        if (isExists(newCode)) {
          showSnackBar(message: 'part_report_code_is_have'.tr);
        } else {
          state.dataList.add(ComponentCodeInfo(barCode: newCode, use: false));
          state.dataList.refresh();
        }
      } else {
        //删除
        if (!state.dataList.any((bean) => bean.barCode == newCode)) {
          showSnackBar(message: 'part_report_code_is_not_have'.tr);
        } else {
          state.dataList
              .remove(ComponentCodeInfo(barCode: newCode, use: false));
        }
      }
    } else {
      showSnackBar(message: 'part_report_code_is_empty'.tr);
    }
  }

  //是否存在条码
  bool isExists(String code) {
    for (var v in state.dataList) {
      if (v.barCode == code) {
        return true;
      }
    }
    return false;
  }

  //删除该条码
  deleteCode(ComponentCodeInfo code) {
    state.dataList.remove(code);
    state.dataList.refresh();
  }

  //获取汇总表
  getBarCodeReportDetails(String type) {
    httpPost(
      method: webApiGetBarCodeReportDetails,
      loading: 'part_report_getting_summary'.tr,
      body: {
        'UserID': getUserInfo()!.userID,
        'DeptID': getUserInfo()!.departmentID,
        'Type': type,
        'Barcodes': [
          for (var i = 0; i < state.dataList.length; ++i)
            state.dataList[i].barCode
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.reportInfo.value =
            ReportDetailsInfo.fromJson(response.data).list ?? [];
        Get.to(() => const PartReportScanSummaryPage())?.then((v) {
          if (v == null) {
            showSnackBar(message: 'part_report_summary_not_submit'.tr);
            //没有去提交条码
          } else if (v == true) {
            clearData();
            //条码提交成功
          }
        });
      } else {
        if (response.message == '您的账号在其他设备登录，如非本人操作，则密码可能已泄露，建议前往个人中心修改密码。') {
          errorDialog(content: response.message);
        } else if (response.message!.startsWith('---')) {
          errorDialog(
              content: response.message ?? 'part_report_acquisition_failed'.tr);
        } else {
          var message = response.message;
          message?.replaceAll('\\', '');

          state.errorInfo = PartReportErrorInfo.fromJson(response.data);

          if (!state.errorInfo.barcodes.isNullOrEmpty()) {
            state.errorInfo.barcodes?.forEach((c) {
              for (var v in state.dataList) {
                if (c == v.barCode) {
                  v.use = true;
                }
              }
            });
            state.dataList.refresh(); //刷新
            showSnackBar(message: state.errorInfo.info.toString());
          }
          errorDialog(content: state.errorInfo.info.toString());
        }
      }
    });
  }

  //条码报工
  submitBarCodeReport({
    required Function(String) submitSuccess,
  }) {
    httpPost(
      method: webApiBarCodeReport,
      loading: 'part_report_summary_reporting'.tr,
      body: {
        'UserID': getUserInfo()!.userID,
        'DeptID': getUserInfo()!.departmentID,
        'Date': getDateSapYMD(),
        'Barcodes': [
          for (var i = 0; i < state.dataList.length; ++i)
            state.dataList[i].barCode
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        submitSuccess
            .call(response.message ?? 'part_report_summary_submit_report'.tr);
      } else {
        errorDialog(content: response.message ?? '');
      }
    });
  }

  //清空条码. 清空汇总表
  clearData() {
    state.dataList.clear();
    state.reportInfo.clear();
  }

  //是否已经扫过
  bool haveBarCode(){
    if(state.dataList.isNotEmpty){
      return true;
    }else{
      showSnackBar(message: 'part_report_barcode_is_empty'.tr);
      return false;
    }
  }
}
