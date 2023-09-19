import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/worker_production_info.dart';

class WorkerProductionReportState {
  RxList<WorkerProductionInfo> dataList = <WorkerProductionInfo>[].obs;

}
