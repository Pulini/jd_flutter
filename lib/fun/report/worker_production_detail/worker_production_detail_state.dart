import 'package:get/get.dart';

import '../../../bean/http/response/worker_production_detail_info.dart';
import '../../../utils.dart';

class WorkerProductionDetailState {
  var etWorker = '';
  var showPrice = checkUserPermission("303100102");
  var showAmount = checkUserPermission("303100103");
  // var showPrice = true;
  // var showAmount =true;

  RxList<WorkerProductionDetailShow> dataList = <WorkerProductionDetailShow>[].obs;

}
