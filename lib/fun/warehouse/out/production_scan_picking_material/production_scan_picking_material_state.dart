import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/bar_code.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ProductionScanPickingMaterialState {
  var reverse = false.obs;
  var barCodeList = <BarCodeInfo>[].obs;
  var usedBarCodeList = <UsedBarCodeInfo>[];

  ProductionScanPickingMaterialState() {
    BarCodeInfo.getSave(
      type: BarCodeReportType.productionScanPicking.name,
      callback: (list) => barCodeList.value = list,
    );
  }


  void submitBarCode({
    required String worker,
    required String supplier,
    required int department,
    required Function(String) success,
    required Function(String) error,
  }) {
    httpPost(
      loading: 'production_scan_picking_material_submitting_picking'.tr,
      method: webApiUploadProductionScanning,
      body: {
        'BarCodeList': [
          for (var item in barCodeList.where((v) => !v.isUsed))
            {'BarCode': item.code}
        ],
        'Red': reverse.value,
        'SAPSupplierNumber': supplier,
        'FDepartmentID': department,
        'EmpCode': worker,
        'DefaultStockID': userInfo?.defaultStockID,
        'TranTypeID': BarCodeReportType.productionScanPicking.value,
        'OrganizeID': userInfo?.organizeID,
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
