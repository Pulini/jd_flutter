import 'package:collection/collection.dart';
import 'package:get/get.dart';

import '../../../bean/http/response/production_materials_info.dart';
import '../../../web_api.dart';

class ProductionMaterialsReportState {
  var tableOpenIndex = <bool>[];
  var tableData = <List<ProductionMaterialsInfo>>[].obs;
  var isPickingMaterialCompleted = false.obs;
  var etInstruction = '';
  var etOrderNumber = '';
  var etSizeOrderNumber = '';
  var select = 0.obs;

  getSapMoPickList({
    String showType = '',
    int interID = 0,
    String instruction = '',
    String order = '',
    String size = '',
    String processId = '',
    String salesOrderNumber = '',
    String productionOrderNumber = '',
    String position = '',
    String outsourcingProcess = '',
    String materialCode = '',
    required Function(String msg) error,
  }) {
    httpGet(
      method: webApiGetSapMoPickList,
      loading: 'production_materials_report_querying'.tr,
      params: {
        'ShowType': showType,
        'interID': interID,
        'instruction': instruction,
        'order': order,
        'size': size,
        'processId': processId,
        'salesOrderNumber': salesOrderNumber,
        'productionOrderNumber': productionOrderNumber,
        'position': position,
        'outsourcingProcess': outsourcingProcess,
        'materialCode': materialCode,
      },
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        tableOpenIndex.clear();
        var group = <List<ProductionMaterialsInfo>>[];
        groupBy([
          for (var i = 0; i < response.data.length; ++i)
            ProductionMaterialsInfo.fromJson(response.data[i])
        ], (v) => v.subItemMaterialCode).forEach((k, v) {
          group.add(v);
          tableOpenIndex.add(false);
        });
        tableData.value = group;
      } else {
        error.call(response.message??'');
      }
    });
  }
}
