import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/component_code_info.dart';
import 'package:jd_flutter/bean/http/response/part_report_error_info.dart';
import 'package:jd_flutter/bean/http/response/report_details_info.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_scan/part_report_scan_state.dart';
import 'package:jd_flutter/fun/work_reporting/part_report_scan/part_report_scan_summary_view.dart';
import 'package:jd_flutter/utils/extension_util.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartReportScanLogic extends GetxController {
  final PartReportScanState state = PartReportScanState();

  //扫码
  void addCode(String newCode) {
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
  void deleteCode(ComponentCodeInfo code) {
    state.dataList.remove(code);
    state.dataList.refresh();
  }

  //获取汇总表
  void getBarCodeReportDetails(String type) {
    httpPost(
      method: webApiGetBarCodeReportDetails,
      loading: 'part_report_getting_summary'.tr,
      body: {
        'UserID': userInfo?.userID,
        'DeptID': userInfo?.departmentID,
        'Type': type,
        'Barcodes': [
          for (var i = 0; i < state.dataList.length; ++i)
            state.dataList[i].barCode
        ],
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var reportList = ReportDetailsInfo.fromJson(response.data).list ?? [];

        // 创建自定义表头
        var headerItem = SummaryLists(
          type: -1, // 使用特殊type标识表头
          mtono: '指令',
          name: '工序',
          size: '尺码',
          empName: '员工',
          // 设置其他需要的字段
        );

        // 在列表开头插入表头
        reportList.insert(0, headerItem);

        state.reportInfo.value = reportList;
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
          String jsonPart = extractJsonFromString(message.toString());
          try {
            // 解析 JSON 字符串
            Map<String, dynamic> jsonMap = json.decode(jsonPart);

            // 提取 Barcodes 数组
            List<String> barcodes = List<String>.from(jsonMap['Barcodes']);
            if (barcodes.isNotEmpty) {
              for (var c in barcodes) {
                for (var v in state.dataList) {
                  if (c == v.barCode) {
                    v.use = true;
                  }
                }
              }
              state.dataList.refresh(); //刷新
            }
            errorDialog(content:  jsonMap['Info']);
          } catch (e) {
            errorDialog(content:  '解析出错');
          }
        }
      }
    });
  }

  String extractJsonFromString(String input) {
    // 查找第一个 '{' 的位置
    int startIndex = input.indexOf('{');
    if (startIndex != -1) {
      // 返回从 '{' 开始到字符串结尾的部分
      return input.substring(startIndex);
    }
    return input;
  }

  //条码报工
  void submitBarCodeReport({
    required Function(String) submitSuccess,
  }) {
    httpPost(
      method: webApiBarCodeReport,
      loading: 'part_report_summary_reporting'.tr,
      body: {
        'UserID': userInfo?.userID,
        'DeptID': userInfo?.departmentID,
        'Date': getDateYMD(),
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
  void clearData() {
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
