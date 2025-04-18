import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class SaleScanOutWarehouseState {
  var barCodeList = <BarCodeInfo>[].obs;
  var usedBarCodeList = <UsedBarCodeInfo>[];

  SaleScanOutWarehouseState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.jinCanSalesScanningCode.name,
      callback: (list) => barCodeList.value = list,
    );
  }


  submitBarCode({
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'sale_scan_out_warehouse_submitting_picking'.tr,
      method: webApiJinCanSalesScanningCodeSubmit,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'EmpCode': userInfo?.number,
        'TranTypeID': BarCodeReportType.jinCanSalesScanningCode.value,
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
