import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_state.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';
class PackingScanLogic extends GetxController {
  final PackingScanState state = PackingScanState();

  //日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(PickerType.date,
      saveKey: '${RouteConfig.packingScan.name}${PickerType.date}',
      onChanged: (index) => query());

  //初始化界面后拉取所有数据
  @override
  void onReady() {
    super.onReady();
    state.getAllData(
        time: pickerControllerDate
            .getDateFormatYMD()
            .replaceAll('-', '')
            .toString(),
        error: (msg) => errorDialog(content: msg));
  }

  query() {
    state.getAllData(
        time: pickerControllerDate
            .getDateFormatYMD()
            .replaceAll('-', '')
            .toString(),
        error: (msg) => errorDialog(content: msg));
  }


  bool checkCode(String code) {
    // var have = 1;
    // var codes = "";
    // var deliveryNumber = "";
    //
    // var count = 0;

    if (code.isNotEmpty &&
        state.packingShipmentScanInfo!.GT_ITEMS2!.isNotEmpty) {
      for (var data in state.packingShipmentScanInfo!.GT_ITEMS2!) {
        if (code == data.ZCTNLABEL) {}
      }
    }

    return false;
  }
}
