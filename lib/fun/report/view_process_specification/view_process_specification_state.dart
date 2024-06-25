import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../bean/http/response/process_specification_info.dart';


class ViewProcessSpecificationState {
  RxList<ProcessSpecificationInfo> pdfList=<ProcessSpecificationInfo>[].obs;
  var etTypeBody = '';
  var isShowWeb=false.obs;
}
