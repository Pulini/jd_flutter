import 'package:get/get.dart';
import 'package:jd_flutter/bean/http/response/container_scanner_info.dart';
import 'package:jd_flutter/bean/http/response/packing_shipment_scan_info.dart';
import 'package:jd_flutter/fun/warehouse/out/forming_packing_scan/packing_shipment_scan_view.dart';
import 'package:jd_flutter/utils/utils.dart';
import 'package:jd_flutter/utils/web_api.dart';
import 'package:jd_flutter/widget/custom_widget.dart';
import 'package:jd_flutter/widget/dialogs.dart';

class PackingScanState {
  var dataList = <ContainerScanner>[].obs;
  PackingShipmentScanInfo? packingShipmentScanInfo; //成型集装箱出货信息
  var showDataList = <GtItem>[].obs; //汇总拣货

  var showCabinetNumber = ''; //显示的柜号
  var scanNumber = ''.obs; //扫描的条码
  var canAdd = true; //可以进行扫描

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
        dataList.value = [
          for (var i = 0; i < response.data.length; ++i)
            ContainerScanner.fromJson(response.data[i])
        ];
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
    required bool isGo,
  }) {
    sapPost(
      method: webApiSapContainerShipmentScanner,
      loading: 'packing_shipment_shipping_information'.tr,
      body: {'ZHGCCRQ': time, 'ZZKHXH1': cabinetNumber},
    ).then((response) {
      if (response.resultCode == resultSuccess) {
        packingShipmentScanInfo =
            PackingShipmentScanInfo.fromJson(response.data);
        showCabinetNumber = cabinetNumber!;
        showDataList.value = packingShipmentScanInfo!.item1!;

        if (isGo) {
          Get.to(() => const PackingShipmentScanPage());
        } else {
          for (var data in showDataList) {
            data.isThis = false;
            if (data.customerPO == order) {
              data.isThis = true;
            }
          }
          showDataList.refresh();
        }
        //跳转到扫码界面
      } else {
        showSnackBar(message: response.message ?? 'query_default_error'.tr);
      }
    });
  }

  int checkCode({
    String? code,
    required Function(String) checkSuccess,
    required Function() checkError,
  }) {
    var have = 1; //0代表有这个条码   1代表条码错误  2代表重复的交货单
    var codes = '';
    var orderNumber = '';
    var deliveryNumber = '';
    var count = 0;

    if (code!.isNotEmpty && packingShipmentScanInfo!.item2!.isNotEmpty) {
      packingShipmentScanInfo?.item2?.forEach((data) {
        if (code == data.barCodes) {
          count = count + 1;
          codes = code;
          orderNumber = data.orderNumber ?? '';
          deliveryNumber = data.deliveryNumber ?? '';
          have = 0;
          return;
        }
      });
    }

    if (have == 0 && count == 1) {
      addCode(
        code: codes,
        orderNumber: orderNumber,
        deliveryNumber: deliveryNumber,
        success: (order) => checkSuccess.call(order),
        error: () => checkError.call(),
      );
      return 0;
    } else if (have == 0 && count > 1) {
      //0代表有这个条码，数量大于1说明多个交货单
      canAdd = true;
      return 2;
    }
    canAdd = true;
    return have;
  }

  //根据条件获取成型集装箱出货信息
  addCode({
    required String code,
    required String orderNumber,
    required String deliveryNumber,
    required Function(String) success,
    required Function() error,
  }) {
    sapPost(method: webApiSapScanAdd, body: {
      'ZCTNLABEL': code, //外箱标
      'VBELN_VL': deliveryNumber, //交货
      'ZZKHPO2': orderNumber, //订单号
      'ZBILLER': userInfo?.number, //制单人
      'ZZKHXH1': showCabinetNumber, //柜号
      'ZHGCCRQ': getDateSapYMD(), //发货日期},
    }).then((response) {
      canAdd = true;
      if (response.resultCode == resultSuccess) {
        success.call(orderNumber);
        scanNumber.value = code;
      } else {
        error.call();
        showSnackBar(message: response.message ?? 'packing_shipment_add_failed'.tr);
      }
    });
  }
}
