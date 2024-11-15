import 'dart:convert';
import 'package:get/get.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_state.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_shipment_scan_view.dart';
import '../../../../bean/http/response/packing_shipment_scan.dart';
import '../../../../bean/http/response/packing_shipment_scan_info.dart';
import '../../../../route.dart';
import '../../../../utils/web_api.dart';
import '../../../../widget/dialogs.dart';
import '../../../../widget/picker/picker_controller.dart';

class PackingScanLogic extends GetxController {
  final PackingScanState state = PackingScanState();

  ///日期选择器的控制器
  late DatePickerController pickerControllerDate = DatePickerController(PickerType.date,
      saveKey: '${RouteConfig.packingScanPage.name}StartDate',
      onChanged: (index) => query());

  ///初始化界面后拉取所有数据
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
