import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/base_data.dart';
import 'package:jd_flutter/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import '../../../bean/http/response/production_materials_info.dart';
import '../../../route.dart';
import '../../../widget/dialogs.dart';
import '../../../widget/picker/picker_controller.dart';
import 'production_materials_report_state.dart';

class ProductionMaterialsReportLogic extends GetxController {
  final ProductionMaterialsReportState state = ProductionMaterialsReportState();
  var pickerControllerSapProcessFlow = OptionsPickerController(
    PickerType.sapProcessFlow,
    saveKey:
        '${RouteConfig.productionMaterialsReportPage.name}${PickerType.sapProcessFlow}',
  );

  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  query() {
    if (state.etInstruction.isEmpty &&
        state.etOrderNumber.isEmpty &&
        state.etSizeOrderNumber.isEmpty) {
      showSnackBar(title: '查询', message: '请输入查询条件');
      return;
    }
    httpGet(
      method: webApiGetSapMoPickList,
      loading: '正在查询物料料表...',
      params: {
        'ShowType': '0',
        'interID': '',
        'instruction': state.etInstruction,
        'order': state.etOrderNumber,
        'size': state.etSizeOrderNumber,
        'processId': pickerControllerSapProcessFlow.selectedId.value,
        'salesOrderNumber': '',
        'productionOrderNumber': '',
        'position': '',
        'outsourcingProcess': '',
        'materialCode': '',
      },
    ).then((response) => dataFormat(response));
  }

  otherInQuery(int interID) {
    httpGet(
      method: webApiGetSapMoPickList,
      loading: '正在查询物料料表...',
      params: {
        'ShowType': '0',
        'interID': interID,
        'instruction': '',
        'order': '',
        'size': '',
        'processId': '',
        'salesOrderNumber': '',
        'productionOrderNumber': '',
        'position': '',
        'outsourcingProcess': '',
        'materialCode': '',
      },
    ).then((response) => dataFormat(response));
  }

  itemQuery(ProductionMaterialsInfo data) {
    httpGet(
      method: webApiGetSapMoPickList,
      loading: '正在查询物料料表...',
      params: {
        'ShowType': '1',
        'interID': '',
        'instruction': '',
        'order': '',
        'size': '',
        'processId': '',
        'salesOrderNumber': data.salesOrderNumber,
        'productionOrderNumber': data.productionOrderNumber,
        'position': data.position,
        'outsourcingProcess': data.outsourcingProcess,
        'materialCode': data.materialCode,
      },
    ).then((response) => dataFormat(response));
  }

  dataFormat(BaseData response) {
    if (response.resultCode == resultSuccess) {
      state.tableOpenIndex.clear();
      var group = <List<ProductionMaterialsInfo>>[];
      groupBy([
        for (var i = 0; i < response.data.length; ++i)
          ProductionMaterialsInfo.fromJson(response.data[i])
      ], (v) => v.subItemMaterialCode).forEach((k, v) {
        group.add(v);
        state.tableOpenIndex.add(false);
      });
      state.tableData.value = group;
    } else {
      errorDialog(content: response.message);
    }
  }
}
