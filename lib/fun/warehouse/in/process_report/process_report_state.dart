import 'package:get/get.dart';

import '../../../../bean/http/response/bar_code.dart';
import '../../../../bean/http/response/sap_picking_info.dart';
import '../../../../bean/http/response/used_bar_code_info.dart';
import '../../../../constant.dart';

class ProcessReportState {

  var showClick = false.obs;
  var code = '';

  var barCodeList = <BarCodeInfo>[].obs; //条码数据
  var usedList = <String>[];

  var palletNumber = ''.obs;  //托盘号
  PalletDetailItem2Info? pallet; //托盘信息

  //从数据库读取条码信息
  // ProcessReportState() {
  //   BarCodeInfo.getSave(
  //     type: barCodeTypes[4],
  //     callback: (list) => barCodeList.value = list,
  //   );
  // }
}