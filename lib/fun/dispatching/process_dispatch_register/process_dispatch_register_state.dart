import 'package:collection/collection.dart';
import 'package:get/get.dart';
import '../../../bean/http/response/process_dispatch_register_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../utils/utils.dart';
import '../../../utils/web_api.dart';

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

  ProcessDispatchRegisterState();

  getProcessWorkCardByBarcode({
    required String barCode,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: '正在派工单信息...',
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

  queryLabelData({
    required String code,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiGetReportDataByBarcode,
      loading: '正在获取标签信息...',
      body: [
        {'BarCode': code}
      ],
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        labelInfo = ProcessDispatchLabelInfo.fromJson(response.data[0]);
        instructions.value = labelInfo!.instructions ?? '';
        worker.value = '${labelInfo!.empName}(${labelInfo!.empNumber})';
        processName.value = labelInfo!.processName ?? '';
        qty.value =
            '${labelInfo!.qty.toShowString()}/${labelInfo!.boxCapacity.toShowString()}';
      } else {
        error.call(response.message ?? '');
      }
    });
  }

  modifyLabelWorker({
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiChangeLabelingBarcodeEmp,
      loading: '正在提交修改...',
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

  deleteLabel({
    required String barCode,
    required Function(String msg) success,
    required Function(String msg) error,
  }) {
    httpPost(
      method: webApiUnReportAndDelLabelingBarcode,
      loading: '正在删除贴标...',
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
}
