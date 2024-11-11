import 'package:get/get.dart';
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
        '${RouteConfig.productionMaterialsReport.name}${PickerType.sapProcessFlow}',
  );

  query() {
    if (state.etInstruction.isEmpty &&
        state.etOrderNumber.isEmpty &&
        state.etSizeOrderNumber.isEmpty) {
      showSnackBar(
        title: 'snack_bar_default_wrong'.tr,
        message: 'production_materials_report_query_error'.tr,
        isWarning: true,
      );
      return;
    }
    state.getSapMoPickList(
      showType: '0',
      instruction: state.etInstruction,
      order: state.etOrderNumber,
      size: state.etSizeOrderNumber,
      processId: pickerControllerSapProcessFlow.selectedId.value,
      error: (msg) => errorDialog(content: msg),
    );
  }

  otherInQuery(int interID) {
    state.getSapMoPickList(
      showType: '0',
      interID: interID,
      error: (msg) => errorDialog(content: msg),
    );
  }

  itemQuery(ProductionMaterialsInfo data) {
    state.getSapMoPickList(
      showType: '1',
      salesOrderNumber: data.salesOrderNumber ?? '',
      productionOrderNumber: data.productionOrderNumber ?? '',
      position: data.position ?? '',
      outsourcingProcess: data.outsourcingProcess ?? '',
      materialCode: data.materialCode ?? '',
      error: (msg) => errorDialog(content: msg),
    );
  }
}
