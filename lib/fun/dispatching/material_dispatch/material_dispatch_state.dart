import 'package:get/get.dart';

import '../../../bean/http/response/material_dispatch_info.dart';

class MaterialDispatchState {
  var typeBody='';
  var lastProcess=false.obs;
  var unStockIn=false.obs;
  var orderList=<MaterialDispatchInfo>[];
  var showOrderList=<MaterialDispatchInfo>[].obs;
  MaterialDispatchState() {
    ///Initialize variables
  }

}
