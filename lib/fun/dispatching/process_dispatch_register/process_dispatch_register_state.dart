import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/process_dispatch_register_info.dart';
import 'package:jd_flutter/bean/http/response/worker_info.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';

class ProcessDispatchRegisterState {
  var typeBody = ''.obs;
  var progress = ''.obs;
  var orderList = <List<Orders>>[].obs;
  var isDetails = false.obs;
  var labelList = <Barcode>[].obs;
  var workerList = <WorkerInfo>[].obs;

  var select = (-1).obs;
  ProcessDispatchLabelInfo? labelInfo;
  var instructions = ''.obs;
  var worker = ''.obs;
  var processName = ''.obs;
  var qty = ''.obs;
  var selectedAll = false.obs;

  var barCodeList = <ProcessDispatchLabelInfo>[].obs;

  ProcessDispatchRegisterState();

  void getProcessWorkCardByBarcode({
    required String barCode,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: 'process_dispatch_register_getting_dispatch_order_info'.tr,
      method: webApiGetProcessWorkCard,
      params: {
        'Barcode': barCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var orderInfo =
            ProcessDispatchRegisterOrderInfo.fromJson(response.data);

        var group = <List<Orders>>[];
        groupBy(orderInfo.info ?? <Orders>[], (v) => v.size ?? '')
            .forEach((k, v) {
          group.add(v);
        });
        var process = <String>[];
        groupBy(orderInfo.info ?? <Orders>[], (v) => v.processName ?? '')
            .forEach((k, v) {
          process.add(k);
        });
        orderList.value = group;
        labelList.value = orderInfo.barcode ?? [];
        typeBody.value = orderInfo.info![0].factoryType ?? '';
        progress.value = process.join(',');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void queryLabelData({
    required String code,
    required Function(List<ProcessDispatchLabelInfo> labelInfo) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetReportDataByBarcode,
      loading: 'process_dispatch_register_getting_label_info'.tr,
      body: [
        {'BarCode': code}
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call([
          for (var json in response.data)
            ProcessDispatchLabelInfo.fromJson(json)
        ]);
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void modifyLabelWorker({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiChangeLabelingBarcodeEmp,
      loading: 'process_dispatch_register_submitting_modify'.tr,
      body: {
        'BarCode': labelInfo!.barCode,
        'EmpID': workerList[select.value].empID,
        'UserID': userInfo!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void deleteLabel({
    required String barCode,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiUnReportAndDelLabelingBarcode,
      loading: 'process_dispatch_register_detecting_label'.tr,
      body: {
        'Barcode': barCode,
        'DeptID': userInfo!.departmentID,
        'UserID': userInfo!.userID,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  void submitReport({
    required void Function(String) success,
    required void Function(String) error,
  }) {
    httpPost(
      method: webApiReportLabelingBarcodeBatch,
      loading: '正在提交报工...',
      body: [
        for(var item in barCodeList)
          {
            'Size':item.size,
            'Barcode':item.barCode,
            'ProcessName':item.processName,
            'EmpID':item.empID,
            'Qty':item.qty!<=0?item.boxCapacity:item.qty,
            'BillInterID':item.billInterID,
            'BillEntryID':item.billEntryID,
            'UserID':userInfo?.userID,
            'DeptID':userInfo?.departmentID,
          }
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        success.call(response.message ?? '');
      } else {
        error.call(response.message ?? '');
      }
      if(!response.data.isBlank&&response.data is List<String>){
          List<String> codes = response.data;
          for (var code in codes) {
            for (var v in barCodeList) {
              if(v.barCode==code){
                v.isReported.value=true;
              }
            }
          }
      }
    });
  }
}
