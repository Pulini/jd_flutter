import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../bean/http/response/process_dispatch_register_order_info.dart';
import '../../../bean/http/response/worker_info.dart';
import '../../../utils.dart';
import '../../../web_api.dart';

class ProcessDispatchRegisterState {
  var order = 'GXPG24446580/5'.obs;
  var typeBody = ''.obs;
  var progress = ''.obs;
  var orderList = <List<Orders>>[].obs;
  var isDetails = false.obs;
  var labelList = <Barcode>[].obs;
  var workerList = <WorkerInfo>[].obs;

  ProcessDispatchRegisterState() {
    getWorkerInfo(
      department: userInfo?.departmentID.toString(),
      workers: (list) => workerList.value = list,
      error: (msg) =>
          showSnackBar(title: '查询失败', message: msg, isWarning: true),
    );
  }

  getProcessWorkCardByBarcode({
    required String barCode,
    required Function() success,
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
        success.call();
      } else {
        error.call(response.message ?? '');
      }
    });
  }
}
