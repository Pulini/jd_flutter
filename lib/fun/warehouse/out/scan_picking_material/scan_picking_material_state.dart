import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/bean/http/response/scan_picking_material_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ScanPickingMaterialState {
  var reverse = false.obs;
  var barCodeList = <BarCodeInfo>[].obs;

  ScanPickingMaterialState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.jinCanMaterialOutStock.name,
      callback: (list) => barCodeList.value = list,
    );
  }

  getBarCodeStatus({
    required int processFlowID,
    required String processName,
    required Function(ScanPickingMaterialReportInfo) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在校验标签...',
      method: webApiGetBarCodeStatus,
      body: {
        'BarCodeList': [
          for (var item in barCodeList) {'BarCode': item.code,'PalletNo':''}
        ],
        'ProcessFlowID': processFlowID,
        'ProcessName': processName,
        'Type': BarCodeReportType.jinCanSalesScanningCode.text,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(ScanPickingMaterialReportInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  getBarCodeReport({
    required int processFlowID,
    required Function(dynamic) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在获取汇总信息...',
      method: webApiNewGetSubmitBarCodeReport,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'BillTypeID':BarCodeReportType.jinCanMaterialOutStock.value,
        'Red': reverse.value ? 1 : -1,
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
  submitBarCode({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: '正在提交领料...',
      method: webApiJinCanMaterialOutStockSubmit,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'BillTypeID': BarCodeReportType.jinCanMaterialOutStock.value,
        'Red': reverse.value ? 1 : -1,
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
}
