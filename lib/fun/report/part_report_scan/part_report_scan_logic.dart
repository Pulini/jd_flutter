import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/component_code_info.dart';
import 'package:jd_flutter/bean/http/response/part_report_error_info.dart';
import 'package:jd_flutter/bean/http/response/report_details_info.dart';
import 'package:jd_flutter/fun/report/part_report_scan/part_report_scan_state.dart';
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
  deleteCode(ComponentCodeInfo code){
      state.dataList.remove(code);
      state.dataList.refresh();
  }

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
        state.reportInfo = ReportDetailsInfo.fromJson(response.data);
      } else {
        if (response.message == '您的账号在其他设备登录，如非本人操作，则密码可能已泄露，建议前往个人中心修改密码。') {
          errorDialog(content: response.message);
        } else if (response.message!.startsWith('---')) {
          errorDialog(content: response.message?? 'part_report_acquisition_failed'.tr);
        } else {
          var message = response.message;
          message?.replaceAll('\\', '');

          state.errorInfo = PartReportErrorInfo.fromJson(response.data);

          if (!state.errorInfo.barcodes.isNullOrEmpty()) {
            state.errorInfo.barcodes?.forEach((c) {
              for (var v in state.dataList) {
                if(c == v.barCode){
                  v.use=true;
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
}
