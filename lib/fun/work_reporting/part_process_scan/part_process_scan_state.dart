import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';

class PartProcessScanState {
  var barCodeList = <String>[].obs;
  var reportList = <ReportInfo>[].obs;
  var distributionList = <ReportItemData>[].obs;
  var modifyBarCodeList = <BarCodeInfo>[].obs;
  var workerPercentageList = <Distribution>[].obs;
  var workerList = <WorkerInfo>[].obs;
  var isShowCheckBox = false.obs;
  var isSelectAll = false.obs;

  //获取组员列表数据
  void reportViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList.value = list,
      error: (msg) => showSnackBar(message: msg),
    );
  }

  void getPartProcessReportedReport({
    required Function(ScanBarcodeReportedReportInfo) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetPartProcessReportedReport,
      loading: 'part_process_scan_getting_summary'.tr,
      body: {'BarCodeList': barCodeList.toList()},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(ScanBarcodeReportedReportInfo.fromJson(response.data));
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void submitChangeReport({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'part_process_scan_submitting_process_report'.tr,
      method: webApiPartProductionReportModify,
      body: {
        'Date': getDateYMD(),
        'DeptID': userInfo?.departmentID,
        'UserID': userInfo?.userID,
        'Barcodes': modifyBarCodeList
            .where((v) => v.isSelect.value)
            .map((v) => v.barCode)
            .toSet()
            .toList(),
        'ProcessList': distributionList
            .map((v) => {
                  'EmpList': v.distribution
                      .map((w) => {
                            'EmpCode': w.number,
                            'EmpID': w.empId,
                            'EmpName': w.name,
                            'Qty': w.distributionQty,
                          })
                      .toList(),
                  'ProcessName': v.reportList.first.name,
                  'Size': v.reportList.map((s) => s.size ?? '').toSet().toList()
                })
            .toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void getPartProductionReportTable({
    required Function(List<ReportInfo>) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'part_process_scan_submitting_process_report'.tr,
      method: webApiGetPartProductionReportTable,
      body: {
        'BarCodeList': barCodeList.toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(
          [for (var json in response.data) ReportInfo.fromJson(json)],
        );
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void submitDispatch({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'part_process_scan_submitting_process_report'.tr,
      method: webApiBarCodeProcessReportSubmit,
      body: {
        'Barcodes': barCodeList.toList(),
        'Date': getDateYMD(),
        'DeptID': userInfo?.departmentID,
        'UserID': userInfo?.userID,
        'ProcessList': distributionList
            .map((v) => {
                  'EmpList': v.distribution
                      .map((w) => {
                            'EmpCode': w.number,
                            'EmpID': w.empId,
                            'EmpName': w.name,
                            'Qty': w.distributionQty,
                          })
                      .toList(),
                  'ProcessName': v.reportList.first.name,
                  'Size': v.reportList.map((s) => s.size ?? '').toSet().toList()
                })
            .toList(),
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void cleanReportData() {
    distributionList.value = [];
    reportList.value = [];
    modifyBarCodeList.value = [];
    workerPercentageList.value = [];
    isSelectAll.value = false;
  }
}
