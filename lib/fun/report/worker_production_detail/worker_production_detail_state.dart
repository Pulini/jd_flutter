import 'package:get/get.dart';

import '../../../bean/http/response/worker_production_detail_info.dart';
import '../../../utils.dart';
import '../../../web_api.dart';

class WorkerProductionDetailState {
  var etWorker = '';
  var showPrice = checkUserPermission("303100102");
  var showAmount = checkUserPermission("303100103");

  // var showPrice = true;
  // var showAmount =true;

  RxList<WorkerProductionDetailShow> dataList =
      <WorkerProductionDetailShow>[].obs;

  getProductionReport({
    required String beginDate,
    required String endDate,
    required String itemID,
    required String reportType,
    required Function() success,
    required Function(String msg) error,
  }) {
    httpGet(
      loading: '正在查询计件明细...',
      method: webApiProductionReport,
      params: {
        'BeginDate': beginDate,
        'EndDate': endDate,
        'EmpNumber': etWorker,
        'ItemID': itemID,
        'DeptID': userInfo?.departmentID ?? '',
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        dataList.value = formatData(response.data, reportType);
        success.call();
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  List<WorkerProductionDetailShow> formatData(dynamic json, String reportType) {
    var list = <WorkerProductionDetail>[];
    for (var item in json) {
      switch (reportType) {
        case '1001':
          list.add(WorkerProductionDetailType1.fromJson(item));
          break;
        case '1002':
          list.add(WorkerProductionDetailType2.fromJson(item));
          break;
        case '1019':
          list.add(WorkerProductionDetailType3.fromJson(item));
          break;
      }
    }
    var ids = <int>[];
    var data = <WorkerProductionDetailShow>[];
    for (var v in list) {
      if (!ids.contains(v.empID)) ids.add(v.empID!);
    }
    for (var id in ids) {
      var item = list.where((v) => v.empID == id);
      var body = item.where((v) => v.level != 1 && v.level != 2).toList();
      var head = item.singleWhere((v) => v.level == 2);
      var title = '';
      switch (reportType) {
        case '1001':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType1)
              .billNO!;
          break;
        case '1002':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType2)
              .itemNo!;
          break;
        case '1019':
          title = (item.singleWhere((v) => v.level == 1)
                  as WorkerProductionDetailType3)
              .date!;
          break;
      }
      data.add(WorkerProductionDetailShow(title, head, body));
    }
    return data;
  }
}
