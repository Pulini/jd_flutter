import 'package:get/get.dart';
import '../../../bean/http/response/sap_surplus_material_info.dart';

class SapSurplusMaterialStockInState {
  var dispatchOrderNumber =''.obs;
  var weight =(0.0).obs;
  var materialList=<SapSurplusMaterialLabelInfo>[].obs;
  var interceptorText='';
  SapSurplusMaterialStockInState() {
    ///Initialize variables
  }
}
