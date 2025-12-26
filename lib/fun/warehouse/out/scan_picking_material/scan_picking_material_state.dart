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

  void getBarCodeStatus({
    required int processFlowID,
    required String processName,
    required Function(ScanPickingMaterialReportInfo, String) success,
    required Function() finish,
  }) {
    httpPost(
      loading: 'scan_picking_material_submitting_label'.tr,
      method: webApiGetBarCodeStatus,
      body: {
        'BarCodeList': [
          for (var item in barCodeList) {'BarCode': item.code, 'PalletNo': ''}
        ],
        'ProcessFlowID': processFlowID,
        'ProcessName': processName,
        'Type': BarCodeReportType.jinCanMaterialOutStock.text,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
          ScanPickingMaterialReportInfo.fromJson(response.data),
          response.message ?? 'query_default_error'.tr,
        );
      }
      finish.call();
    });
  }

  void submitBarCode({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'scan_picking_material_submitting_picking'.tr,
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
