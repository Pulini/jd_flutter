import 'dart:convert';

import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/container_scanner_info.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan_info.dart';
import 'package:jd_flutter/fun/other/forming_packing_scan/packing_shipment_scan_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/dialogs.dart';



class PackingScanState {
  var dataList = <ContainerScanner>[].obs;
  PackingShipmentScanInfo? packingShipmentScanInfo; //成型集装箱出货信息
  var showDataList = <GtItem>[].obs; //汇总拣货

  var showCabinetNumber = ''.obs; //显示的柜号
  var scanNumber = ''.obs; //扫描的条码

  //  获取汇总信息
  getAllData({
    String? time,
    required Function(String msg) error,
  }) {
    sapPost(
      method: webApiSapContainerScanner,
      loading: 'packing_shipment_getting_summary_data'.tr,
      body: {'ZHGCCRQ': time},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        var list = <ContainerScanner>[];
        var jsonList = jsonDecode(response.data);
        for (var i = 0; i < jsonList.length; ++i) {
          list.add(ContainerScanner.fromJson(jsonList[i]));
        }
        dataList.value = list;
        if (list.isNotEmpty) Get.back();
      } else {
        dataList.value = [];
        error.call(response.message ?? '');
      }
    });
  }

  //根据条件获取成型集装箱出货信息
  getShipmentInformation({
    String? time,
    String? cabinetNumber,
    String? order,
    required Function(String msg) error,
  }) {
    sapPost(
      method: webApiSapContainerScanner,
      loading: 'packing_shipment_shipping_information'.tr,
      body: {'ZHGCCRQ': time, 'ZZKHXH1': cabinetNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        packingShipmentScanInfo =
            PackingShipmentScanInfo.fromJson(response.data);
        cabinetNumber = cabinetNumber;
        showDataList.value = packingShipmentScanInfo!.item1!;

        Get.to(() => const PackingShipmentScanPage());

        //跳转到扫码界面
      } else {
        error.call(response.message ?? 'query_default_error'.tr);
      }
    });
  }

  int checkCode({
    String? code,
    required Function() success,
  }) {
    var have = 1;
    var codes = '';
    var orderNumber = '';
    var deliveryNumber = '';
    var count = 0;

    if (code!.isNotEmpty && packingShipmentScanInfo!.item2!.isNotEmpty) {
      for (var i = 0; i < packingShipmentScanInfo!.item2!.length; ++i) {
        if (code == packingShipmentScanInfo!.item2![i].barCodes) {
          count += 1;
          codes = code;
          orderNumber =
              packingShipmentScanInfo!.item2![i].orderNumber?? '';
          deliveryNumber =
              packingShipmentScanInfo!.item2![i].deliveryNumber?? '';
          have = 0;
          break;
        }
      }
    }

    if (have == 0 && count == 1) {
      addCode(
        code: codes,
        orderNumber: orderNumber,
        deliveryNumber: deliveryNumber,
        success: () => { success.call()},
        error: (msg) => errorDialog(content: msg),
      );
      return 0;
    } else if (have == 0 && count > 1) {
      //0代表有这个条码，数量大于1说明多个交货单
      return 2;
    }

    return have;
  }

  //根据条件获取成型集装箱出货信息
  addCode({
    String? code,
    String? orderNumber,
    String? deliveryNumber,
    required Function() success,
    required Function(String msg) error,
  }) {
    sapPost(method: webApiSapScanAdd, body: {
      'ZCTNLABEL': code, //外箱标
      'VBELN_VL': deliveryNumber, //交货
      'ZZKHPO2': orderNumber, //订单号
      'ZBILLER': userInfo?.number, //制单人
      'ZZKHXH1': showCabinetNumber, //柜号
      'ZHGCCRQ': showCabinetNumber, //发货日期},
    }).then((response) {
      Future.delayed(const Duration(seconds: 1), () {  //延迟一秒执行
        if (response.resultCode == resultSuccess) {



        } else {
          error.call(response.message ?? 'packing_shipment_add_failed'.tr);
        }
      });
    });
  }
}
