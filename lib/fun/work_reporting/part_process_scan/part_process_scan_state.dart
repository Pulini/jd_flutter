import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PartProcessScanState {
  var barCodeList = <String>[].obs;
  var reportList = <ReportInfo>[].obs;
  var modifyEmpList = <EmpInfo>[].obs;
  var modifyDistributionList = <ReportItemData>[].obs;
  var modifyReportList = <ReportInfo>[].obs;
  var modifyBarCodeList = <BarCodeInfo>[].obs;
  var workerPercentageList = <Distribution>[].obs;
  var workerList = <WorkerInfo>[].obs;
  var isSelectAll = false.obs;

  //获取组员列表数据
  reportViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList.value = list,
      error: (msg) => showSnackBar( message: msg),
    );
  }

  getPartProcessReportedReport({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetPartProcessReportedReport,
      loading: 'part_process_scan_getting_summary'.tr,
      body: {'BarCodeList': barCodeList.toList()},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var data = ScanBarcodeReportedReportInfo.fromJson(response.data);
        modifyEmpList.value = data.empList ?? [];
        modifyReportList.value = data.reportList ?? [];
        modifyBarCodeList.value = data.barCodeList ?? [];
        groupBy(modifyReportList.where((v) => v.type == 0), (v) => v.name)
            .forEach((k, v) {
          modifyDistributionList.add(
            ReportItemData.fromData(
              empList: modifyEmpList
                  .where((v1) => v1.processName == v[0].name)
                  .toList(),
              reportList: v,
            ),
          );
        });
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  submitChangeReport({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      loading: 'part_process_scan_submitting_process_report'.tr,
      method: webApiPartProductionReportModify,
      body: [
        {
          'Date': getDateYMD(),
          'DeptID': userInfo?.departmentID,
          'UserID': userInfo?.userID,
          'Barcodes': [],
          'ProcessList': [],
        }
      ].toList(),
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  getPartProductionReportTable({
    required Function() success,
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
        reportList.value = [
          for (var json in response.data) ReportInfo.fromJson(json)
        ];
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  cleanReportData() {
    modifyEmpList.value = [];
    modifyDistributionList.value = [];
    modifyReportList.value = [];
    modifyBarCodeList.value = [];
    workerPercentageList.value = [];
    isSelectAll.value = false;
  }
}
