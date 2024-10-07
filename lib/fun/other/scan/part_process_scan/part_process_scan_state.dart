import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/scan_barcode_info.dart';
import 'package:jd_flutter/utils.dart';
import 'package:jd_flutter/web_api.dart';

import '../../../../bean/http/response/worker_info.dart';
import '../../../../widget/dialogs.dart';

class PartProcessScanState {
  var barCodeList = <String>[].obs;
  var modifyEmpList = <EmpInfo>[].obs;
  var modifyDistributionList = <ReportItemData>[].obs;
  var modifyReportList = <ReportInfo>[].obs;
  var modifyBarCodeList = <BarCodeInfo>[].obs;
  var workerPercentageList = <Distribution>[].obs;
  var workerList = <WorkerInfo>[].obs;
  var isSelectAll=false.obs;

  PartProcessScanState() {
    ///Initialize variables
  }

  ///获取组员列表数据
  reportViewGetWorkerList() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList.value = list,
      error: (msg) => errorDialog(content: msg),
    );
  }

  getPartProcessReportedReport({
    required Function() success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetPartProcessReportedReport,
      loading: '正在获取汇总信息...',
      body: {'BarCodeList': barCodeList.toList()},
    ).then((response) {
       modifyReportList.value = [
        for (var i = 1; i < 10; ++i)
          ReportInfo(
            type: '0',
            name: 'processName$i',
            size: (i*15/2).toString(),
            mtono: 'mtono',
            mtonoQty: (i * 100.0).toShowString(),
            qty: (i * 100.0).toShowString(),
          ),
         ReportInfo(
           type: '1',
           name: 'processName',
           size:  (20*15/2).toString(),
           mtono: 'mtono',
           mtonoQty:(20 * 100.0).toShowString(),
           qty: (20 * 100.0).toShowString(),
         ),
         ReportInfo(
           type: '2',
           name: 'processName',
           size: (30*15/2).toString(),
           mtono: 'mtono',
           mtonoQty:(30 * 100.0).toShowString(),
           qty: (30 * 100.0).toShowString(),
         ),
      ];
      modifyBarCodeList.value = [
        for (var i = 1; i < 10; ++i)
          BarCodeInfo(
            barCode: i%2==0?'barCode1':'barCode2',
            qty: i * 10,
            processName: 'processName$i',
          )
      ];
      groupBy(
        modifyReportList.where((v) => v.type == '0'),
        (v) => v.name,
      ).forEach((k, v) {
        modifyDistributionList.add(ReportItemData.fromData(
          empList: modifyEmpList
              .where(
                (v1) => v1.processName == v[0].name,
              )
              .toList(),
          reportList: v,
        ));
      });

      success.call();
      if (response.resultCode == resultSuccess) {
        var data = ScanBarcodeReportedReportInfo.fromJson(
          response.data,
        );
        modifyEmpList.value = data.empList ?? [];
        modifyReportList.value = data.reportList ?? [];
        modifyBarCodeList.value = data.barCodeList ?? [];
        groupBy(
          modifyReportList.where((v) => v.type == '0'),
              (v) => v.name,
        ).forEach((k, v) {
          modifyDistributionList.add(ReportItemData.fromData(
            empList: modifyEmpList
                .where(
                  (v1) => v1.processName == v[0].name,
            )
                .toList(),
            reportList: v,
          ));
        });
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  subItemCancelReport({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {


    httpPost(
      loading: '正在提交工序报工...',
      method: webApiProductionDispatchReportSubmit,
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

  cleanReportData(){
    modifyEmpList.value=[];
    modifyDistributionList.value=[];
    modifyReportList.value=[];
    modifyBarCodeList.value=[];
    workerPercentageList.value=[];
    isSelectAll.value=false;
  }
}
