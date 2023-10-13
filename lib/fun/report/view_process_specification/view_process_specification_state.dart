import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../http/response/process_specification_info.dart';

class ViewProcessSpecificationState {
  RxList<ProcessSpecificationInfo> pdfList=<ProcessSpecificationInfo>[].obs;
  var isShowWeb=false.obs;
}
