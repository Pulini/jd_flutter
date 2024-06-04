import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../route.dart';
import '../../../widget/picker/picker_controller.dart';
import 'production_materials_report_state.dart';

class ProductionMaterialsReportLogic extends GetxController {
  final ProductionMaterialsReportState state = ProductionMaterialsReportState();
  var textControllerTypeBody = TextEditingController();
  var textControllerInstruction = TextEditingController();
  var textControllerOrderNumber = TextEditingController();
  var textControllerSizeOrderNumber = TextEditingController();
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

  queryProductionMaterials() {}
}
