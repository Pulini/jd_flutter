import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/container_scanner_info.dart';
import 'package:jd_flutter/bean/http/response/packing_scan_time.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan_info.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_scan_state.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_shipment_scan_view.dart';
import 'package:jd_flutter/route.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';
import 'package:jd_flutter/widget/picker/picker_controller.dart';



class PackingScanLogic extends GetxController {
  final PackingScanState state = PackingScanState();

  ///日期选择器的控制器
  var pickerControllerDate = DatePickerController(
    PickerType.startDate,
    saveKey: '${RouteConfig.packingScan.name}${PickerType.startDate}',
  );

  ///初始化界面后拉取所有数据
  @override
  void onReady() {
    super.onReady();
    // getAllData();
  }

  getAllData() {
    var body = <PackingScanTime>[];
    body.add(PackingScanTime(
        ZHGCCRQ: pickerControllerDate.getDateFormatYMD().replaceAll('-', '')));

    httpPost(
      method: webApiSapContainerScanner,
      loading: '正在获取汇总数据...',
      body: body,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ContainerScanner>[];
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(ContainerScanner.fromJson(jsonList[i]));
        }
        state.dataList.value = list;
        if (list.isNotEmpty) Get.back();
      } else {
        state.dataList.value = [];
        errorDialog(content: response.message);
      }
    });
  }

  goShipment(String cabinetNumber) {
    ///柜号

    getShipmentInformation(
        pickerControllerDate.getDateFormatYMD().replaceAll('-', ''),
        cabinetNumber,
        "");
  }

  getShipmentInformation(String time, String cabinetNumber, String order) {
    var body = <PackingShipmentScan>[];
    body.add(PackingShipmentScan(ZHGCCRQ: time, ZZKHXH1: cabinetNumber));

    sapPost(
      method: webApiSapContainerScanner,
      loading: '正在获取成型集装箱出货信息...',
      body: body,
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        state.packingShipmentScanInfo =
            PackingShipmentScanInfo.fromJson(response.data);
        state.outMessage = state.packingShipmentScanInfo?.GT_ITEMS;
        state.outMessage?.forEach((data) {
          if (order.isNotEmpty) {
            data.isThis = false;
            if (data.ZZKHPO2 == order) {
              data.isThis = true;
            }
          }
        });
        Get.to(() => const PackingShipmentScanPage());///跳转到扫码界面
      } else {
        errorDialog(content: response.message);
      }
    });
  }

  bool checkCode(String code) {
    // var have = 1;
    // var codes = "";
    // var deliveryNumber = "";
    //
    // var count = 0;

    if (code.isNotEmpty && state.packingShipmentScanInfo!.GT_ITEMS2!.isNotEmpty){
      for (var data in state.packingShipmentScanInfo!.GT_ITEMS2!) {
        if(code==data.ZCTNLABEL){

        }
      }}

    return false;
  }
}
