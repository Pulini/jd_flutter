
import 'package:get/get.dart';

import '../../../bean/http/response/production_materials_info.dart';

class ProductionMaterialsReportState {
  var tableOpenIndex=<bool>[];
  var tableData = <List<ProductionMaterialsInfo>>[].obs;
  var isPickingMaterialCompleted = false.obs;
  var etInstruction = '';
  var etOrderNumber = '';
  var etSizeOrderNumber = '';
  var select = 0.obs;
  ProductionMaterialsReportState() {
    ///Initialize variables
  }

}