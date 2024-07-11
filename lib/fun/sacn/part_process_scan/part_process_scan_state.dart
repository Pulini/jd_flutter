import 'package:get/get.dart';

import '../../../bean/http/response/scan_barcode_info.dart';

class PartProcessScanState {
  var barCodeList=<String>[].obs;
  // var reportEmpList =<EmpInfo>[].obs;
  var reportProcessList =<List<ReportInfo>>[].obs;
  var reportSelectList =<bool>[].obs;
  var reportDistributionList =<List<Distribution>>[].obs;
  // var reportBarCodeList =<BarCodeInfo>[].obs;
  PartProcessScanState() {
    ///Initialize variables
  }
}
