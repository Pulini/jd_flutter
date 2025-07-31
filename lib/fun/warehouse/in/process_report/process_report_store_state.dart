import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/process_modify_info.dart';
import 'package:jd_flutter/bean/http/response/sap_picking_info.dart';
import 'package:jd_flutter/bean/http/response/scan_process_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ProcessReportStoreState {

  var showClick = false.obs;
  var type = 1.obs;  //搜索类型
  var scanNumber =""; //扫码人工号
  var instructionNumber =""; //指令号
  var controller = TextEditingController();  //条码内容控制器

  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var modifyList = <ProcessModifyInfo>[].obs; //工序汇报入库的条码信息
  var usedList = <String>[];

  var palletNumber = ''.obs;  //托盘号
  PalletDetailItem2Info? pallet; //托盘信息

  //从数据库读取条码信息
  processReportState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.processReportInStock.text,
      callback: (list) => barCodeList.value = list,
    );
  }

  //校验条码信息
  getBarCodeStatus({
    required int processFlowID,
    required String processName,
    required Function(ScanProcessInfo) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'process_report_store_verifying_tags'.tr,
      method: webApiGetBarCodeStatus,
      body: {
        'BarCodeList': [
          for (var item in barCodeList) {'BarCode': item.code,'PalletNo':''}
        ],
        'ProcessFlowID': processFlowID,
        'ProcessName': processName,
        'Type': BarCodeReportType.processReportInStock.text,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(ScanProcessInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  //获取汇总表
  getBarCodeReport({
    required int processFlowID,
    required Function(dynamic) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'process_report_store_obtaining_summary_information'.tr,
      method: webApiNewGetSubmitBarCodeReport,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'BillTypeID':BarCodeReportType.processReportInStock.value,
        'Red':  -1,
        'ProcessFlowID': processFlowID,
        'OrganizeID': userInfo?.organizeID,
        'DefaultStockID': userInfo?.defaultStockID,
        'UserID': userInfo?.userID,
        'EmpID': userInfo?.empID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }



  //提交条码信息
  submitBarCode({
    required WorkerInfo worker,
    required BarCodeProcessInfo process,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'process_report_store_submitting_process_store'.tr,
      method: webApiUploadProcessReport,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'EmpCode': worker.empID,
        'ProcessFlowID': process.processFlowID,
        'ProcessNodeName': process.processNodeName,
        'UserID': userInfo?.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.data);
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }
}